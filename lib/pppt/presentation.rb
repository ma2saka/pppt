#!/usr/bin/ruby
require 'curses'
require 'pppt/helpers'
require 'pppt/presentation_pages'
require 'pppt/presentation_window'
include Curses

class Pppt::Presentation
  def initialize(pages)
    @window = Pppt::PresentationWindow.new(pages)
    @prev_ch = nil
    Curses.stdscr.keypad(true)
    Curses.noecho
    Curses.curs_set(0)
    Curses.timeout = 1000
  end

  def run
    loop do
      @window.show
      c = getch
      case c
      when 'l'
        @window.index
      when ':'
        cmd = input
        case cmd
        when 'list', 'l'
          @window.index
        when 'q', 'exit'
          exit
        end
        next
      when 'k', Curses::KEY_UP, Curses::KEY_LEFT, 8
        @window.prev
      when ' ', 'j', Curses::KEY_RIGHT, Curses::KEY_DOWN, 10
        @window.next
      end
    end
  end

  def getch
    @prev_ch = Curses.stdscr.getch
  end

  def input
    Curses.timeout = -1
    setpos(Curses.stdscr.maxy - 1, 0)
    Curses.stdscr.deleteln
    Curses.stdscr.addstr(':')
    Curses.echo
    Curses.curs_set(2)
    buf = Curses.stdscr.getstr
    Curses.curs_set(0)
    Curses.noecho
    Curses.timeout = 1000
    @prev_input = buf.chomp
  end
end
