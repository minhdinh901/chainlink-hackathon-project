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
    async componentWillMount() {
        await this.loadWeb3();
        await this.loadBlockchainData();
    }

    async loadWeb3() {
        if (window.ethereum) {
            window.web3 = new Web3(window.ethereum);
            await window.ethereum.enable();
        } else if (window.web3) {
            window.web3 = new Web3(window.web3.currentProvider);
        } else {
            window.alert(
                "Non-Ethereum browser detected. Consider trying MetaMask."
            );
        }
    }

    async loadBlockchainData() {
        const web3 = window.web3;
    
        const accounts = await web3.eth.getAccounts();
        this.setState({ account: accounts[0] });
        this.setState({
            tokenAddress: "0xa36085F69e2889c224210F603D836748e7dC0088" });
        this.setState({ tokenName: "LINK" });
    
        const networkId = await web3.eth.net.getId();

        const erc20 = new web3.eth.Contract(ERC20.abi, this.state.tokenAddress);
        this.setState({ erc20 });
    
        //Load NbaToken
        const nbaTokenData = NbaToken.networks[networkId];
        if (nbaTokenData) {
            const nbaToken = new web3.eth.Contract(NbaToken.abi, 
                             nbaTokenData.address);
            this.setState({ nbaTokenAddress: nbaTokenData.address });
            this.setState({ nbaToken });
            let nbaTokenBalance = await nbaToken.methods.balanceOf(
                                  this.state.account).call();
            this.setState({ nbaTokenBalance: nbaTokenBalance.toString() });
        } else {
            window.alert(
                "NbaToken contract not deployed to detected network.");
        }
    
        //Load NbaBetting
        const nbaBettingData = NbaBetting.networks[networkId];
        if (nbaBettingData) {
            const nbaBetting = new web3.eth.Contract(NbaBetting.abi,
                               nbaBettingData.address);
            this.setState({ nbaBetting });
        } else {
            window.alert(
                "NbaBetting contract not deployed to detected network.");
        }
    }

    async updateNbaTokenBalance() {
        const web3 = window.web3;
        const networkId = await web3.eth.net.getId();
        const nbaBettingData = NbaBetting.networks[networkId];
        const nbaBetting = new web3.eth.Contract(NbaBetting.abi, 
            nbaBettingData.address);
        let nbaTokenBalance = await nbaBetting.methods.nbaTokenBalance(
            this.state.account).call();
        this.setState({ nbaTokenBalance: nbaTokenBalance.toString() });
    }

    /*getGameIds

    getFutureGamesData*/
    
    deposit = (amount) => {
        this.state.erc20.methods.approve(this.state.nbaBetting._address, 
            amount).send({from: this.state.account}).on("transactionHash", 
            (hash) => {
                this.state.nbaBetting.methods.deposit(amount).send({
                from: this.state.account}).on("transactionHash", (hash) => {});
            });
        this.updateNbaTokenBalance();
    }

    withdraw = (amount) => {
        this.state.nbaBetting.methods.withdraw(amount).send(
            {from: this.state.account}).on("transactionHash", (hash) => {});
        this.updateNbaTokenBalance();
    }

    /*placeBet

    rewardBets

    getGameHome

    getGameVisitor

    getGameDate

    getGameTime*/
    
    constructor(props) {
        super(props)
        this.state = {
            account: "0x0",
            erc20: {},
            nbaToken: {},
            nbaTokenAddress: "",
            nbaBetting: {},
            nbaTokenBalance: "0",
            tokenName: "",
            tokenAddress: "0x0"
        }
    }

    render() {
        return (
            <div>
                <Navbar account={this.state.account} />
                <div className="container-fluid mt-5">
                    <div className="row">
                        <main 
                            role="main" 
                            className="col-lg-12 ml-auto mr-auto" 
                            style={{ maxWidth: '600px' }}
                        >
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
                                balance={this.state.nbaTokenBalance}
                                withdraw={this.withdraw.bind(this)}
                                deposit={this.deposit.bind(this)}
                            />
                        </div>
                    </Router>
                </div>
            </div>
        );
    }
}

export default App;