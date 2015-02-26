require_relative 'poly_tree_node'

class BoardNode < PolyTreeNode
  attr_reader :board, :piece, :move

  def initialize(board, piece, move)
    @board = board
    @piece = piece
    @move = move

    @parent, @children = nil, []
  end

end

class AIPlayer < Player

  VALUES = {
    King =>   1000,
    Queen =>  8.8,
    Rook =>   5.1,
    Bishop => 3.33,
    Knight => 3.2,
    Pawn =>   1
  }

  def get_move(board)
    root_node = build_move_tree(board)
    best_node = root_node.children.max_by do |child|
      evaluate_node(board, child)
    end

    [best_node.piece.position, best_node.move]
  end

  def build_move_tree(board)
    root_node = BoardNode.new(board.deep_dup, nil, nil)

    depth = 3
    current_color = color
    frontier_nodes = [root_node]

    until depth == 0
      next_nodes = []

      frontier_nodes.each do |frontier_node|
        current_board = frontier_node.board
        all_moves = get_all_moves(current_board, current_color)
        # debugger
        all_moves.shuffle.each do |piece, moves|
          moves.each do |move|
            new_board = current_board.deep_dup
            new_board.force_move(piece, move)
            next_node = BoardNode.new(new_board, piece.deep_dup, move.dup)
            frontier_node.add_child(next_node)
            next_nodes << next_node
          end
        end
      end

      frontier_nodes = next_nodes
      current_color = current_color == :white ? :black : :white
      depth -= 1
    end

    root_node
  end

  def get_all_moves(board, color)
    all_moves = []
    board.my_pieces(color).each do |piece|
      moves = board.check_moves(piece, piece.moves(board))
      all_moves << [piece, moves] unless moves.empty?
    end
    all_moves
    #[[piece, dest], [piece, dest]]
  end

  def evaluate_board(board)
    enemy_value = 0
    my_value = 0
    board.pieces.each do |piece|
      value = VALUES[piece.class]
      piece.color == color ? my_value += value : enemy_value += value
    end

    # if board.in_checkmate?(other_color)
    #   my_value += 1000
    # elsif board.in_checkmate?(color)
    #   enemy_value += 1000
    # else
      my_value += 1 if board.in_check?(other_color)
      enemy_value += 1 if board.in_check?(color)
    # end

    my_value - enemy_value
  end

  def evaluate_node(board, node)
    return evaluate_board(node.board) if node.children.empty?

    ratings = node.children.map do |child|
      evaluate_node(board, child)
    end

    ((ratings.inject(:+).to_f / ratings.size) + ratings.min) / 2
  end

  def other_color
    color == :white ? :black : :white
  end

end
