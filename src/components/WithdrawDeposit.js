import React, { Component } from 'react'

class WithdrawDeposit extends Component {
  render(){
        return(
            <div>
                <h4>Account Balance</h4>
                <h5>{this.props.balance} NbaTokens</h5>
                <h4><br/></h4>
                <h4>Withdraw or Deposit</h4>
                <form>
                    <label>
                        <input type="text" name="withdraw_amount" />
                    </label>
                    <input type="submit" value="Withdraw" />
                </form>
                <form>
                    <label>
                        <input type="text" name="deposit_amount" />
                    </label>
                    <input type="submit" value="Deposit" />
                </form>
                <h6>Please deposit no more than 999999</h6>
            </div>
        );
    }
}

export default WithdrawDeposit;