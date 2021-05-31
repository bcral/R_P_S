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
    Data data;
    // Sets owner privilages
    address private owner;

    // Game info
    address player1;
    address player2;
    uint8 play1;
    uint8 play2;
    uint256 bet;

    constructor(address dataContract) 
        public 
        {
        owner = msg.sender;
        data = Data(dataContract);
        }

    ////////////////////////////////// Modifiers ////////////////////////////////

    modifier checkValue() {
        require(msg.value == requiredBet());
        _;
    }

    modifier requireMoney() {
        require(msg.value >= 1 ether, "Are you going to pay for that?  Min. is 1 ETH");
        _;
    }

    modifier requireUnpaused() {
        require(isPaused() == false, "Contract is paused");
        _;
    }

    modifier checkPlay(uint8 play) {
        require((play >= 0) && (play <= 2));
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

    function requiredBet()
        public
        view
        returns(uint256)
        {
            return data.getBalance();
        }


    ////////////////////////////////// Functionality ////////////////////////////////

    function play(uint8 playerMove)
        public
        payable
        requireUnpaused
        requireMoney
        checkPlay(playerMove)
        {
            // If there is a current game...
            if (data.checkMove()) {
                require(msg.value == bet);
                player2 = msg.sender;
                play2 = playerMove;
                data.setBet(msg.value);
                // Run function to check who on.
                checkWinner();
            // If there is NOT a current game...
            } else {
                player1 = msg.sender;
                play1 = playerMove;
                bet = msg.value;
                data.setBet(msg.value);
            }
        }

    // How to test who won:
    // Increment one of the plays by 1.  If it then equals the same as the other
    // person's play, then it wins(because each one beats the next in the cycle)
    // If a winner still isn't found, increment the other person's play by one, and
    // repeat the check.

    function compare(uint8 a, uint8 b)
        private
        returns(bool)
        {
            // increment a by 1
            a++;
            // if a + 1 = 3, then loop it around the cycle to be 0
            if (a >= 3) {
                a = 0;
            }
            // compare a to b.  If a = b, a is the winner - return true
            if (a == b) {
                return true;
            // else return false - no winner is determined
            } else {
                return false;
            }
        }

    function checkWinner()
        private
        {
            if (play1 == play2) {
                // it's a draw!
                // return 50% of funds to both players
                data.draw(player1, player2);
            }
            else if (compare(play1, play2)) {
                // Player1 wins
                data.win(player1);
            }
            else if (compare(play2, play1)) {
                // Player2 wins
                data.win(player2);
            }
            clear();
        }

    function clear()
        private
        {
            player1 = address(0);
            player2 = address(0);
        }
    
}

contract Data {
    function isPaused() public view returns(bool);
    function getBalance() external view returns(uint256);
    function setBet(uint256) external;
    function checkMove() external returns(bool);
    function win(address) external;
    function draw(address, address) external;
}