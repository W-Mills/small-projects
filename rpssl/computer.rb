# computer.rb
class Computer < Player
  attr_accessor :weights, :weighted_moves, :personality

  ROBOTS = ['T800', 'Wintermute', 'HAL 9000', 'WALL-E']
  PERSONALITY_BOOST = 30

  def initialize
    super
    set_personality
    init_weights
    weight_personality
    update_weighted_moves
  end

  def init_weights
    self.weights = {}
    Move::VALUES.each do |move|
      weights[move] = 20
    end
  end

  def weight_personality
    case personality
    when 'T800' then set_t800
    when 'Wintermute' then set_wintermute
    when 'HAL 9000' then set_hal_9000
    when 'WALL-E' then set_wall_e
    end
  end

  def set_t800
    weights['rock'] += PERSONALITY_BOOST
    weights['scissors'] += PERSONALITY_BOOST
  end

  def set_wintermute
    weights.each { |k, _| weights[k] -= 18 }
  end

  def set_hal_9000
    weights['paper'] += PERSONALITY_BOOST
  end

  def set_wall_e
    weights['spock'] += PERSONALITY_BOOST
    weights['lizard'] += PERSONALITY_BOOST
  end

  def update_weighted_moves
    self.weighted_moves = []
    weights.each do |move, weighting|
      weighting.times { weighted_moves << move }
    end
  end

  def adjust_weights(cntr_moves_array, amount)
    cntr_moves_array.each do |move|
      weights[move] += amount unless weights[move] <= 1
    end
  end

  def set_name
    self.name = ROBOTS.sample
  end

  def set_personality
    self.personality = name
  end

  def choose
    current_move = create_move(weighted_moves.sample)
    self.move = current_move
    update_moves_history(current_move)
  end
end
