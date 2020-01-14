# displayable.rb
module Displayable
  require 'yaml'

  def prompt(message)
    puts "==> #{message}"
  end

  def clear_screen
    system('clear') || system('cls')
  end

  def display_rules
    rules = YAML.load_file('rules.yml')
    puts "The first to #{RPSGame::WINNING_SCORE} wins the round.\n\n"
    puts rules
    puts "\n"
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Spock, Lizard!\n\n"
  end

  def display_goodbye_message
    puts "Thanks for playing Rock, Paper, Scissors, Spock, Lizard. Goodbye!"
  end

  def display_choices
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
      puts "It's a tie!"
    end
  end

  def display_score
    hn = human.name
    hs = score.human[:plays].to_i
    cn = computer.name
    cs = score.computer[:plays].to_i

    puts "\nScoreboard:"
    print_in_box("#{hn}: #{hs} <> #{cn}: #{cs} <> Ties: #{score.ties}")
  end

  def display_round_wins
    puts "\nRound Wins:\n"
    puts "#{human.name}: #{score.human[:rounds]}"
    puts "ROBOTS: #{score.computer[:rounds]}"
    puts
  end

  def display_cpu_best_move
    wins = computer.won_with
    best = wins.values.sort.pop
    puts
    puts "#{computer.name} really likes using #{wins.key(best)}!" if best > 1
    puts
  end

  def prompt_cpu_personality
    puts "In this round, you will battle: #{computer.name}"
  end

  def display_cpu_personality
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
