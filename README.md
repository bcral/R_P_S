This is a simple Rock-Paper-Scissors game built with Solidity on the Ethereum platform.  Built with the truffle drizzle-vue-box boilerplate.

The front end is incomplete.  Will update if it is made functional.

Contracts and tests are complete, and should run as expected.

Game overview(user perspective):

The user inputs a move(rock, paper, or scisors) and a bet(currently set to 1 ETH)

    -Player's move is converted to a number representative of the choice.  0 = paper, 1 = rock, 2 = scissors.  This order is important in how the game is checked and resolved.

    -Player's bet is stored in the Data contract until the player chooses to withdraw their winnings.  Funds are not able to be withdrawn until the game they are used in is resolved.  The players currently can NOT use previous winnings to bet without withdrawing them first.

The user then waits for the next move to be made.  The outcome will be 1 of 3 possibilities:

    -Draw - both players played the same move(ex. player 1 and 2 both played 'rock', represented as '1' in the contract).  A draw outcome sends 50% of the funds from the game(currently 1 ETH) to a bonus pool, and returns the remainder to the players.  Players recieve 50% payback for the draw.

    -Loss - player looses to the other player.  Player recieves no funds back from the game, and nothing is added to the bonus pool.

    -Win - player wins 100% of funds bet on the game(currently 2 ETH) plus 25% of the total bonus pool(if the pool contains at least 1 ETH)

With the practical odds of each outcome being 1 in 3, the bonus pool should continue to grow as players keep resulting in draws.  Of course, as it grows, and winnings become larger, there is incentive to steal the bonus.  All that was implemented to prevent this is not allowing the same address to play as both players.

