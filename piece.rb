class Piece
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def white?
    @color == :white
  end

  def black?
    @color == :black
  end

  def render(hollow, solid)
    white? ? " #{solid.colorize(:white)} " : " #{solid.colorize(:black)} "
  end

  def limit_moves(moves, board)
    move_arr = moves.select do |move|
      next unless Board.in_bounds?(move)
      board[move].nil? || board[move].color != color
    end
    move_arr
  end

end

class SlidingPiece < Piece
  def moves(start, board)
    moves = []
    x, y = start
    directions.each do |x_shift, y_shift|
      (1..7).each do |n|
        pos = [x + x_shift * n, y + y_shift * n]
        moves << pos
        break unless Board.in_bounds?(pos) && board[pos].nil?
      end
    end
    moves
  end
end

class SteppingPiece < Piece

  def offsets
    raise NotImplementedError.new
  end

  def moves(start, board)
    x, y = start
    moves = offsets.map do |x_shift, y_shift|
      [x + x_shift, y + y_shift]
    end
    moves.select { |move| Board.in_bounds?(move) }
  end
end

class King < SteppingPiece

  def offsets
    [[-1,-1],[-1,0],[-1,1],[0,-1],[0,1],[1,-1],[1,0],[1,1]]
  end

  def render
    super("♔", "♚")
  end

end

class Queen < SlidingPiece

  def directions
    [[-1,0],[1,0],[0,1],[0,-1],[-1,-1],[-1,1],[1,-1],[1,1]]
  end

  def render
    super("♕", "♛")
  end

end

class Rook < SlidingPiece

  def directions
    [[-1,0],[1,0],[0,1],[0,-1]]
  end

  def render
    super("♖", "♜")
  end

end

class Bishop < SlidingPiece

  def directions
    [[-1,-1],[-1,1],[1,-1],[1,1]]
  end

  def render
    super("♗", "♝")
  end

end

class Knight < SteppingPiece

  def offsets
    [[-1,2],[-1,-2],[-2,1],[-2,-1],[1,-2],[1,2],[2,1],[2,-1]]
  end

  def render
    super("♘", "♞")
  end

end

class Pawn < SteppingPiece

  def moves(start, board)
    x, y = start
    offsets = [offset]
    offsets += first_move(start) unless @has_moved
    moves = []
    offsets.each do |x_shift, y_shift|
      pos = [x + x_shift, y + y_shift]
      moves << pos if Board.in_bounds?(pos) && board[pos].nil?
    end
    attacks.each do |x_shift, y_shift|
      pos = [x + x_shift, y + y_shift]
      if Board.in_bounds?(pos) &&
         !board[pos].nil? &&
         board[pos].color != color

         moves << pos
      end
    end
    moves
  end

  def attacks
    white? ? [[-1, -1], [-1, 1]] : [[1, -1], [1, 1]]
  end

  def offset
    white? ? [-1,0] : [1,0]
  end

  def first_move(start)
    if white? && start.first == 6
      [[-2, 0]]
    elsif black? && start.first == 1
      [[2, 0]]
    else
      []
    end
  end

  def render
    super("♙", "♟")
  end
end
