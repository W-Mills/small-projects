module Displayable
  protected

  def welcome_message
    puts "Welcome to Bond Villain Twenty-One!"
    puts "\nThis is a high-stakes game:"
    puts "The first to #{TwentyOne::ROUND_WINS_TO_END} round wins survives"
    puts "Otherwise it's GAME OVER"
    puts
    puts "The distance between insanity and genius is measured only by success"
    puts "\n"
  end

  def goodbye_message
    puts
    if grand_winner == human
      puts "No, #{human.name}! I expect you to die!"
      puts "Goodbye for now...\n\n"
      return nil
    end
    puts "This time, #{human.name}, the pleasure will be all mine!"
    puts "(Lazer begins slowly moving towards #{human.name})"
    puts "\nGAME OVER\n\n"
  end

  def display_end_game
    display_grand_winner
    goodbye_message
  end

  def display_grand_winner
    print_in_box("=====> #{grand_winner.name} is the grand winner! <=====")
  end

  def prompt(msg)
    puts "==> #{msg}"
  end

  def show_initial_cards
    human.show_hand
    dealer.show_initial_hand
  end

  def show_all_cards
    human.show_hand
    dealer.show_hand
  end

  def player_ui
    clear
    display_score
    show_initial_cards
  end

  def dealer_ui
    clear
    display_score
    show_all_cards
  end

  def clear
    system('clear') || system('cls')
  end

  def enter_to_continue
    prompt("Press enter to continue...")
    gets.chomp
  end

  def show_round_result
    if tie?
      print_in_box("=====> It was a tie <=====")
    else
      print_in_box("=====> #{determine_winner.name} wins! <=====")
      puts
    end
  end

  def display_score
    human_info = "#{human.name}: #{human.wins} <> "
    dealer_info = "#{dealer.name}: #{dealer.wins} <> "
    tie_info = "Ties: #{human.ties}"
    puts "Scoreboard:"
    print_in_box(human_info + dealer_info + tie_info)
    puts ""
  end

  def print_in_box(text)
    txt = box_text(text)
    horizontal_rule = "+#{'-' * (txt.length + 2)}+"
    empty_line = "|#{' ' * (txt.length + 2)}|"

    puts horizontal_rule
    puts empty_line
    puts "| #{txt} |"
    puts empty_line
    puts horizontal_rule
  end

  def box_text(text)
    if text.length > 76
      text[0..75]
    else text
    end
  end
end

module Hand
  def show_hand
    puts "#{name}'s hand:"
    hand.each do |card|
      puts card.to_s
    end
    puts ""
    prompt "(Total = #{total})"
    puts ""
  end

  def total
    total = 0
    hand.each do |card|
      total += case card.face
               when "Jack" then 10
               when "Queen" then 10
               when "King" then 10
               when "Ace" then 11
               else card.to_i
               end
    end
    total = correct_aces(total)
  end

  def correct_aces(subtotal)
    hand.each do |card|
      break if subtotal <= TwentyOne::BUST_IF_OVER
      subtotal -= 10 if card.face == "Ace"
    end
    subtotal
  end
end

class Participant
  include Hand, Displayable
  attr_accessor :name, :hand, :wins, :ties

  VALID_HIT_RESPONSES = ['hit', 'h']
  VALID_STAY_RESPONSES = ['stay', 's']

  def initialize
    set_name
    @hand = []
    @wins = 0
    @ties = 0
  end

  def hit(card)
    hand << card
  end

  def stay
    puts "(#{name} stays with a hand value of #{total})\n\n"
    enter_to_continue
  end

  def busted?
    total > TwentyOne::BUST_IF_OVER
  end
end

class Player < Participant
  def set_name
    name = ''
    loop do
      prompt "What's your name?"
      puts "Names is for tombstones, baby"
      name = gets.chomp
      break unless name.strip.empty?
      puts "Invalid entry, name can't be blank"
    end
    self.name = name
  end

  def hit_or_stay_choice
    answer = nil
    loop do
      puts "Would you like to hit or stay? Shortcuts: (h/s)"
      answer = gets.chomp.downcase
      return :hit if VALID_HIT_RESPONSES.include?(answer)
      return :stay if VALID_STAY_RESPONSES.include?(answer)
      puts "Invalid response, enter 'H' to hit, or 'S' to stay."
    end
  end
end

