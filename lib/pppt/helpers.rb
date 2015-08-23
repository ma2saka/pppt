class Helpers
  def self.truncate_screen_width(str, width, suffix = '...')
    i = 0
    str.each_char.inject(0) do |c, x|
      c += x.ascii_only? ? 1 : 2
      i += 1
      next c if c < width
      return str[0, i] + suffix
    end
    str
  end

  def self.split_screen_width(str, width = 40)
    s = i = r = 0
    str.each_char.inject([]) do |res, c|
      i += c.ascii_only? ? 1 : 2
      r += 1
      next res if i < width
      res << str[s, r]
      s += r
      i = r = 0
      res
    end << str[s, r]
  end

  def self.screen_width(str)
    hankaku_len = str.each_char.count(&:ascii_only?)
    hankaku_len + (str.size - hankaku_len) * 2
  end

  def self.format_page_number(page)
    index = page['page'] || '-'
    title = page['action'] || (page['title'] && " - #{page['title']}") || page['h1'] || page['h2'] || page['h3'] || (page['body'] && "     #{Helpers.truncate_screen_width(page['body'].join(''), 15)}")
    format('%02s    %s', index, title)
  end

end
