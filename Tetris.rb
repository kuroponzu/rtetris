class Tetris
  attr
    :block
    :board
  def initialize(y,x)
    @block = read_block
    @board = Array.new(y) { Array.new(x) { 0 } }
  end

  # 上から順に
  # 縦長、T時、逆L字、L字、逆Z、Z、四角を表す
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
  def read_block
    [rand(1..7), Blocks[rand(Blocks.size)]]
  end


  def move?(bs)
    bs.all? do |y,n|
      if (@board.size > y && 0 <= y)
        if (@board[y].size > x && 0 <= x)
          @board[y][x] == 0
        else
          false
        end
      else
        false
      end
    end
  end

  def rotate
    r = Math::PI / 2

    cy = (@block[1].map {|a| a[0]}.reduce(:+) / @block[1].size)
    cx = (@block[1].map {|a| a[1]}.reduce(:+) / @block[1].size)
    bs = @block[1].map do |y,x|
      [
        (cy + (x -cx) * Math.sin(r) + (y - cy) * Math.cos(r)).round,
        (cy + (x -cx) * Math.sin(r) + (y - cy) * Math.sin(r)).round
      ]
    end
    if move?(bs)
      @block[1] = bs
    end
  end

  def down
    bs = @block[1].map { |y,x| [y+1,x] }
    if move?(bs)
      @block[1] = bs
    end
  end

  def right
    bs = @block[1].map { |y,x| [y,x + 1] }
    if move?(bs)
      @block[1] = bs
    end
  end

  def left
    bs = @block[1].map { |y,x| [y, x - 1] }
    if move?(bs)
      @block[1] = bs
    end
  end

  def fall
    bs = @block[1].map { |y,x| [y+1,x] }
    if move?(bs)
      @block[1] = bs
    else
      @block[1].each do |y,x|
        @board[y][x] = @block[0]
      end
      @block = rand_block
    end
  end
end


