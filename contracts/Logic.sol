pragma solidity >=0.4.21 <0.7.0;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Logic {

    ////////////////////////////////// Globals ////////////////////////////////

    using SafeMath for uint256;

    // Game play variable funcitonality:
    // Plays are numbered 0 - 2
    // Paper = 0,
    // Rock = 1,
    // Scissors = 2
    // Each one beats the next one in the sequence.  Paper beats rock, rock beats
    // scissors, etc.

    // Configure Data contract
    iData data;
    // Sets owner privilages
    address private owner;

    // Game info
    address player1;
    address player2;
    uint8 play1;
    uint8 play2;

    constructor(address payable dataContract) 
        public 
        {
        owner = msg.sender;
        data = iData(dataContract);
        }

    ////////////////////////////////// Modifiers ////////////////////////////////

    // In case you need owner control for additional functionality
    modifier requireOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier requireMoney() {
        // Should be able to change this amount to anything
        require(msg.value == 1 ether, "Are you going to pay for that?  Required bet is 1 ETH");
        _;
    }

    modifier requireUnpaused() {
        require(isPaused() == false, "Contract is paused");
        _;
    }

    modifier checkPlay(uint8 play) {
        require((play >= 0) && (play <= 2), "Invalid play - input must be 0 - 2");
        _;
    }

    ////////////////////////////////// Utilities ////////////////////////////////

    function isPaused() 
        public
        view
        returns(bool)
        {
            return data.isPaused();
        }

    ////////////////////////////////// Functionality ////////////////////////////////

    // Main function for initiating and completing a game
    function play(uint8 playerMove)
        public
        payable
        requireUnpaused
        requireMoney
        checkPlay(playerMove)
        {
            bool gameStatus = data.isOpen();
            // If there is a current game...
            if (gameStatus) {
                player2 = msg.sender;
                play2 = playerMove;
                // Sends funds to Data contract for storage
                data.fund.value(msg.value)();
                // Resets game status to false
                data.setGame(false);
                // Run function to check who won.
                checkWinner();
            // If there is NOT a current game...
            } else {
                player1 = msg.sender;
                play1 = playerMove;
                // Sets status of game in Data contract
                data.setGame(true);
                // Sends funds to Data contract for storage
                data.fund.value(msg.value)();
            }
        }

    // How to test who won:
    // Paper == 0, Rock == 1, Scissors == 2.
    // Increment one of the plays by 1.  If it then equals the same as the other
    // person's play, then it wins(because each one beats the next in the looping 
    // cycle). If a winner still isn't found, increment the other person's play by 
    // one, and repeat the check.

    function compare(uint8 a, uint8 b)
        private
        requireUnpaused
        returns(bool result)
        {
            // increment a by 1
            a++;
            // if a + 1 = 3, then loop it around the cycle to be 0
            if (a > 2) {
                a = 0;
            }
            // ternary for cleaning up the return syntax
            return a == b ? true : false;
        }

    // Check function for determining the winner and calling the function to allocate
    // funds to the winner in the Data contract
    function checkWinner()
        private
        requireUnpaused
        {
            if (play1 == play2) {
                // it's a draw!
                // return 50% of funds to both players
                draw(player1, player2);
            }
            else if (compare(play1, play2)) {
                // Player1 wins
                win(player1);
            }
            else if (compare(play2, play1)) {
                // Player2 wins
                win(player2);
            }
            clear();
        }

    // Function for transferring funds to winner's 'winnings' mapping in Data contract
    function win(address _address)
        private
        requireUnpaused
        {
            // Get current bet balance from Data contract
            // Dont credit just yet - wait for bonus calculation.  This should
            // reduce gas, but potentially introduce security risks
            uint256 payout = data.getBalance();
            // If bonus is available, add that as well
            uint256 bonus = data.getBonusPool();
            uint256 bonusPay;

            if (bonus >= 1 ether) {
                // Sets bonus payout to 25% of bonus pool
                uint256 bonusPlaceholder = bonus;
                bonus = 0;
                bonusPay = bonusPlaceholder.div(4);
                // Set bonusPool in Data contract to new value
                data.bonusPayout(bonusPay);
            }

            // Credit current payout to winner
            data.addWinnings(_address, payout, bonusPay);
        }

    // Function for determining what happens with the funds if there is a draw
    // 50% is returned to the players(split evenly), and 50% is added to the bonus pool
    function draw(address _address1, address _address2)
        private
        requireUnpaused
        {
            uint256 balance = data.getBalance();
            // Use SafeMath to devide balance in half
            uint256 split = balance.div(2);
            // Send half of the balance to bonusPool
            balance = 0;
            data.addToBonus(split);
            // Split remaining half of balance in half again
            uint256 payout = split.div(2);
            // Credit half to each argument addresss
            data.addWinnings(_address1, payout, 0);
            data.addWinnings(_address2, payout, 0);
        }

    function clear()
        private
        {
            // Reset addresses to defaults for safety
            player1 = address(0);
            player2 = address(0);
        }
    
}

contract iData {
    function isPaused() external view returns(bool);
    function isOpen() external view returns(bool);
    function setGame(bool) external;
    function getBalance() external view returns(uint256);
    function getBonusPool() external view returns(uint256);
    function fund() external payable;
    function addWinnings(address, uint256, uint256) external;
    function addToBonus(uint256) external;
    function bonusPayout(uint256) external;
}