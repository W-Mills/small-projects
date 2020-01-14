module Displayable
  def clear_screen_and_display_board
    clear
    display_board
  end

  def display_score
    puts ""
    puts("SCORE:

    #{human.name}: #{human.score}
    #{computer.name}: #{computer.score}
    ")
  end

  def clear
    system('clear') || system('cls')
  end

  def enter_to_continue
    puts "Press enter to continue"
    gets.chomp
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "======> #{human.name} won! <======"
    when computer.marker
      puts "======> #{computer.name} won! <======"
    else
      puts "======> It's a tie! <======"
    end
  end

  def display_welcome_message
    puts "Welcome to Tic Tac Toe"
    puts ""
    puts "The first to #{TTTGame::NUM_ROUNDS_TO_WIN} wins!"
    puts ""
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye #{human.name}!"
    puts ""
  end

  def display_board
    puts "You are a #{human.marker}. Computer is a #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end
end

class Board
  attr_reader :squares

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] + # cols
                  [[1, 5, 9], [3, 5, 7]] # diagonals

  def initialize
    @squares = {}
    reset
  end

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def winning_marker
    WINNING_LINES.each do |line|
      squares = @squares.values_at(*line)
      if three_identical_markers?(squares)
        return squares.first.marker
      end
    end
    nil
  end

  # rubocop:disable Metrics/AbcSize
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize

  private

  def three_identical_markers?(squares)
    markers = squares.select(&:marked?).map(&:marker)
    return false if markers.size != 3
    markers.uniq.size == 1
  end
end

class Square
  INITIAL_MARKER = " "

  attr_accessor :marker

  def initialize(marker=INITIAL_MARKER)
    @marker = marker
  end

  def marked?
    marker != INITIAL_MARKER
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_reader :marker
  attr_accessor :score

  def initialize(marker)
    @marker = marker
    @score = 0
  end

  def set_name
    name = nil
    loop do
      name = gets.chomp
      break if name.strip != ""
      puts "Invalid name, blanks are not allowed"
    end
    self.name = name
  end

  def set_computer_name
    puts "Please enter the name of your computer opponent:"
    set_name
  end

  def set_human_name
    puts "Please enter your name:"
    set_name
  end
end

class Computer < Player
  attr_accessor :name

  def initialize(marker)
    super
    set_computer_name
  end
end

class Human < Player
  attr_accessor :name

  def initialize(marker)
    super
    set_human_name
  end
end

class TTTGame
  CPU_MARKER_OPTIONS = ["X", "O", "#", "@", "&", "*", "?", "$"]
  NUM_ROUNDS_TO_WIN = 5

  attr_reader :board, :human, :computer
  attr_accessor :human_marker, :computer_marker, :first_to_move

  def initialize
    choose_human_marker
    set_computer_marker
    @board = Board.new
    @human = Human.new(human_marker)
    @computer = Computer.new(computer_marker)
    @first_to_move = @human_marker
    @current_marker = first_to_move
  end

  def choose_human_marker
    choice = nil
    clear
    loop do
      puts "Choose your marker: (typically X or O)"
      choice = gets.chomp
      break if choice.length == 1
      puts "Invalid choice, choice must be a single character"
    end
    @human_marker = choice
  end

  def set_computer_marker
    markers_left = CPU_MARKER_OPTIONS.reject { |mrkr| mrkr == @human_marker }
    @computer_marker = markers_left.sample
  end

  def play_round
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
      display_score
    end
  end

  def post_round
    update_score
    display_result
    display_score
    enter_to_continue
  end

  def play
    clear
    display_welcome_message
    loop do
      loop do
        display_board
        play_round
        post_round
        break if round_winner?
        round_reset
        display_play_again_message
      end
      break unless play_again?
      game_reset
    end
    display_goodbye_message
  end

  private

  include Displayable

  def round_winner?
    human.score >= 5 || computer.score >= 5
  end

  def update_score
    case board.winning_marker
    when human.marker
      human.score += 1
    when computer.marker
      computer.score += 1
    end
  end

  def game_reset
    human.score = 0
    computer.score = 0
    round_reset
    display_play_again_message
  end

  def joinor(arr, delimiter=', ', word='or')
    case arr.size
    when 0 then ''
    when 1 then arr.first
    when 2 then arr.join(" #{word} ")
    else
      arr[-1] = "#{word} #{arr.last}"
      arr.join(delimiter)
    end
  end

  def human_moves
    puts "Choose a square: (#{joinor(board.unmarked_keys)})"
    square = nil
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = @computer_marker
    else
      computer_moves
      @current_marker = @human_marker
    end
  end

  def human_turn?
    @current_marker == @human_marker
  end

  def computer_moves
    move = computer_attack if computer_attack
    move = computer_defend unless move
    move = computer_take_five unless move
    move = computer_random_move unless move
    board[move] = computer.marker
  end

  def computer_random_move
    board.unmarked_keys.sample
  end

  def computer_attack
    computer_best_play(computer)
  end

  def computer_defend
    computer_best_play(human)
  end

  def computer_take_five
    5 if board.squares[5].unmarked?
  end

  def computer_best_play(attacker)
    initial_marker = Square::INITIAL_MARKER
    squares = board.squares
    Board::WINNING_LINES.each do |line|
      if squares.values_at(*line).map(&:to_s).count(attacker.marker) == 2 &&
         squares.values_at(*line).map(&:to_s).count(initial_marker) == 1
        line.select do |square|
          return square if board.squares[square].unmarked?
        end
      end
    end
    nil
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w[y n].include?(answer)
      puts "Sorry, must be y or n"
    end

    answer == 'y'
  end

  def round_reset
    board.reset
    @current_marker = first_to_move
    clear
  end
end

game = TTTGame.new
game.play
