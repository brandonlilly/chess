require_relative "board.rb"
require_relative "piece.rb"
require_relative "player.rb"
require 'colorize'
require 'byebug'

class InputError < StandardError
end

class Game
  attr_reader :board

  def initialize(w_player, b_player)
    @w_player = w_player
    @b_player = b_player
    @board = Board.new
    @board.setup
    @turn = 0
  end

  def play
    until over?
      board.display
      current_player = @turn.even? ? @w_player : @b_player

      if board.in_checkmate?(current_player.color)
        puts "Checkmate. #{current_player.name} loses"
        break
      elsif board.in_check?(current_player.color)
        puts "#{current_player.name} in check"
      end

      begin
        move = current_player.get_move(board)
        board.check_start(current_player, move.first)
        board.make_move(move.first, move.last)
        @turn += 1
      rescue InputError => e
        puts e.message
        retry
      end
      board.promote_pawns
    end
  end

  def over?
    false
  end
end

if __FILE__ == $PROGRAM_NAME
  game = Game.new(HumanPlayer.new(:white), ComputerPlayer.new(:black))
  game.play
end
