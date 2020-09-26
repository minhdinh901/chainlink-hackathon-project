# NBA-Betting

This project is a simple and fun program that simulates betting on NBA games

To get started, clone this repository and run
  > truffle migrate --network development
  
to deploy the contracts on a local Ganache blockchain. Before running the program, edit ./scripts/add-games.js using game IDs found on https://www.balldontlie.io/#get-all-games and edit the homeTeam[], visitorTeam[], gameDate[], and gameTime[] arrays in ./src/components/App.js to reflect the new game IDs. Then run 
  > npm run start
  
to start the program. All accounts will start with 100 NBA Tokens which can be deposited into the application using the 'Deposit' feature. Then, select a game to bet on and choose a team to bet on winning and input the bet amount. Bets will now be stored in the application but be careful not to place multiple bets on the same game as that will override the previous bet on the game and make the account lose NBA tokens. 

To
