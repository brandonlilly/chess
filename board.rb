class Board

  def initialize
    @board = Array.new(8) { Array.new(8) }
  end

  def setup
    @board[0] = add_royalty(0, :black)
    @board[7] = add_royalty(7, :white)
    @board[1] = add_pawns(1, :black)
    @board[6] = add_pawns(6, :white)
  end

  def deep_dup
    new_board=Board.new
    (0..7).each do |x|
      (0..7).each do |y|
        pos = [x,y]
        piece = self[pos]
        new_board[pos] = piece.nil? ? nil : piece.deep_dup
      end
    end

    new_board
  end

  def [](pos)
    x, y = pos
    @board[x][y]
  end

  def []=(pos,value)
    x, y = pos
    @board[x][y] = value
  end

  def force_move(piece, dest)
    self[dest] = piece
    self[piece.position] = nil
  end

  def make_move(start, dest)
    piece = self[start]
    moves = piece.moves(self)
    moves = check_moves(piece, moves)
    puts piece.render
    if moves.include?(dest)
      piece.set_position(dest)
      self[dest] = piece
      self[start] = nil
    else
      raise InputError.new "Invalid destination"
    end
  end

  def in_checkmate?(color)
    my_pieces(color).each do |piece|
      return false unless check_moves(piece, piece.moves(self)).empty?
    end
    true
  end

  def pieces
    @board.flatten.compact
  end

  def my_pieces(color)
    pieces.select { |piece| piece.color == color }
  end

  def enemy_pieces(color)
    pieces.select { |piece| piece.color != color }
  end

  def check_moves(piece, moves)
    moves.reject do |move|
      new_board = self.deep_dup
      new_board.force_move(piece, move)
      new_board.in_check?(piece.color)
    end
  end

  def self.in_bounds?(pos)
    x, y = pos
    x.between?(0, 7) && y.between?(0, 7)
  end

  def render
    out_string = "\n"
    @board.each_with_index do |row, ri|
      out_string += "#{8 - ri} "
      row.each_with_index do |col, ci|
        tile = col.nil? ? "   " : col.render
        bg_color = (ri + ci).even? ? :magenta : :light_cyan
        out_string += tile.colorize(background: bg_color)
      end
      out_string += "\n"
    end
    out_string += "  "
    ('a'..'h').each { |n| out_string += " #{n} "}
    out_string += "\n"
  end

  def display
    puts render
  end

  def check_start(player, pos)
    piece = self[pos]
    if piece.nil?
      raise InputError.new "No piece at that position"
    end
    if piece.color != player.color
      raise InputError.new "You don't own that piece"
    end
  end

  def in_check?(color)
    king = find_king(color)
    enemy_pieces(color).any? do |piece|
      piece.moves(self).include?(king.position)
    end
  end

  private

  def add_royalty(row, color)
    royalty = [Rook, Knight, Bishop, King, Queen, Bishop, Knight, Rook]
    royalty.each_with_index.map do |type, col|
      type.new(color, [row, col])
    end
  end

  def add_pawns(row, color)
    Array.new(8) { |col| Pawn.new(color, [row, col]) }
  end

  def find_king(color)
    my_pieces(color).find { |piece| piece.is_a? King }
  end

end
