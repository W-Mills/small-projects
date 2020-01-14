# displayable.rb
module Displayable
  def prompt(message)
    puts "==> #{message}"
  end

  def clear_screen
    system('clear') || system('cls')
  end

  def display_rules
    puts "The first to #{RPSGame::WINNING_SCORE} wins the round.\n\n"
    puts "Scissors cuts Paper covers Rock crushes Lizard poisons Spock"
    puts "smashes Scissors decapitates Lizard eats Paper disproves Spock"
    puts "vaporizes Rock crushes Scissors."
    puts "\n"
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Spock, Lizard!\n\n"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Spock, Lizard. Goodbye!"
  end

  def display_choices
    puts
    prompt("Please choose rock, paper, scissors, spock or lizard:")
    puts "\nShortcuts:\n\n"
    Human::SHORTHAND_CHOICES.each do |key, move|
      puts "#{key} => #{move.capitalize}"
    end
  end

  def display_moves
    puts "\n#{human.name} chose #{human.move}."
    puts "#{computer.name} chose #{computer.move}."
  end

  def display_winner
    if human.move > computer.move
      puts "======> #{human.name} won! <======"
    elsif computer.move > human.move
      puts "======> #{computer.name} won! <======"
    else
      puts "======> It's a tie! <======"
    end
  end

  def display_score
    puts "\nScoreboard:"
    print_in_box("#{human.name}: #{score.human[:plays].to_i} <> #{computer.name}: #{score.computer[:plays].to_i} <> Ties: #{score.ties}")
  end

  def display_round_wins
    puts "\nRound Wins:\n"
    print_in_box("#{human.name}: #{score.human[:rounds]} <> ROBOTS: #{score.computer[:rounds]}")
  end

  def display_cpu_best_move
    wins = computer.won_with
    best = wins.values.sort.pop
    puts
    puts "#{computer.name} really likes using #{wins.key(best)}!" if best > 1
    puts
  end

  def display_cpu_personality
    puts "In this round, you will battle: #{computer.name}"
  end

  def describe_cpu_personality
    cpu = computer.name

    if cpu == 'T800'
      puts "T800 is an aggresive one, mostly going for simple smashes\n\n"
    elsif cpu == 'Wintermute'
      puts "Deviously cunning, Wintermute will coldly calculate your demise\n\n"
    elsif cpu == 'HAL 9000'
      puts "HAL 9000 is from another era, when paper was king\n\n"
    elsif cpu == 'WALL-E'
      puts "WALL-E is a cute one, favoring life over things\n\n"
    end
  end

  def print_in_box(text)
    txt = if text.length > 76
            text[0..75]
          else text
          end
    horizontal_rule = "+#{'-' * (txt.length + 2)}+"
    empty_line = "|#{' ' * (txt.length + 2)}|"

    puts horizontal_rule
    puts empty_line
    puts "| #{txt} |"
    puts empty_line
    puts horizontal_rule
  end
end

module Enhanced
  # Enhanced visuals (if ENHANCED == :on in rpssl.rb)
  def display_winning_moves
    display_human_winning_moves if human.any_win_values?
    puts
    display_cpu_winning_moves if computer.any_win_values?
  end

  def display_human_winning_moves
    puts "#{human.name} has won with:"
    human.won_with.each do |move, value|
      puts "#{move.capitalize} ---- #{value}" if value > 0
    end
  end

  def display_cpu_winning_moves
    puts "#{computer.name} has won with:"
    computer.won_with.each do |move, value|
      puts "#{move.capitalize} ---- #{value}" if value > 0
    end
  end

  def display_weights
    puts "Weights are set at:\n"
    total_weights = computer.weights.values.sum
    computer.weights.each do |move, value|
      percentage = (value.fdiv(total_weights) * 100).to_i
      puts "#{percentage}% chance of #{move.capitalize}"
    end
    puts
  end
end

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

