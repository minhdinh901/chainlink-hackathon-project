import React, { Component } from 'react'
import basketball from '../basketball.png'
import Button from './Button.js'
import './Home.css'
/*import { Button } from 'react-bootstrap/lib/InputGroup'*/

class Navbar extends Component {

  render() {  
        /*Button Work*/
        const buttonStyle = {
          color: "red",
          backgroundCOlor: "white",
          padding: "10px",
          fontFamily: "Arial", 
          justifyContent:'left',
          display: 'flex'
        };
        
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

        {/*Buttons*/}
        <Button 
        label="Deposit/Withdraw"
        style ={buttonStyle}
        link="./bet_page.js" /*Deposit/Withdraw Page */
        />  

        <ul className="navbar-nav px-3">
          <li className="nav-item text-nowrap d-none d-sm-none d-sm-block">
            <small className="text-secondary">
              <small id="account">{this.props.account}</small>
            </small>
          </li>
        </ul>
      </nav>
    );
  }
}

export default Navbar;
