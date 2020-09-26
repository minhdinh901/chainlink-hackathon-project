import React, { Component } from 'react'
import { Switch,Route } from "react-router-dom"
import Bet from "./Bet"

class BetChanger extends Component {
    render(){
        let rows = [];

        for(var i = 0; i < this.props.numGames; i++){
            rows.push(
                <Route path={"/bet_" + i}>
                    <Bet
                        index={i}
                        home={this.props.homeTeam[i]}
                        visitor={this.props.visitorTeam[i]}
                        date={this.props.gameDate[i]}
                        time={this.props.gameTime[i]}
                        placeBet={this.props.placeBet.bind(this)}
                    />
                </Route>
            );
        }

        return(
            <div>
                <Switch>
                    {rows}
                    <Route path="/">
                        <h4>Choose a Game to Bet On</h4>
                    </Route>
                </Switch>
            </div>
        );
    }
}

export default BetChanger;