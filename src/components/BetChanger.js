import React, { Component } from 'react'
import { Switch,Route } from "react-router-dom"
import Bet from "./Bet"

class BetChanger extends Component {
    render(){
        return(
            <div>
                <Switch>
                    <Route path="/bet_1">
                        <Bet 
                            teams="Celtics vs Heat"
                            datetime="9/23/2020 | 8:30 ET"
                            teamA="celtics"
                            teamB="heat"
                        />
                    </Route>
                    <Route path="/bet_2">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_3">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_4">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_5">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_6">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_7">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_8">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_9">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_10">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_11">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_12">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_13">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_14">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/bet_15">
                        <Bet 
                            teams="N/A"
                            datetime="N/A"
                            teamA="N/A"
                            teamB="N/A"
                        />
                    </Route>
                    <Route path="/">
                        <h4>Choose a Game to Bet On</h4>
                    </Route>
                </Switch>
            </div>
        );
    }
}

export default BetChanger;