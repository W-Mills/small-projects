README

This is a simple text-based game of Rock, Paper, Scissors with the additional movesets of Spock and Lizard.
It's based on the game created by Sam Kass and Karen Bryla (http://www.samkass.com/theories/RPSSL.html).

Within the rpssl.rb file, adjust these constants to modify the game:

WINNING_SCORE = n (default = 5)
  - set n to any positive integer to adjust the required number of wins to win a round

ENHANCED = :on || :off (default = :on)

  - set to :on to enable enhanced visuals during gameplay
  - set to :off to disable enhanced visuals 

WEIGHT_MODIFIER = n (default = 5)
  - set n to any positive integer to adjust the AI responsiveness to human winning moves (a higher number makes the AI more responsive).
  - WEIGHT_MODIFIER kicks in at the end of each round if any human move accounts for greater than 30% of human wins within a round
  - WEIGHT_MODIFIER works by increasing the number of counter-moves to any of the preferred winning moves of the human
    -computer personality 'Wintermute' is heavily reliant on this mechanic

Within the computer.rb file, adjust this constant to modify the game:

PERSONALITY_BOOST = n (default = 30)
 - set n to any positive integer to alter the default personality boost of each computer personality. Default weighting is 20 out of 100 for each of the five possible moves. 
  - e.g. if PERSONALITY_BOOST = 30, then T800 which favours rock will have the base chance of 20 + the added boost of 30 to have a weighting of 50 for rock in a pool of (100 + 30) move options (boosted to a 38% chance, up from 20%). 