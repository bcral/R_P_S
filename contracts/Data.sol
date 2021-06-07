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
    address private owner;
    // The Logic contract's address
    // Set to single address instead of array - one logic contract at a time
    address public authLogic;
    // Boolean for setting/checking if a game is currently open
    bool public openGame;
    // Mapping for storing winnings
    // Possibility for future expansion - Use this store of funds for betting
    mapping(address => uint256) private winnings;

    constructor() 
        public 
        {
        balance = 0;
        bonusPool = 0;
        pauseStatus = false;
        owner = msg.sender;
        openGame = false;
        }

    ////////////////////////////////// Modifiers ////////////////////////////////

    // Sets the owner of the contract to the deployer.  Add more functionality
    // to add/remove authorized users, change owners, etc. if desired
    modifier requireOwner() {
        require(msg.sender == owner, "You're not the owner.  Go away.");
        _;
    }

    // Checks that the sender is the approved logic file
    modifier requireAuthLogic() {
        require(msg.sender == authLogic, "You're not the Logic for this Data.");
        _;
    }

    modifier requireUnpaused() {
        require(pauseStatus == false, "Contract is paused");
        _;
    }

    modifier requireMoney(uint256 amnt) {
        require(amnt == 1 ether, "Are you going to pay for that?  Min. is 1 ETH");
        _;
    }

    modifier requireWinnings(address _address) {
        require(winnings[_address] > 0, "You don't have any winnings stored here.");
        _;
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

    // Pauses/unpauses the contract - Set to only be modified by deployer
    function setAuthLogic(address newLogicContract)
        external
        requireOwner 
        {
            authLogic = newLogicContract;
        }

    // Adds funds to the bonus pool, in case they somehow run dry, and someone wants
    // to top it off to insentivise players
    function addFunds() 
        external
        payable
        requireMoney(msg.value)
        {
            bonusPool.add(msg.value);
        }

    function getOwner()
        external
        view
        returns(address)
        {
            return owner;
        }

    // Getter function for testing the connection between contracts
    function getAuthLogic()
        external
        view
        requireOwner
        returns(address)
        {
            return authLogic;
        }

    // Checks if there is currently a game open(first move played) or not
    function isOpen() 
        external
        view
        returns(bool) 
        {
            return openGame;
        }

    // Getter that returns contract balance
    function getBalance()
        external
        view
        returns(uint256)
        {
            return balance;
        }

    // For checking contract balance in testing
    function dataBalance()
        external
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

    ///////////////////////////////// Functionality ///////////////////////////////

    // Sets the status of the game - if true, first move was played.  If false,
    // there is currently not an open game, because the playing of the second move
    // resolved the game
    function setGame(bool game) 
        external
        requireAuthLogic
        requireUnpaused
        {
            openGame = game;
        }
    
    function addToBonus(uint256 bonus)
        external
        requireAuthLogic
        requireUnpaused
        {
            // Subtract the value to be added to bonusPool from balance
            balance = balance.sub(bonus);
            // Add value to bonusPool
            bonusPool = bonusPool.add(bonus);
        }

    function bonusPayout(uint256 payout)
        external
        requireAuthLogic
        requireUnpaused
        {
            // Subtract value that was paid out to winnings from the bonusPool
            bonusPool = bonusPool.sub(payout);
        }

    function addWinnings(address winner, uint256 winning)
        external
        requireAuthLogic
        requireUnpaused
        {
            // Subtract the winning amount from balance
            balance = balance.sub(winning);
            // Credit winner's account with winning amount
            winnings[winner] = winnings[winner].add(winning);
        }
    
    function fund()
        external
        payable
        requireAuthLogic
        requireUnpaused
        {
            balance = balance.add(msg.value);
        }

    function checkWinnings(address _address)
        public
        requireUnpaused
        requireWinnings(_address)
        returns(uint256)
        {
            return winnings[_address];
        }

    function withdraw(address _address)
        public
        requireUnpaused
        requireWinnings(_address)
        {

        }

    ///////////////////////////////// Fallback ///////////////////////////////
    function() 
        external
        payable
        {
            //Since we all need that payable fallback function...
        }
}