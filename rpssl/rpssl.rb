# rpssl.rb
require_relative 'displayable'
require_relative 'player'
require_relative 'human'
require_relative 'computer'
require_relative 'moves'

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
    @computer[:plays] = 0r
    @ties = 0
  end
end

# Game Orchestration Engine
class RPSGame
  include Displayable, Adaptable, Enhanced
  attr_accessor :human, :computer, :score

  WINNING_SCORE = 5 # determines score to win a round
  ENHANCED = :on # set to :on to show enhanced visuals

  def initialize
    clear_screen
    @human = Human.new
    @computer = Computer.new
    @score = Score.new
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
    prompt_cpu_personality
    display_cpu_personality
    enter_to_continue
  end

  def human_turn
    clear_screen
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
      display_moves
      increment_winning_move
      display_winner
      increment_score
      display_score
      display_cpu_best_move
      modify_weights
      enhanced_visuals if ENHANCED == :on
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
