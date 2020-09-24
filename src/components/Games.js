import React, { Component } from 'react'
import { Link } from "react-router-dom"
import "./App.css"

class Games extends Component {
  render(){
        return(
            <div>
                <ul className="ul">
                    <li>
                        <Link to="/bet_1">Bet_1</Link>
                    </li>
                    <li>
                        <Link to="/bet_2">Bet_2</Link>
                    </li>
                    <li>
                        <Link to="/bet_3">Bet_3</Link>
                    </li>
                    <li>
                        <Link to="/bet_4">Bet_4</Link>
                    </li>
                    <li>
                        <Link to="/bet_5">Bet_5</Link>
                    </li>
                    <li>
                        <Link to="/bet_6">Bet_6</Link>
                    </li>
                    <li>
                        <Link to="/bet_7">Bet_7</Link>
                    </li>
                    <li>
                        <Link to="/bet_8">Bet_8</Link>
                    </li>
                    <li>
                        <Link to="/bet_9">Bet_9</Link>
                    </li>
                    <li>
                        <Link to="/bet_10">Bet_10</Link>
                    </li>
                    <li>
                        <Link to="/bet_11">Bet_11</Link>
                    </li>
                    <li>
                        <Link to="/bet_12">Bet_12</Link>
                    </li>
                    <li>
                        <Link to="/bet_13">Bet_13</Link>
                    </li>
                    <li>
                        <Link to="/bet_14">Bet_14</Link>
                    </li>
                    <li>
                        <Link to="/bet_15">Bet_15</Link>
                    </li>
                </ul>
            </div>
        );
    }
}

export default Games;