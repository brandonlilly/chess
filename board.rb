class Board

  def initialize
    @board = Array.new(8) { Array.new(8) }
  end

  def setup
    royalty = [:black, :white].map do |color|
       [Rook.new(color), Knight.new(color), Bishop.new(color),
       King.new(color), Queen.new(color), Bishop.new(color),
       Knight.new(color), Rook.new(color)]
    end

    @board[0] = royalty[0]
    @board[-1]  = royalty[-1]
    @board[-2] = Array.new(8) { Pawn.new(:white) }
    @board[1]  = Array.new(8) { Pawn.new(:black) }
  end

  def deep_dup
    new_board=Board.new
    (0..7).each do |x|
      (0..7).each do |y|
        pos = [x,y]
        new_board[pos] = self[pos]
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

  def force_move(start, dest)
    piece = self[start]
    self[dest] = piece
    self[start] = nil
  end

  def make_move(start, dest)
    piece = self[start]
    moves = check_moves(start)
    puts piece.render
    if moves.include?(dest)
      self[dest] = piece
      self[start] = nil
    else
      raise InputError.new "Invalid destination"
    end
  end

  def in_checkmate?(color)
    (0..7).each do |x|
      (0..7).each do |y|
        pos = [x, y]
        piece = self[pos]
        next if piece.nil? || piece.color != color
        return false unless check_moves([x,y]).empty?
      end
    end
    true
  end

  def valid_moves(start)
    piece = self[start]
    moves = piece.moves(start, self)
    moves = piece.limit_moves(moves, self)
  end

  def check_moves(start)
    piece = self[start]
    moves = valid_moves(start)
    moves.reject do |move|
      new_board = self.deep_dup
      new_board.force_move(start, move)
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
    (0..7).each do |x|
      (0..7).each do |y|
        pos = [x, y]
        piece = self[pos]
        next if piece.nil?
        if piece.color != color
          moves = valid_moves(pos)
          moves.each do |move|
            target_piece = self[move]
            if target_piece.class == King &&
               target_piece.color == color
              return true
            end
          end
        end
      end
    end
    false
  end


end
