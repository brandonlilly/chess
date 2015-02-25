class Player
  attr_reader :color

  def initialize(color)
    @color = color
  end

  def get_move
    puts "#{name}, make a move:"
    input = gets.downcase.scan(/[abcdefgh][1-8]/).first(2)
    raise InputError.new "Invalid input" if input.count != 2
    [convert_coord(input.first), convert_coord(input.last)]
  end

  def name
    color.to_s.capitalize
  end

  private

  def convert_coord(coord)
    letter, num = coord.split('')
    [8 - num.to_i, letter.ord - 'a'.ord]
  end

end
