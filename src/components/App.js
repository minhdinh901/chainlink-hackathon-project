import React, { Component } from 'react'
import Web3 from "web3";
import NbaToken from "../abis/NbaToken.json";
import NbaBetting from "../abis/NbaBetting.json";
import "./App.css";
import Navbar from "./Navbar";
import Main from "./Main";

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
    
        const networkId = await web3.eth.net.getId();
    
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
            this.updateScreen();
        } else {
            window.alert(
                "NbaBetting contract not deployed to detected network.");
        }

        this.setState({ loading: false });
    }

    async updateScreen() {
        const web3 = window.web3;
        const networkId = await web3.eth.net.getId();
        const nbaBettingData = NbaBetting.networks[networkId];
        const nbaBetting = new web3.eth.Contract(NbaBetting.abi, 
            nbaBettingData.address);
        let nbaTokenBalance = await nbaBetting.methods.nbaTokenBalance(
            this.state.account).call();
        this.setState({ nbaTokenBalance: nbaTokenBalance.toString() });
        let numGames = await nbaBetting.methods.numGames().call();
        this.setState({numGames: numGames});
    }
    
    deposit = (amount) => {
        this.setState({loading: true});
        this.state.nbaToken.methods.approve(this.state.nbaBetting._address, 
            amount).send({from: this.state.account}).on("transactionHash", 
            (hash) => {
                this.state.nbaBetting.methods.deposit(amount).send({
                from: this.state.account}).on("transactionHash", (hash) => {
                    this.setState({loading: false});
                }
            );
        });
    }

    withdraw = (amount) => {
        this.setState({loading: true});
        this.state.nbaBetting.methods.withdraw(amount).send(
            {from: this.state.account}).on("transactionHash", (hash) => {
                this.setState({loading: false});
            }
        );
    }

    placeBet = (game, team, amount) => {
        this.setState({loading: true});
        this.state.nbaBetting.methods.placeBet(game, team, amount)
            .send({from: this.state.account}).on("transactionHash", (hash) => {
                this.setState({loading: false});
            });
    }
    
    constructor(props) {
        super(props)
        this.state = {
            account: "",
            numGames: 0,
            homeTeam: ["Boston Celtics", "Los Angeles Lakers"],
            visitorTeam: ["Miami Heat", "Denver Nuggets"],
            gameDate: ["2020-09-25", "2020-09-26"],
            gameTime: ["8:30 PM ET", "9:00 PM ET"],
            nbaToken: {},
            nbaTokenAddress: "",
            nbaBetting: {},
            nbaTokenBalance: "",
            loading: true,
        }
    }

    render() {
        let content;
        if (this.state.loading) {
            content = (<p id="loader" className="text-center">Loading...</p>);
        } else {
            content = (
                <Main
                    nbaTokenAddress={this.state.nbaTokenAddress}
                    nbaTokenBalance={this.state.nbaTokenBalance}
                    numGames={this.state.numGames}
                    homeTeam={this.state.homeTeam}
                    visitorTeam={this.state.visitorTeam}
                    gameDate={this.state.gameDate}
                    gameTime={this.state.gameTime}
                    winningTeam={this.state.winningTeam}
                    placeBet={this.placeBet.bind(this)}
                    deposit={this.deposit.bind(this)}
                    withdraw={this.withdraw.bind(this)}
                />
            );
        }

        return (
            <div>
                <Navbar 
                    account={this.state.account} 
                    nbaTokenAddress={this.state.nbaTokenAddress}
                />
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
                {content}
            </div>
        );
    }
}

export default App;