pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NbaBetting is ChainlinkClient, Ownable {
    uint8 constant private MAX_GAMES = 15;
    uint constant private DATE_FROM_API = 10;
    uint8 constant private INT_ASCII_OFFSET = 48;
    uint8 constant private MAX_DIGITS = 78;
    uint8 constant private DECIMAL_BASE = 10;
    uint8 constant private HALF = 2;
    uint8 constant private HOME_TEAM = 1;
    uint8 constant private VISITOR_TEAM = 2;
    uint8 constant private DOUBLE = 2;
    uint constant private MAX_DEPOSIT = 999999;

    //Address of Kovan network oracle which contains Get > bytes32 job
    //Alpha Chain - Kovan oracle found on market.link
    address private ORACLE_ADDRESS = 
        0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
    //Job ID of Get > bytes32 job
    //Found on market.link
    bytes32 constant private BYTES_JOB = "b7285d4859da4b289c7861db971baf0a";
    //Job ID of Get > uint256 job
    //Found on market.link
    bytes32 constant private UINT_JOB = "c7dd72ca14b44f0c9b6cfcd4b7ec0a2c";
    //LINK payment for Get > bytes32 and Get > uint256 jobs (0.1 LINK)
    //1 LINK  = 1 * (10^18)
    uint constant private LINK_PAYMENT = 100000000000000000;

    string public name = "Nba Betting";
    IERC20 public nbaToken;

    //Array that contains betters and their attributes
    address[] public betters;
    mapping(address => uint) public nbaTokenBalance;
    mapping(address => bool) public hasBetted;
    mapping(address => uint8[MAX_GAMES]) public gamesBetted;
    mapping(address => uint8[MAX_GAMES]) public teamsBetted;
    mapping(address => uint[MAX_GAMES]) public betAmounts;

    //Array that contains upcoming games and their attributes
    string public date;
    uint public numGames;
    uint[MAX_GAMES] public gameIds;
    mapping(uint => bool) public isStored;
    mapping(uint => string) public homeTeam;
    mapping(uint => string) public visitorTeam;
    mapping(uint => string) public gameDate;
    mapping(uint => string) public gameStatus;
    uint public tempGameId;
    bool public addGameId;
    string public tempHomeTeam;
    string public tempVisitorTeam;
    string public tempGameDate;
    string public tempGameStatus;
    string public tempStatus;
    uint public tempHomeScore;
    uint public tempVisitorScore;

    constructor(address _nbaTokenAddress) public {
        //setPublicChainlinkToken();
        nbaToken = IERC20(_nbaTokenAddress);
    }

    /* Allow users to deposit NbaTokens */
    function deposit(uint _amount) public {
        require(_amount <= MAX_DEPOSIT, 
                "Cannot deposit more than 999999");
        require(_amount > 0, "Cannot deposit 0");

        nbaToken.transferFrom(msg.sender, address(this), _amount);
        nbaTokenBalance[msg.sender] = nbaTokenBalance[msg.sender] + _amount;
    }

    /* Allow users to withdraw NbaTokens */ 
    function withdraw(uint _amount) public {
        require(_amount <= nbaTokenBalance[msg.sender], 
                "Cannot withdraw more than account balance");
        require(_amount > 0, "Cannot withdraw 0");

        nbaToken.transfer(msg.sender, _amount);
        nbaTokenBalance[msg.sender] = nbaTokenBalance[msg.sender] - _amount;
    }

    /* Allow users to place bets */
    function placeBet(uint8 _game, uint8 _team, uint _amount) public {
        require(_game >= 0 && _game < MAX_GAMES, "Choose a valid game");
        require(_team == HOME_TEAM || _team == VISITOR_TEAM, 
                "Choose a valid team");
        require(_amount > 0, "Must bet an amount greater than 0");
        require(_amount <= nbaTokenBalance[msg.sender], 
                "Cannot bet more than current balance");

        //Transfer tokens from user
        nbaTokenBalance[msg.sender] = nbaTokenBalance[msg.sender] - _amount;

        //Update relevant attributes of user
        (gamesBetted[msg.sender])[_game] = 1;
        (teamsBetted[msg.sender])[_game] = _team;
        (betAmounts[msg.sender])[_game] = _amount;

        //Add user to betters array
        if(!hasBetted[msg.sender]){
            betters.push(msg.sender);
        }
        hasBetted[msg.sender] = true;
    }

    /* Allow owner to reward betters if they won */
    function rewardBets(uint8 _finishedGame, uint8 _winningTeam) public onlyOwner {
        //Check who betted on this game
        for(uint i = 0; i < betters.length; i++){
            if((gamesBetted[betters[i]])[_finishedGame] == 0){
                continue;
            }

            //Reward winning betters
            if((teamsBetted[betters[i]])[_finishedGame] == _winningTeam){
                nbaTokenBalance[betters[i]] = nbaTokenBalance[betters[i]] 
                    + (DOUBLE * (betAmounts[betters[i]])[_finishedGame]);
            }

            //Remove relevant bet data
            (gamesBetted[betters[i]])[_finishedGame] = 0;
            (teamsBetted[betters[i]])[_finishedGame] = 0;
            (betAmounts[betters[i]])[_finishedGame] = 0;
        }
    }

    /* 
     * APIs used:
     * NBA API instructions: https://www.balldontlie.io/#get-all-games
     * World Clock API: http://worldtimeapi.org/ 
     */

    /* Allow owner to add a new array of game IDs */
    function addGames(uint[] memory _ids) public onlyOwner {
        require(_ids.length <= MAX_GAMES, "Cannot input more than 15 games");

        numGames = _ids.length;

        //Clear original array
        for(uint i = 0; i < MAX_GAMES; i++){
            gameIds[i] = 0;
        }

        //Add new game IDs
        for(uint i = 0; i < _ids.length; i++){
            gameIds[i] = _ids[i];
        }
    }

    /* Allow owner to get the data of stored games */
    function getGameData() public onlyOwner {
        for(uint i = 0; i < numGames; i++){
            string memory id = string(abi.encodePacked(gameIds[i]));

            //Get home team
            Chainlink.Request memory reqHome = buildChainlinkRequest(BYTES_JOB,
                address(this), this.storeHomeData.selector);
            reqHome.add("get", string(abi.encodePacked(
                    "https://www.balldontlie.io/api/v1/games/", id)));
            reqHome.add("path", "home_team.full_name");
            sendChainlinkRequestTo(ORACLE_ADDRESS, reqHome, LINK_PAYMENT);
            homeTeam[gameIds[i]] = tempHomeTeam;

            //Get visitor team
            Chainlink.Request memory reqVisitor = buildChainlinkRequest(
                BYTES_JOB, address(this), this.storeVisitorData.selector);
            reqVisitor.add("get", string(abi.encodePacked(
                    "https://www.balldontlie.io/api/v1/games/", id)));
            reqVisitor.add("path", "visitor_team.full_name");
            sendChainlinkRequestTo(ORACLE_ADDRESS, reqVisitor, LINK_PAYMENT);
            visitorTeam[gameIds[i]] = tempVisitorTeam;

            //Get game date
            Chainlink.Request memory reqDate = buildChainlinkRequest(BYTES_JOB,
                address(this), this.storeDateData.selector);
            reqDate.add("get", string(abi.encodePacked(
                    "https://www.balldontlie.io/api/v1/games/", id)));
            reqDate.add("path", "date");
            sendChainlinkRequestTo(ORACLE_ADDRESS, reqDate, LINK_PAYMENT);
            gameDate[gameIds[i]] = tempGameDate;

            //Get game status
            Chainlink.Request memory reqStatus = buildChainlinkRequest(
                BYTES_JOB, address(this), this.storeStatusData.selector);
            reqStatus.add("get", string(abi.encodePacked(
                    "https://www.balldontlie.io/api/v1/games/", id)));
            reqStatus.add("path", "status");
            sendChainlinkRequestTo(ORACLE_ADDRESS, reqStatus, LINK_PAYMENT);
            gameStatus[gameIds[i]] = tempGameStatus;
        }
    }

    /* For getGameData() function only */
    function storeHomeData(bytes32 _requestId, bytes32 _homeTeam) public 
             recordChainlinkFulfillment(_requestId) {
        tempHomeTeam = string(abi.encodePacked(_homeTeam));
    }

    /* For getGameData() function only */
    function storeVisitorData(bytes32 _requestId, bytes32 _visitorTeam) public 
             recordChainlinkFulfillment(_requestId) {
        tempVisitorTeam = string(abi.encodePacked(_visitorTeam));
    }

    /* For getGameData() function only */
    function storeDateData(bytes32 _requestId, bytes32 _date) public 
             recordChainlinkFulfillment(_requestId) {
        //Create arrays to parse date from _date
        bytes memory datetime = abi.encodePacked(_date);
        bytes memory _datetime = new bytes(DATE_FROM_API);

        //Extract date from datetime
        for(uint i = 0; i < DATE_FROM_API; i++){
            _datetime[i] = datetime[i];
        }

        //Save date
        tempGameDate = string(_datetime);
    }

    /* For getGameData() function only */
    function storeStatusData(bytes32 _requestId, bytes32 _status) public 
             recordChainlinkFulfillment(_requestId) {
        tempGameStatus = string(abi.encodePacked(_status));
    }
}