# human.rb
class Human < Player
  SHORTHAND_CHOICES = { 'r' => 'rock',
                        'p' => 'paper',
                        's' => 'scissors',
                        'sp' => 'spock',
                        'l' => 'lizard' }

  include Displayable
  def set_name
    n = ""
    loop do
      prompt("What's your name?")
      n = gets.chomp
      break unless n.strip.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      display_choices
      choice = gets.chomp.downcase
      break if Move::VALUES.include? choice
      if SHORTHAND_CHOICES.keys.include?(choice)
        choice = SHORTHAND_CHOICES[choice]
        break
      end
      puts "Sorry, invalid choice."
    end
    self.move = create_move(choice)
    update_moves_history(choice)
  end
end

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

# rpssl.rb
module Adaptable
  WEIGHT_MODIFIER = 5 # adjusts AI responsiveness to human moves (up == more)

  def modify_weights
    total_h_wins = human.won_with.values.sum
    Move::VALUES.each do |move|
      if human.won_with[move].fdiv(total_h_wins) >= 0.3
        computer.adjust_weights(Move::COUNTER_MOVES[move], WEIGHT_MODIFIER)
      end
    end
  end
end

class Score
  attr_accessor :human, :computer, :ties

  def initialize
    @human = { plays: 0, rounds: 0 }
    @computer = { plays: 0, rounds: 0 }
    @ties = 0
  end

  def round_winner?
    @human[:plays] >= RPSGame::WINNING_SCORE ||
      @computer[:plays] >= RPSGame::WINNING_SCORE
  end

  def round_reset
    @human[:plays] = 0
    @computer[:plays] = 0
    @ties = 0
  end
end

# Game Orchestration Engine
class RPSGame
  include Displayable, Adaptable, Enhanced
  attr_accessor :human, :computer, :score

  WINNING_SCORE = 5 # determines score to win a round

  def initialize
    clear_screen
    @human = Human.new
    @computer = Computer.new
    @score = Score.new
    @enhanced = nil
  end

  def increment_score
    h_move = human.move
    c_move = computer.move
    if h_move > c_move
      score.human[:plays] += 1
    elsif c_move > h_move
      score.computer[:plays] += 1
    else
      score.ties += 1
    end
  end

  def increment_round_wins
    if score.human[:plays] >= 5
      score.human[:rounds] += 1
    elsif score.computer[:plays] >= 5
      score.computer[:rounds] += 1
    end
  end

  def increment_winning_move
    h_move = human.move
    c_move = computer.move
    if h_move > c_move
      human.update_won_with(h_move.to_s)
    elsif c_move > h_move
      computer.update_won_with(c_move.to_s)
    end
  end

  def play_again?
    answer = nil
    loop do
      prompt("#{human.name}, would you like to play another round? (y/n)")
      answer = gets.chomp
      break if ['y', 'n'].include?(answer.downcase)
      puts "Sorry, must be y or n."
    end

    return true if answer.downcase == 'y'
    return false if answer.downcase == 'n'
  end

  def round_reset
    @computer = Computer.new
    human.init_won_with
  end

  def enter_to_continue
    prompt("Press enter to continue")
    gets.chomp
  end

  def set_enhanced_mode
    answer = nil
    puts "Enhanced mode provides additional information:"
    puts "- The percent chance of the Robot's next move."
    puts "- A log of the winning moves by each player."
    loop do
      puts "Would you like to use enhanced mode? (y/n)"
      answer = gets.chomp.downcase
      break if answer == 'y' || answer == 'n'
      puts "Sorry, invalid choice."
    end
    @enhanced = :on if answer == 'y'
    @enhanced = :off if answer == 'n'
  end

  def enhanced_visuals
    display_weights
    display_winning_moves
  end

  def pre_game
    clear_screen
    display_welcome_message
    score.round_reset
    display_rules
    round_reset
    display_cpu_personality
    describe_cpu_personality
    set_enhanced_mode
  end

  def human_turn
    clear_screen
    display_score
    human.choose
  end

  def computer_turn
    computer.update_weighted_moves
    computer.choose
  end

  def play_round
    loop do
      human_turn
      computer_turn
      clear_screen
      increment_winning_move
      increment_score
      display_score
      display_moves
      display_winner
      display_cpu_best_move
      modify_weights
      enhanced_visuals if @enhanced == :on
      break if score.round_winner?
      enter_to_continue
    end
  end

  def game
    loop do
      pre_game
      play_round
      increment_round_wins
      display_round_wins
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.game
