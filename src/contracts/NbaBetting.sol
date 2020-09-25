pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

contract NbaBetting is ChainlinkClient {
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

    address public owner;
    IERC20 public nbaToken;
    string public date;
    uint public numGames;

    //Array that contains betters and their attributes
    address[] public betters;
    mapping(address => uint) public nbaTokenBalance;
    mapping(address => bool) public hasBetted;
    mapping(address => uint8[MAX_GAMES]) public gamesBetted;
    mapping(address => uint8[MAX_GAMES]) public teamsBetted;
    mapping(address => uint[MAX_GAMES]) public betAmounts;

    //Array that contains upcoming games and their attributes
    uint[MAX_GAMES] public gameIds;
    mapping(uint => bool) public isStored;
    mapping(uint => string) public homeTeam;
    mapping(uint => string) public visitorTeam;
    mapping(uint => string) public gameDate;
    mapping(uint => string) public gameTime;
    uint public tempGameId;
    string public tempHomeTeam;
    string public tempVisitorTeam;
    string public tempGameDate;
    string public tempGameTime;
    string public tempStatus;
    uint public tempHomeScore;
    uint public tempVisitorScore;

    constructor(address _nbaTokenAddress) public {
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
        makeApiCall(BYTES_JOB, this.processTimeData.selector, 
                    "http://worldtimeapi.org/api/timezone/America/New_York", 
                    "datetime");

        //Get next 15 games if possible
        makeApiCall(UINT_JOB, this.gamesToGet.selector, 
                    string(abi.encodePacked(
                    "https://www.balldontlie.io/api/v1/games?start_date=", 
                    date, "&end_date=", date)), "meta.total_count");

        //Get game IDs for all games on a given date
        for(uint8 i = 0; i < numGames; i++){
            //Convert i to a string to use in API call
            bytes memory _gameNum = new bytes(1);
            _gameNum[0] = byte(INT_ASCII_OFFSET + i);
            string memory gameNum = string(_gameNum);
            
            makeApiCall(UINT_JOB, this.storeGameId.selector, 
                        string(abi.encodePacked(
                        "https://www.balldontlie.io/api/v1/games?start_date=", 
                        date, "&end_date=", date)), string(abi.encodePacked(
                        "data.", gameNum, ".id")));
            gameIds[i] = tempGameId;
        }
    }

    /* For getGameIds() and getFutureGamesData functions only */
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
        if(_totalCount > MAX_GAMES){
            numGames = MAX_GAMES;
        }else{
            numGames = _totalCount;
        }
    }

    /* For getGameIds() function only */
    function storeGameId(bytes32 _requestId, uint _id) public 
             recordChainlinkFulfillment(_requestId) {
        if(!isStored[_id]){
            tempGameId = _id;
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
            string memory id = convertUintToString(_gameId);

            //Get home team
            makeApiCall(BYTES_JOB, this.storeHomeData.selector, 
                        string(abi.encodePacked(
                        "https://www.balldontlie.io/api/v1/games/", id)), 
                        "home_team.full_name");
            homeTeam[gameIds[i]] = tempHomeTeam;

            //Get visitor team
            makeApiCall(BYTES_JOB, this.storeVisitorData.selector, 
                        string(abi.encodePacked(
                        "https://www.balldontlie.io/api/v1/games/", id)), 
                        "visitor_team.full_name");
            visitorTeam[gameIds[i]] = tempVisitorTeam;

            //Get game date
            makeApiCall(BYTES_JOB, this.storeDateData.selector, 
                        string(abi.encodePacked(
                        "https://www.balldontlie.io/api/v1/games/", id)), 
                        "date");
            gameDate[gameIds[i]] = tempGameDate;

            //Get game time
            makeApiCall(BYTES_JOB, this.storeTimeData.selector, 
                        string(abi.encodePacked(
                        "https://www.balldontlie.io/api/v1/games/", id)), 
                        "status");
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

    /* Allow users to deposit NbaTokens */
    function deposit(uint _amount) public {
        require(_amount <= MAX_DEPOSIT, "Cannot deposit more than 999999");
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
                "Cannot be more than NbaToken balance");

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
    function rewardBets() public onlyOwner {
        //Search through array of games to see which games are finished
        for(uint i = 0; i < numGames; i++){
            //Get game status
            makeApiCall(BYTES_JOB, this.checkGameStatus.selector, 
                        string(abi.encodePacked(
                        "https://www.balldontlie.io/api/v1/games/", 
                        gameIds[i])), "status");
            
            //Check if game is not finished
            if(keccak256(abi.encodePacked(tempStatus)) 
               != keccak256(abi.encodePacked("Final"))){
                continue;
            }

            //Get home team score
            makeApiCall(UINT_JOB, this.homeScore.selector, 
                        string(abi.encodePacked(
                        "https://www.balldontlie.io/api/v1/games/", 
                        gameIds[i])), "home_team_score");

            //Get visitor team score
            makeApiCall(UINT_JOB, this.visitorScore.selector, 
                        string(abi.encodePacked(
                        "https://www.balldontlie.io/api/v1/games/", 
                        gameIds[i])), "visitor_team_score");

            //Determine winning team
            uint winningTeam = 0;
            if(tempHomeScore > tempVisitorScore){
                winningTeam = HOME_TEAM;
            }else{
                winningTeam = VISITOR_TEAM;
            }

            //Check who betted on this game
            for(uint j = 0; j < betters.length; j++){
                if((gamesBetted[betters[j]])[i] == 0){
                    continue;
                }

                //Reward winning betters
                if((teamsBetted[betters[j]])[i] == winningTeam){
                    nbaTokenBalance[betters[j]] = nbaTokenBalance[betters[j]] 
                                                  + (DOUBLE * 
                                                  (betAmounts[betters[j]])[i]);
                }

                //Remove relevant bet data
                (gamesBetted[betters[j]])[i] = 0;
                (teamsBetted[betters[j]])[i] = 0;
                (betAmounts[betters[j]])[i] = 0;
            }
        }
    }

    /* For rewardBets() function only */
    function checkGameStatus(bytes32 _requestId, bytes32 _status) public 
             recordChainlinkFulfillment(_requestId) {
        bytes memory status = abi.encodePacked(_status);
        tempStatus = string(status);
    }

    /* For rewardBets() function only */
    function homeScore(bytes32 _requestId, uint _homeScore) public 
             recordChainlinkFulfillment(_requestId) {
        tempHomeScore = _homeScore;
    }

    /* For rewardBets() function only */
    function visitorScore(bytes32 _requestId, uint _visitorScore) public 
             recordChainlinkFulfillment(_requestId) {
        tempVisitorScore = _visitorScore;
    }

    /* Converts a uint to a string */
    function convertUintToString(uint _convert) public pure 
        returns (string memory){
        bytes memory convert = new bytes(MAX_DIGITS);
        uint8 leastSignificantDigit = 0;
        uint8 index = 0;

        //Store digits in reverse
        while(_convert != 0){
            leastSignificantDigit = uint8(_convert % DECIMAL_BASE);
            _convert = _convert / DECIMAL_BASE;
            convert[index] = byte(INT_ASCII_OFFSET + leastSignificantDigit);
            index++;
        }

        //Reverse digits again to obtain correct string
        byte temp = "";
        for(uint8 j = 0; j < index / HALF; j++){
            temp = convert[j];
            convert[j] = convert[index - j - 1];
            convert[index - j - 1] = temp;
        }

        return string(convert);
    }

    /* Makes a Chainlink API request */
    function makeApiCall(bytes32 _job, bytes4 _selector, string memory _api, 
        string memory _path) public onlyOwner {
        Chainlink.Request memory req = 
            buildChainlinkRequest(_job, address(this), _selector);
        req.add("get", _api);
        req.add("path", _path);
        sendChainlinkRequestTo(ORACLE_ADDRESS, req, LINK_PAYMENT);
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