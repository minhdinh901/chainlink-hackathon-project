# NBA-Betting

This project is a simple and fun program that simulates betting on NBA games.

To get started (using Ganache https://www.trufflesuite.com/ganache), clone this repository and run 
  > npm install

  > truffle migrate --network development
  
to deploy the contracts on a local Ganache blockchain. Before running the program, edit ./scripts/add-games.js using game IDs found on https://www.balldontlie.io/#get-all-games and edit the homeTeam[], visitorTeam[], gameDate[], and gameTime[] arrays in ./src/components/App.js to reflect the new game IDs. Then run 
  > truffle exec ./scripts/add-games.js --network development
  
  > npm run start
  
to start the program. All accounts will start with 100 NBA Tokens which can be deposited into the application using the 'Deposit' feature. Then, select a game to bet on and choose a team to bet on winning and input the bet amount. Bets will now be stored in the application but be careful not to place multiple bets on the same game as that will override the previous bet on the game and make the account lose NBA tokens. 

To stop the program, press the CTRL and C keys simultaneously and enter 'Y' when prompted. To reward a single bet, edit the ./scripts/reward-bets.js where the first parameter is the number of the game to issue rewards on (the first game is 0, second game is 1, third gamei is 2, etc) and the second parameter is deciding the winning team (home team is 1 and visitor team is 2). Then run
  > truffle exec ./scripts/reward-bets.js --network development
  
  > npm run start

and the account balance will be increased by twice the amount betted if won or stay the same otherwise.
