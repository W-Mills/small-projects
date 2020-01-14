OOP Twenty-One is a James Bond themed text-based card game of based on blackjack written in object-oriented style. 
This version was coded as an assignment for the course RB120 for Launch School.

The following constants can be adjusted to alter gameplay:

TwentyOne::BUST_IF_OVER = (default = 21) # Set the number above which the players will bust.
TwentyOne::DEALER_STOPS_AT = 17 (default = 17) # Set the hand value above which the dealer will stay.
TwentyOne::ROUND_WINS_TO_END = 5 (default = 5) # Sets the number of round wins required to win the game.

Dealer::DEALER_NAMES = (default = ["Goldfinger", "Oddjob", "Jaws", "Boris", "006", "Dr. No"] )
  - Set to an array containing strings which are randomly sampled to create the dealer's name.
  
Thanks to [SuperheroSith](https://www.mi6community.com/discussion/4505/classic-bond-villain-quotes) for the classic James Bond villain quotes.
