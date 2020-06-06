require "bundler"
Bundler.require
require "curses"

class Tetris
  attr
    :block # [color,[y,x]]
    :board # [[color]]

  def initialize(y,x)
    @block = read_block
    @board = Array.new(y) { Array.new(x) { 0 } }
  end

  # 上から順に
  # 縦長、T時、L字、逆L字、Z、逆Z、四角を表す
  Blocks = [
    [[0,0],[1,0],[2,0],[3,0]],
    [[0,0],[0,1],[0,2],[1,1]],
    [[0,0],[1,0],[2,0],[0,1]],
    [[0,0],[0,1],[1,1],[2,1]],
    [[0,0],[1,0],[1,1],[2,1]],
    [[0,1],[1,1],[1,0],[2,0]],
    [[0,0],[0,1],[1,0],[1,1]],
  ]

  # [0]は色を表す、ミノに対して色を割り当て、ミノ未配置の場所については
  # [0] = 0として、扱う。
  # return [int,Blocks]
  # テトリミノの色(int:1..7)と形を返す。
  # 色が0の場合は、テトリミノが配置されてないことを表す。
  def read_block
    [rand(1..7), Blocks[rand(Blocks.size)]]
  end

  def move?(bs)
    bs.all? do |y,x|
      if (@board.size > y && 0 <= y) && (@board[y].size > x && 0 <= x)
        # 0にすることでテトリミノがないことを表す。
        @board[y][x] == 0
      else
        false
      end
    end
  end

  def rotate
    r = Math::PI / 2

    # ブロックのy座標の基準
    cy = (@block[1].map {|a| a[0]}.reduce(:+) / @block[1].size)
    # ブロックのx座標の基準
    cx = (@block[1].map {|a| a[1]}.reduce(:+) / @block[1].size)

    bs = @block[1].map do |y,x|
      [
        x,y
      ]
      # [
      #   # 回転後のy座標
      #   (cy + (x -cx) * Math.sin(r) + (y - cy) * Math.cos(r)).round,
      #   # 回転後のx座標
      #   (cx + (x -cx) * Math.cos(r) - (y - cy) * Math.sin(r)).round
      # ]
    end
    if move?(bs)
      @block[1] = bs
    end
  end

  def down
    bs = @block[1].map { |y, x| [y + 1, x] }
    if move?(bs)
      @block[1] = bs
    end
  end

  def right
    bs = @block[1].map { |y, x| [y, x + 1] }
    if move?(bs)
      @block[1] = bs
    end
  end

  def left
    bs = @block[1].map { |y, x| [y, x - 1] }
    if move?(bs)
      @block[1] = bs
    end
  end

  def fall
    bs = @block[1].map { |y, x| [y+1, x] }
    if move?(bs)
      @block[1] = bs
    else
      @block[1].each do |y, x|
        @board[y][x] = @block[0]
      end
      @block = read_block
    end
  end


  def delete
    for y in 0..@board.size - 1
      # 一列に並んでいるのかを判定
      if @board[y].all? {|c| c !=0}
        for yy in 0..y-1
          @board[yy].each.with_index do |c, x|
            @board[y - yy][x] = @board[y - yy - 1][x]
          end
        end
      end
    end
  end

  C = Curses

  def controller(c)
    case c
    when "w"
      rotate
    when "s"
      down
    when "d"
      right
    when "a"
      left
    when "q"
      C.close_screen
      exit
    else
      nil
    end
  end

  def display_init
    C.init_screen
    C.start_color
    C.use_default_colors
    C.noecho
    C.curs_set(0)

    [
      C::COLOR_BLACK,
      C::COLOR_RED,
      C::COLOR_GREEN,
      C::COLOR_YELLOW,
      C::COLOR_BLUE,
      C::COLOR_MAGENTA,
      C::COLOR_CYAN,
      C::COLOR_WHITE,
    ].each.with_index do |c,i|
      C.init_pair(i, C::COLOR_WHITE, c)
    end
  end

  def display
    C.clear
    C.addstr("-" * (@board[0].size + 2))
    C.addstr("\n")
    for y in 0..@board.size - 1
      C.addstr("|")
      for x in 0..@board[y].size - 1
        # テトリミノがおいてあるかどうかを確認している。
        c = @block[1].any? { |a| a == [y,x] } ? @block[0] : @board[y][x]
        C.attron(C.color_pair(c))
        C.addstr(" ")
        C.attroff(C.color_pair(c))
      end
      C.addstr("|")
      C.addstr("\n")
    end
    C.addstr("-" * (@board[0].size + 2))
    C.addstr("\n")
    C.refresh
  end

  def run 
    display_init
    # Thread間の処理の同期に利用
    m = Mutex.new
    Thread.new do
      loop do
        m.synchronize do
          fall
          delete
          display
        end
        sleep 1
      end
    end

    loop do
      controller(C.getch.to_s)
      m.synchronize do
        delete
        display
      end
    end
  end
end

Tetris.new(30,30).run
