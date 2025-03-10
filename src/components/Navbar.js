import React, { Component } from 'react'
import basketball from '../basketball.png'

class Navbar extends Component {

    render() {
        return (
            <nav className="navbar navbar-dark fixed-top bg-dark flex-md-nowrap p-0 shadow">
                <a
                    className="navbar-brand col-sm-3 col-md-2 mr-0"
                    href="/"
                    rel="noopener noreferrer"
                >
                    <img src={basketball} width="30" height="30" className="d-inline-block align-top" alt="" />
                    &nbsp; NBA Betting Simulator
                </a>

                <ul className="navbar-nav px-3">
                    <li className="nav-item text-nowrap d-none d-sm-none d-sm-block">
                        <small className="text-secondary">
                            <medium id="account">Account: {this.props.account}</medium>
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <medium id="nbatoken">NBA Token: {this.props.nbaTokenAddress}</medium>
                        </small>
                    </li>
                </ul>
            </nav>
        );
    }
}

export default Navbar;
