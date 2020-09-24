import React, { Component } from 'react'
import { BrowserRouter as Router } from "react-router-dom"
import Web3 from "web3";
import NbaToken from "../abis/NbaToken.json";
import NbaBetting from "../abis/NbaBetting.json";
import ERC20 from "../abis/ERC20.json";
import "./App.css"
import Navbar from './Navbar'
import Games from "./Games"
import WithdrawDeposit from './WithdrawDeposit'
import BetChanger from './BetChanger'

class App extends Component {

    constructor(props) {
        super(props)
        this.state = {
            account: '0x0'
        }
    }

    render() {
        return (
            <div>
                <Navbar account={this.state.account} />
                <div className="container-fluid mt-5">
                    <div className="row">
                        <main role="main" className="col-lg-12 ml-auto mr-auto" style={{ maxWidth: '600px' }}>
                            <div className="content mr-auto ml-auto">
                            </div>
                        </main>
                    </div>
                </div>
                <div style = {{display: 'flex'}}> 
                    <Router>
                        <div className="column">
                            <div>
                                <div>
                                    <h4>Games Today</h4>
                                </div>
                                <nav>
                                    <Games />
                                </nav>
                            </div>
                        </div>
                        <div className="column">
                            <BetChanger />
                        </div>
                        <div className="column">
                            <WithdrawDeposit 
                                balance="1000"
                            />
                        </div>
                    </Router>
                </div>
            </div>
        );
    }
}

export default App;