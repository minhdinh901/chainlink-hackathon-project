import React, { Component } from 'react'
import { BrowserRouter as Router } from "react-router-dom"
import "./App.css"
import Games from "./Games"
import WithdrawDeposit from './WithdrawDeposit'
import BetChanger from './BetChanger'

class Main extends Component {
    render(){
        return(
            <div style = {{display: 'flex'}}> 
                <Router>
                    <div className="column">
                        <div>
                            <div>
                                <h4>Upcoming Games</h4>
                                <h6><br/></h6>
                            </div>
                            <nav>
                                <Games 
                                    numGames={this.props.numGames}
                                    homeTeam={this.props.homeTeam}
                                    visitorTeam={this.props.visitorTeam}
                                />
                            </nav>
                        </div>
                    </div>
                    <div className="column">
                        <BetChanger 
                            numGames={this.props.numGames}
                            homeTeam={this.props.homeTeam}
                            visitorTeam={this.props.visitorTeam}
                            gameDate={this.props.gameDate}
                            gameTime={this.props.gameTime}
                            placeBet={this.props.placeBet.bind(this)}
                        />
                    </div>
                    <div className="column">
                        <WithdrawDeposit 
                            balance={this.props.nbaTokenBalance}
                            withdraw={this.props.withdraw.bind(this)}
                            deposit={this.props.deposit.bind(this)}
                        />
                    </div>
                </Router>
            </div>
        );
    }
}

export default Main;