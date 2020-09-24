import React, { Component } from 'react'

class Bet extends Component {
    render(){
        return(
            <div>
                <div>
                    <h4>{this.props.teams}</h4>
                    <h5>{this.props.datetime}</h5>
                    <h6>Choose the Winning Team</h6>
                    <button>{this.props.teamA}</button>
                    <button>{this.props.teamB}</button>
                    <form>
                        <label>
                            <input type="text" name="bet_amount" />
                        </label>
                        <input type="submit" value="Place Bet" />
                    </form>
                    <h6>Please place a bet greater than 0</h6>
                </div>
            </div>
        );
    }
}

export default Bet;