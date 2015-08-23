class PresentationWindow
  def initialize(data)
    @pages = PresentationPages.new(data)
    @current = 0
    @max = @pages.size
    init_screen
  end

  def next
    @current += 1 if @pages.data.length - 1 > @current
  end

  def prev
    @current -= 1 if @current > 0
  end

  def show(page = nil)
    @current = page || @current
    page_data = @pages.data[@current]
    update_window(Curses.stdscr, page_data)
  end

  # 目次ページ
  def index
    w = Curses.stdscr
    current = @current
    start_point = current - w.maxy / 2
    loop do
      height = w.maxy - 5
      w.clear
      w.setpos(1, 0)
      w.addstr(' -- index --'.center(w.maxx - 1))
      vindex = 3
      start_point = current if start_point > current
      start_point = current - height if current - start_point >= height
      start_point = 0 if start_point < 0
      @pages.data.each_with_index do |page, i|
        next if i < start_point
        w.setpos(vindex, 0)
        w.addstr(' ' * w.maxx)
        w.setpos(vindex, 3)
        w.standout if i == current
        page_number_string = Helpers.format_page_number(page)
        w.addstr(page_number_string + (' ' * (w.maxx - Helpers.screen_width(page_number_string) - 4)))
        vindex += 1
        w.standend if i == current
        break if i >= start_point + height
      end
      w.refresh
      Curses.timeout = -1
      c = w.getch
      Curses.timeout = 1000
      case c
      when 27, 8
        return current
      when Curses::KEY_UP, 'k'
        current -= 1 if current > 0
      when Curses::KEY_DOWN, 'j'
        current += 1 if current < @pages.data.length - 1
      when 10, ' '
        @current = current
        return current
      end
    end
  end

  private

  # window 全体を再描画
  def update_window(w, page_data)
    return unless page_data
    w.clear
    w.setpos(0, 0)
    page_data.each do |k, v|
      next unless v
      write_element(w, k, v)
    end
    render_time(w)
    w.refresh
  end

  # 画面右上の時刻表示
  def render_time(w)
    w.setpos(1, w.maxx - 10)
    w.addstr(Time.now.strftime('%H:%M:%S'))
  end

  # ページコンテンツを表示する
  def write_element(w, k, v)
    len = 1
    len = Helpers.screen_width(v) if v.is_a? String
    width = w.maxx - 1
    pad = ' ' * ((width - len) / 2)
    case k
    when 'action'
      if v == 'logo'
        text = "powered by POOR POINT PRESENTATION #{Pppt::VERSION}"
        w.setpos((w.maxy / 2) - 2, (w.maxx - text.length) / 2)
        if !@started
          text.each_char do |c|
            w.addstr(c)
            w.refresh
            sleep 0.05
          end
          sleep 0.5
          @started = true
        else
          w.addstr(text)
        end
        w.setpos(w.maxy - 5, 0)
        w.attron(Curses::A_BLINK)
        w.addstr('<< STAND BY >>'.center(w.maxx - 1))
        w.attroff(Curses::A_BLINK)
      end
    when 'h1'
      w.attron(Curses::A_BOLD)
      w.setpos(w.maxy / 3, 0)
      w.addstr("#{pad}#{v}#{pad}")
      w.attroff(Curses::A_BOLD)
    when 'h2'
      w.attron(Curses::A_UNDERLINE)
      w.setpos(w.maxy * 2 / 3, 0)
      w.addstr("#{pad}#{v}#{pad}")
      w.attroff(Curses::A_UNDERLINE)
    when 'h3'
      vindex = 0
      v.split("\n").each do |x|
        x.chomp!
        w.setpos((w.maxy / 2) - 2 + vindex, 0)
        len = Helpers.screen_width(x)
        pad = ' ' * ((width - len) / 2)
        w.addstr("#{pad}#{x}#{pad}")
        vindex += 1
      end
    when 'title'
      w.attron(Curses::A_BOLD)
      w.setpos(1, 2)
      w.addstr(v)
      w.setpos(3, 0)
      w.attroff(Curses::A_BOLD)
      w.attron(Curses::A_REVERSE)
      w.addstr(' ' * w.maxx)
      w.attroff(Curses::A_REVERSE)
    when 'body'
      vindex = 5
      w.setpos(vindex, 2)
      v.each do |line|
        vindex = render_body_text(w, line, vindex)
      end
    when 'page'
      w.setpos(w.maxy - 2, 0)
      w.addstr("- #{v}/#{@max} -".center(w.maxx - 1))
    end
  end

  def render_body_text(w, lines, vindex, level = 1)
    width = w.maxx - 4
    vi = vindex + 1
    if lines.is_a? Array
      lines.each do |sub_line|
        vi = render_body_text(w, sub_line, vi, level + 1)
      end
    else
      sp = ['*', '-', '>'][level - 1]
      indent = ' ' * (level * 2)
      lines.split("\n").each do |x|
        Helpers.split_screen_width(x, width - (4 + 4 * level)).each do |xl|
          w.setpos(vi, 2)
          w.addstr("#{indent}#{sp} #{xl}")
          sp = ' '
          vi += 1
        end
      end
    end
    vi
  end
end
