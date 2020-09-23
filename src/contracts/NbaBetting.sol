pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

contract NbaBetting is ChainlinkClient {
    uint8 constant private MAX_GAMES = 3; //Only 3 future games to bet on
    uint8 constant private GAME_OFFSET = 10;
    uint constant private DATE_FROM_API = 10;
    uint constant private FUTURE_GAMES = 15;
    uint8 constant private INT_ASCII_OFFSET = 48;
    uint8 constant private MAX_DIGITS = 78;
    uint8 constant private DECIMAL_BASE = 10;
    uint8 constant private HALF = 2;
    uint constant private MAX_DEPOSIT = 999999000000000000000000;

    //Address of Kovan network oracle which contains Get > bytes32 job
    //Alpha Chain - Kovan oracle found on market.link
    address private ORACLE_ADDRESS = 0xAA1DC356dc4B18f30C347798FD5379F3D77ABC5b;
    //Job ID of Get > bytes32 job
    //Found on market.link
    bytes32 constant private BYTES_JOB = "b7285d4859da4b289c7861db971baf0a";
    //Job ID of Get > uint256 job
    //Found on market.link
    bytes32 constant private UINT_JOB = "c7dd72ca14b44f0c9b6cfcd4b7ec0a2c";
    //LINK payment for Get > bytes32 and Get > uint256 jobs (0.1 LINK)
    //1 LINK  = 1 * (10^18)
    uint constant private LINK_PAYMENT = 100000000000000000;

    address public owner;
    IERC20 public nbaToken;
    string public date;
    uint public numGames;

    //Array that contains betters and their attributes
    address[] public betters;
    mapping(address => uint) public nbaTokenBalance;
    mapping(address => bool) public hasBetted;
    mapping(address => uint8) public gamesBetted;
    mapping(address => uint8) public teamsBetted;
    mapping(address => uint) public betAmount1;
    mapping(address => uint) public betAmount2;
    mapping(address => uint) public betAmount3;

    //Array that contains upcoming games and their attributes
    uint[] public gameIds;
    mapping(uint => bool) public isStored;
    string public tempHomeTeam;
    mapping(uint => string) public homeTeam;
    string public tempVisitorTeam;
    mapping(uint => string) public visitorTeam;
    string public tempGameDate;
    mapping(uint => string) public gameDate;
    string public tempGameTime;
    mapping(uint => string) public gameTime;

    constructor(IERC20 _nbaTokenAddress) public {
        setPublicChainlinkToken(); //Set the address for the LINK token
        nbaToken = IERC20(_nbaTokenAddress);
        owner = msg.sender;
    }

    /* 
     * Allow owner to get future games
     * NBA API instructions: https://www.balldontlie.io/#get-all-games
     * World Clock API: http://worldtimeapi.org/ 
     */
    function getGameIds() public onlyOwner {
        //Get time data in EDT
        Chainlink.Request memory reqDate = 
            buildChainlinkRequest(BYTES_JOB, address(this), 
                                  this.processTimeData.selector);
        reqDate.add("get", 
                 "http://worldtimeapi.org/api/timezone/America/New_York");
        reqDate.add("path", "datetime");
        sendChainlinkRequestTo(ORACLE_ADDRESS, reqDate, LINK_PAYMENT);

        //Get next 15 games if possible
        Chainlink.Request memory reqGames = 
            buildChainlinkRequest(UINT_JOB, address(this), 
                                  this.gamesToGet.selector);
        reqGames.add("get", 
                 string(abi.encodePacked(
                 "https://www.balldontlie.io/api/v1/games?start_date=", 
                 date)));
        reqGames.add("path", "meta.total_count");
        sendChainlinkRequestTo(ORACLE_ADDRESS, reqGames, LINK_PAYMENT);

        //Get game IDs for all upcoming games
        for(uint8 i = 0; i < numGames; i++){
            //Convert i to a string to use in API call
            bytes memory _gameNum = new bytes(1);
            _gameNum[0] = byte(INT_ASCII_OFFSET + i);
            string memory gameNum = string(_gameNum);
            
            Chainlink.Request memory reqId = 
                buildChainlinkRequest(UINT_JOB, address(this), 
                                      this.storeGameId.selector);
            reqId.add("get", 
                      string(abi.encodePacked(
                      "https://www.balldontlie.io/api/v1/games?start_date=", 
                      date)));
            reqId.add("path", string(abi.encodePacked("data.", gameNum, 
                      ".id")));
            sendChainlinkRequestTo(ORACLE_ADDRESS, reqId, LINK_PAYMENT);
        }
    }

    /* For getGameIds() function only */
    function processTimeData(bytes32 _requestId, bytes32 _datetime) public 
             recordChainlinkFulfillment(_requestId) {
        //Create arrays to parse date from _datetime
        bytes memory datetime = abi.encodePacked(_datetime);
        bytes memory _date = new bytes(DATE_FROM_API);

        //Extract date from datetime
        for(uint i = 0; i < DATE_FROM_API; i++){
            _date[i] = datetime[i];
        }

        //Save date
        date = string(_date);
    }

    /* For getGameIds() function only */
    function gamesToGet(bytes32 _requestId, uint _totalCount) public 
             recordChainlinkFulfillment(_requestId) {
        if(_totalCount > FUTURE_GAMES){
            numGames = FUTURE_GAMES;
        }else{
            numGames = _totalCount;
        }
    }

    /* For getGameIds() function only */
    function storeGameId(bytes32 _requestId, uint _id) public 
             recordChainlinkFulfillment(_requestId) {
        if(!isStored[_id]){
            gameIds.push(_id);
        }
        isStored[_id] = true;
    }

    /* Get game data from game IDs stored in gameIds array */
    function getFutureGamesData() public onlyOwner {
        for(uint i = 0; i < gameIds.length; i++){
            //Check for invalid game ID
            if(gameIds[i] == 0){
                break;
            }

            //Convert game ID to string
            uint _gameId = gameIds[i];
            bytes memory gameId = new bytes(MAX_DIGITS);
            uint8 leastSignificantDigit = 0;
            uint8 index = 0;
            //Store digits in reverse
            while(_gameId != 0){
                leastSignificantDigit = uint8(_gameId % DECIMAL_BASE);
                _gameId = _gameId / DECIMAL_BASE;
                gameId[index] = byte(INT_ASCII_OFFSET + leastSignificantDigit);
                index++;
            }
            //Reverse digits again to obtain correct string
            byte temp = "";
            for(uint8 j = 0; j < index / HALF; j++){
                temp = gameId[j];
                gameId[j] = gameId[index - j - 1];
                gameId[index - j - 1] = temp;
            }
            string memory id = string(gameId);

            //Get home team
            Chainlink.Request memory reqHome = 
            buildChainlinkRequest(BYTES_JOB, address(this), 
                                  this.storeHomeData.selector);
            reqHome.add("get", string(abi.encodePacked(
                        "https://www.balldontlie.io/api/v1/games/", id)));
            reqHome.add("path", "home_team.full_name");
            sendChainlinkRequestTo(ORACLE_ADDRESS, reqHome, LINK_PAYMENT);
            homeTeam[gameIds[i]] = tempHomeTeam;

            //Get visitor team
            Chainlink.Request memory reqVisitor = 
            buildChainlinkRequest(BYTES_JOB, address(this), 
                                  this.storeVisitorData.selector);
            reqVisitor.add("get", string(abi.encodePacked(
                           "https://www.balldontlie.io/api/v1/games/", id)));
            reqVisitor.add("path", "visitor_team.full_name");
            sendChainlinkRequestTo(ORACLE_ADDRESS, reqVisitor, LINK_PAYMENT);
            visitorTeam[gameIds[i]] = tempVisitorTeam;

            //Get game date
            Chainlink.Request memory reqDate = 
            buildChainlinkRequest(BYTES_JOB, address(this), 
                                  this.storeDateData.selector);
            reqDate.add("get", string(abi.encodePacked(
                           "https://www.balldontlie.io/api/v1/games/", id)));
            reqDate.add("path", "date");
            sendChainlinkRequestTo(ORACLE_ADDRESS, reqDate, LINK_PAYMENT);
            gameDate[gameIds[i]] = tempGameDate;

            //Get game time
            Chainlink.Request memory reqTime = 
            buildChainlinkRequest(BYTES_JOB, address(this), 
                                  this.storeTimeData.selector);
            reqTime.add("get", string(abi.encodePacked(
                           "https://www.balldontlie.io/api/v1/games/", id)));
            reqTime.add("path", "status");
            sendChainlinkRequestTo(ORACLE_ADDRESS, reqTime, LINK_PAYMENT);
            gameTime[gameIds[i]] = tempGameTime;
        }
    }

    /* For getFutureGamesData() function only */
    function storeHomeData(bytes32 _requestId, bytes32 _homeTeam) public 
             recordChainlinkFulfillment(_requestId) {
        bytes memory _tempHomeTeam = abi.encodePacked(_homeTeam);
        tempHomeTeam = string(_tempHomeTeam);
    }

    /* For getFutureGamesData() function only */
    function storeVisitorData(bytes32 _requestId, bytes32 _visitorTeam) public 
             recordChainlinkFulfillment(_requestId) {
        bytes memory _tempVisitorTeam = abi.encodePacked(_visitorTeam);
        tempVisitorTeam = string(_tempVisitorTeam);
    }

    /* For getFutureGamesData() function only */
    function storeDateData(bytes32 _requestId, bytes32 _date) public 
             recordChainlinkFulfillment(_requestId) {
        //Create arrays to parse date from _date
        bytes memory tempDate = abi.encodePacked(_date);
        bytes memory transfer = new bytes(DATE_FROM_API);

        //Extract date
        for(uint i = 0; i < DATE_FROM_API; i++){
            transfer[i] = tempDate[i];
        }

        //Save date
        tempGameDate = string(transfer);
    }

    /* For getFutureGamesData() function only */
    function storeTimeData(bytes32 _requestId, bytes32 _time) public 
             recordChainlinkFulfillment(_requestId) {
        bytes memory _tempGameTime = abi.encodePacked(_time);
        tempGameTime = string(_tempGameTime);
    }

    /*TODO: function rewardBets() public onlyOwner {

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
    
    /* Get home team by game ID */
    function getGameHome(uint _gameId) public view returns (string memory) {
        return homeTeam[_gameId];
    }

    /* Get visitor team by game ID */
    function getGameVisitor(uint _gameId) public view returns (string memory) {
        return visitorTeam[_gameId];
    }

    /* Get date by game ID */
    function getGameDate(uint _gameId) public view returns (string memory) {
        return gameDate[_gameId];
    }

    /* Get time by game ID */
    function getGameTime(uint _gameId) public view returns (string memory) {
        return gameTime[_gameId];
    }

    /* Restrict access to owner of contract */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}