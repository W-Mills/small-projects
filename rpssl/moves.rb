# moves.rb
class Move
  attr_reader :move

  VALUES = ['rock', 'paper', 'scissors', 'spock', 'lizard']

  COUNTER_MOVES = { 'rock' => ['paper', 'spock'],
                    'paper' => ['lizard', 'scissors'],
                    'scissors' => ['rock', 'spock'],
                    'spock' => ['lizard', 'paper'],
                    'lizard' => ['rock', 'scissors'] }

  def initialize
    @move = self.class.to_s.downcase
  end

  def to_s
    move
  end
end
rr
class Rock < Move
  def >(other_move)
    other_move.class == Scissors || other_move.class == Lizard
  end
end

class Paper < Move
  def >(other_move)
    other_move.class == Rock || other_move.class == Spock
  end
end

class Scissors < Move
  def >(other_move)
    other_move.class == Paper || other_move.class == Lizard
  end
end

class Spock < Move
  def >(other_move)
    other_move.class == Rock || other_move.class == Scissors
  end
end

class Lizard < Move
  def >(other_move)
    other_move.class == Paper || other_move.class == Spock
  end
end
