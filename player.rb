class Player
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_move
    raise NotImplementedError.new
  end

  def name
    color.to_s.capitalize
  end

  def pieces(board)
    board.my_pieces(color)
  end

end

class HumanPlayer < Player

  def get_move(board)
    puts "#{name}, make a move:"
    input = gets.downcase.scan(/[abcdefgh][1-8]/).first(2)
    raise InputError.new "Invalid input" if input.count != 2
    [convert_coord(input.first), convert_coord(input.last)]
  end

  private

  def convert_coord(coord)
    letter, num = coord.split('')
    [8 - num.to_i, letter.ord - 'a'.ord]
  end

end

class ComputerPlayer < Player

  def get_move(board)
    puts "Hmm..."
    sleep(0.5)

    try_checking(board) || try_take_piece(board) || try_random(board)
  end

  def try_take_piece(board)
    pieces(board).shuffle.each do |piece|
      moves = board.check_moves(piece, piece.moves(board))
      moves.shuffle.each do |move|
        return [piece.position, move] if (!board[move].nil? && board[move].color != color)
      end
    end
    false
  end

  def try_checking(board)
    pieces(board).shuffle.each do |piece|
      moves = board.check_moves(piece, piece.moves(board))
      moves.shuffle.each do |move|
        new_board = board.deep_dup
        new_board.force_move(piece, move)
        other_color = piece.white? ? :black : :white
        if new_board.in_check?(other_color)
          return [piece.position, move]
        end
      end
    end
    false
  end

  def try_random(board)
    pieces(board).shuffle.each do |piece|
      moves = board.check_moves(piece, piece.moves(board))
      return [piece.position, moves.sample] unless moves.empty?
    end
  end



end
