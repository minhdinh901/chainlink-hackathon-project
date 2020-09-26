import React, { Component } from 'react'

class Bet extends Component {
    render(){
        return(
            <div>
                <div>
                    <h4>{this.props.home} vs {this.props.visitor}</h4>
                    <h5>{this.props.date} | {this.props.time}</h5>
                    <h6><br/></h6>
                    <div>
                        <h6>Choose the Winning Team</h6>
                        <button
                            onClick={(event) => {
                                event.preventDefault();
                                this.winningTeam = 1;
                                this.chosenTeam = this.props.home;
                            }}
                        >{this.props.home}</button>
                        &nbsp;&nbsp;&nbsp;
                        <button
                            onClick={(event) => {
                                event.preventDefault();
                                this.winningTeam = 2;
                                this.chosenTeam = this.props.visitor;
                            }}
                        >{this.props.visitor}</button>
                        <h6><br/></h6>
                        <form
                            onSubmit={(event) => {
                                event.preventDefault();
                                let index = this.props.index;
                                let winningTeam = this.winningTeam;
                                let amount = this.betAmount.value;
                                this.props.placeBet(index, winningTeam, amount);
                            }}
                        >
                            <label>
                                <input 
                                    type="text" 
                                    ref={(input) => {
                                        this.betAmount = input;
                                    }}
                                    placeholder="0"
                                    name="bet_amount" 
                                />
                            </label>
                            <input type="submit" value="Place Bet" />
                        </form>
                        <h6>Please place a bet greater than 0</h6>
                    </div>
                </div>
            </div>
        );
    }
}

export default Bet;