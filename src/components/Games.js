import React, { Component } from 'react'
import { Link } from "react-router-dom"
import "./App.css"

class Games extends Component {
    render(){
        let rows = [];

        for(var i = 0; i < this.props.numGames; i++){
            rows.push(
                <div>
                    <Link to={"/bet_" + i}>
                        {this.props.homeTeam[i]} vs {this.props.visitorTeam[i]}
                    </Link>
                </div>
            );
        }

        return(
            <div>
                {rows}
            </div>
        );
    }
}

export default Games;