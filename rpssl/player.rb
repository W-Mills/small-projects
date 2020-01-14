# player.rb
class Player
  include Displayable
  attr_accessor :move, :name, :moves_history, :won_with

  def initialize
    set_name
    init_moves_history
    init_won_with
  end

  def create_move(choice)
    case choice
    when 'rock' then Rock.new
    when 'paper' then Paper.new
    when 'scissors' then Scissors.new
    when 'spock' then Spock.new
    when 'lizard' then Lizard.new
    end
  end

  def init_moves_history
    self.moves_history = {}
    Move::VALUES.each do |move|
      moves_history[move] = 0
    end
  end

  def update_moves_history(move)
    moves_history[move.to_s] += 1
  end

  def init_won_with
    self.won_with = {}
    Move::VALUES.each do |move|
      won_with[move] = 0
    end
  end

  def update_won_with(move)
    won_with[move.to_s] += 1
  end

  def any_win_values?
    won_with.values.any? { |num| num > 0 }
  end
end