class Dealer < Participant
  DEALER_NAMES = ["Goldfinger", "Oddjob", "Jaws", "Boris", "006", "Dr. No"]

  def set_name
    self.name = DEALER_NAMES.sample
  end

  def show_initial_hand
    puts "#{name}'s hand:"
    puts hand.first.to_s
    puts ""
    prompt "(Total = ?)"
    puts ""
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    Card::SUITS.each do |suit|
      Card::UNSUITED_CARDS.each do |face|
        @cards << Card.new(suit, face)
      end
    end
    @cards.shuffle!
  end

  def deal_card
    cards.pop
  end

  def to_s
    cards
  end
end

class Card
  attr_accessor :suit

  UNSUITED_CARDS = %w[Ace 2 3 4 5 6 7 8 9 10 Jack Queen King]
  SUITS = [:C, :H, :D, :S]

  def initialize(suit, face)
    @suit = suit
    @face = face
  end

  def to_s
    "#{face} of #{suit}"
  end

  def to_i
    face.to_i
  end

  def suit
    case @suit
    when :C then "Clubs"
    when :H then "Hearts"
    when :D then "Diamonds"
    when :S then "Spades"
    end
  end

  def face
    case @face
    when "Ace" then "Ace"
    when "Jack" then "Jack"
    when "Queen" then "Queen"
    when "King" then "King"
    else @face
    end
  end
end

module GameMechanics
  protected

  def tie?
    human.busted? && dealer.busted? || human.total == dealer.total
  end

  def busted
    clear
    display_score
    show_initial_cards if current_player == human
    show_all_cards if current_player == dealer
    print_in_box("=====> #{current_player.name} BUSTED!! <=====")
    puts ""
    enter_to_continue
  end

  def deal_starting_hands
    2.times do
      human.hit(deck.deal_card)
      dealer.hit(deck.deal_card)
    end
  end

  def update_score
    if tie?
      human.ties += 1 && dealer.ties += 1
    elsif determine_winner == human
      human.wins += 1
    elsif determine_winner == dealer
      dealer.wins += 1
    end
  end

  def grand_winner
    return human if human.wins >= TwentyOne::ROUND_WINS_TO_END
    return dealer if dealer.wins >= TwentyOne::ROUND_WINS_TO_END
  end

  def determine_winner
    return dealer if human.busted?
    return human if !human.busted? && dealer.busted?
    higher_value_hand
  end

  def higher_value_hand
    if human.total > dealer.total
      human
    elsif dealer.total > human.total
      dealer
    end
  end
end

class TwentyOne
  include Displayable, GameMechanics
  attr_accessor :human, :dealer, :deck, :current_player

  BUST_IF_OVER = 21
  DEALER_STOPS_AT = 17
  ROUND_WINS_TO_END = 1

  def initialize
    clear
    welcome_message
    @human = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def start
    loop do
      @current_player = human
      deal_starting_hands
      clear
      display_score
      show_initial_cards
      player_turn
      player_stay_message_if_21
      dealer_turn
      post_round
      break if grand_winner
      reset_round
    end
    display_end_game
  end

  protected

  def player_turn
    choice = nil
    loop do
      break if human.total == 21
      choice = human.hit_or_stay_choice
      player_hit(choice)
      if human.busted?
        busted
        break
      end
      if choice == :stay
        human.stay
        break
      end
      player_ui
    end
  end

  def player_stay_message_if_21
    human.stay if human.total == 21
  end

  def player_hit(choice)
    human.hit(deck.deal_card) if choice == :hit
  end

  def stay_if_twenty_one
    human.stay if human.total == 21
  end

  def dealer_turn
    self.current_player = dealer
    loop do
      dealer_ui
      if dealer.busted?
        busted
        break
      end
      if dealer.total < DEALER_STOPS_AT && !human.busted?
        dealer_hit
      else
        dealer_stays
        break
      end
    end
  end

  def dealer_hit
    dealer.hit(deck.deal_card)
    puts "#{dealer.name} decides to hit!\n\n"
    enter_to_continue
  end

  def dealer_stays
    puts "(#{dealer.name} stays with a hand value of #{dealer.total})\n\n"
  end

  def post_round
    update_score
    show_round_result
    enter_to_continue
  end

  def reset_round
    clear
    @deck = Deck.new
    dealer.hand = []
    human.hand = []
  end
end

game = TwentyOne.new
game.start
