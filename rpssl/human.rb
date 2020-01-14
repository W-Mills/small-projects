# human.rb
class Human < Player
  SHORTHAND_CHOICES = { 1 => 'rock',
                        2 => 'paper',
                        3 => 'scissors',
                        4 => 'spock',
                        5 => 'lizard' }

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
      if SHORTHAND_CHOICES.keys.include?(choice.to_i)
        choice = SHORTHAND_CHOICES[choice.to_i]
        break
      end
      puts "Sorry, invalid choice."
    end
    self.move = create_move(choice)
    update_moves_history(choice)
  end
end
