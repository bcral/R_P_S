pragma solidity >=0.4.21 <0.7.0;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Data {

    ////////////////////////////////// Globals ////////////////////////////////

    using SafeMath for uint256;


    // 'balance' is only the funds for the current open game
    uint256 balance;
    // 'bonusPool' is the total of all funds in the bonus pool
    uint256 bonusPool;
    // If contract is currently paused or not
    bool pauseStatus;
    // Currently set to the deployer address at migration
    address owner;
    // Shows if first move is made
    bool firstMove;
    // Shows if second move is made
    bool secondMove;
    // Mapping for storing winnings
    mapping(address => uint256) private winnings;

    constructor() 
        public 
        {
        balance = 0;
        bonusPool = 0;
        pauseStatus = false;
        owner = msg.sender;
        firstMove = false;
        secondMove = false;
        }

    ////////////////////////////////// Modifiers ////////////////////////////////

    // Sets the owner of the contract to the deployer.  Add more functionality
    // to add/remove authorized users, change owners, etc. if desired
    modifier requireOwner() {
        require(msg.sender == owner, "You're not the owner.  Go away.");
        _;
    }

    modifier requireUnpaused() {
        require(pauseStatus == false, "Contract is paused");
        _;
    }

    modifier requireMoney(uint256 amnt) {
        require(amnt >= 1 ether, "Are you going to pay for that?  Min. is 1 ETH");
        _;
    }

    modifier requireComplete() {
        require( (firstMove && secondMove) , "Game must be complete to call this");
        _;
    }

    modifier resetGame() {
        _;
        firstMove = false;
        secondMove = false;
    }

    ////////////////////////////////// Utilities ////////////////////////////////

    // Checks if contract is paused
    function isPaused() 
        public 
        view 
        returns(bool) 
        {
            return pauseStatus;
        }

    // Pauses/unpauses the contract - Set to only be modified by deployer
    function setPauseStatus(bool status)
        external
        requireOwner 
        {
            pauseStatus = status;
        }

    // Adds funds to the bonus pool, in case they somehow run dry
    // INCLUDE TRANSACTION
    function addFunds() 
        external
        payable
        requireMoney(msg.value)
        {
            bonusPool.add(msg.value);
        }

    // Getter that returns contract balance
    function getBalance()
        external
        view
        returns(uint256)
        {
            return address(this).balance;
        }

    // Getter that returns bonus pool balance
    function getBonusPool()
        external
        view
        returns(uint256)
        {
            return bonusPool;
        }

    function checkMove()
        external
        view
        returns(bool)
        {
            return firstMove;
        }

    ///////////////////////////////// Functionality ///////////////////////////////

    function setBet()
        external
        payable
        requireUnpaused
        requireMoney(msg.value)
        {
            // increase balance by incoming amount
            balance += msg.value;
            // set move depending on where the current status is
            if (firstMove) {
                move2();
            } else if (!firstMove) {
                move1();
            }
        }

    function move1()
        private
        requireUnpaused
        {
            firstMove = true;
        }

    function move2()
        private
        requireUnpaused
        {
            secondMove = true;
        }

    function win(address _address)
        external
        requireUnpaused
        requireComplete
        resetGame
        {
            // Credit current balance to winner DO NOT transfer
            winnings[_address].add(balance);
            // If bonus is available, add that as well
            if (bonusPool >= 1 ether) {
                // Sets bonus payout to 25% of bonus pool
                uint256 bonusPlaceholder = bonusPool;
                bonusPool = 0;
                uint256 bonusPayout = bonusPlaceholder.div(4);
                // Add bonus to the player's winnings
                winnings[_address].add(bonusPayout);
                // Set bonusPool to new value
                bonusPool = bonusPlaceholder.sub(bonusPayout);
            }
        }

    // Function for determining what happens with the funds if there is a draw
    // 50% is returned to the players(split evenly), and 50% is added to the bonus pool
    function draw(address _address1, address _address2)
        external
        requireUnpaused
        requireComplete
        resetGame
        {
            // Use SafeMath to devide balance in half
            uint256 split = balance.div(2);
            // Send half of the balance to bonusPool
            balance = 0;
            bonusPool.add(split);
            // Split remaining half of balance in half again
            uint256 payout = split.div(2);
            // Credit half to each argument addresss
            winnings[_address1].add(payout);
            winnings[_address2].add(payout);
        }

    ///////////////////////////////// Fallback ///////////////////////////////
    function() 
        external
        payable
        {
            //Since we all need that payable fallback function...
        }
}