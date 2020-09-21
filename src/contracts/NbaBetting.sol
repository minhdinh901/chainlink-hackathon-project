pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

contract NbaBetting is ChainlinkClient {
    uint8 private MAX_GAMES = 3; //Only 3 future games to bet on
    uint8 private GAME_OFFSET = 10;
    uint private MAX_DEPOSIT = 999999;

    string public name = "NBA Betting Simulator";
    address public owner;
    IERC20 public nbaToken;

    address[] public betters;
    mapping(address => uint) public nbaTokenBalance;
    mapping(address => bool) public hasBetted;
    mapping(address => uint8) public gamesBetted;
    mapping(address => uint8) public teamsBetted;
    mapping(address => uint) public betAmount1;
    mapping(address => uint) public betAmount2;
    mapping(address => uint) public betAmount3;

    constructor(IERC20 _nbaTokenAddress) public {
        nbaToken = IERC20(_nbaTokenAddress);
        owner = msg.sender;
    }

    /*function getGame() public {

    }*/

    /* Allow users to deposit or withdraw NbaTokens */
    function depositOrWithdraw(uint _amount) public {
        require(_amount >= (uint(-1) * nbaTokenBalance[msg.sender]), 
                "Cannot withdraw more than account balance");
        require(_amount <= MAX_DEPOSIT, "Cannot deposit more than 999999");
        require(_amount != 0, "Cannot withdraw or deposit 0");

        //Deposit
        if(_amount > 0){
            nbaToken.transferFrom(msg.sender, address(this), _amount);
        }

        //Withdraw
        if(_amount < 0){
            nbaToken.transfer(msg.sender, _amount);
        }

        nbaTokenBalance[msg.sender] = nbaTokenBalance[msg.sender] + _amount;
    }

    /* Allow users to place bets */
    function placeBet(uint8 _game, uint8 _team, uint _amount) public {
        require(_game >= 0 && _game < MAX_GAMES, "Choose a valid game");
        require(_team == 0 || _team == 1, "Choose a valid team");
        require(_amount > 0, "Must bet an amount greater than 0");

        //Transfer tokens from user
        nbaTokenBalance[msg.sender] = nbaTokenBalance[msg.sender] - _amount;

        //Update relevant attributes of user
        gamesBetted[msg.sender] = gamesBetted[msg.sender] 
                                  + (GAME_OFFSET * _game);
        teamsBetted[msg.sender] = teamsBetted[msg.sender] 
                                  + (_team * GAME_OFFSET * _game);
        if(_game == 0){
            betAmount1[msg.sender] = _amount;
        }else if(_game == 1){
            betAmount2[msg.sender] = _amount;
        }else{
            betAmount3[msg.sender] = _amount;
        }

        //Add user to betters array
        if(!hasBetted[msg.sender]){
            betters.push(msg.sender);
        }
        hasBetted[msg.sender] = true;
    }

    /*function rewardBets() public onlyOwner {

    }
    
    function getBetInfo() public {
        
    }*/
}