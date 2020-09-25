import React, { Component } from 'react'

class WithdrawDeposit extends Component {
  render(){
        return(
            <div>
                <h4>Account Balance</h4>
                <h5>{this.props.balance} NbaTokens</h5>

                <h4><br/></h4>

                <h4>Withdraw or Deposit</h4>
                <form
                    onSubmit={(event) => {
                        event.preventDefault();
                        let amount = this.deposit.value;
                        this.props.deposit(amount);
                    }}
                >
                    <label>
                        <input 
                            type="text" 
                            ref={(input) => {
                                this.deposit = input;
                            }}
                            placeholder="0"
                            name="deposit_amount" 
                        />
                    </label>
                    <input type="submit" value="Deposit" />
                </form>
                <h6>Please deposit no more than 999999</h6>

                <h6><br/></h6>

                <form
                    onSubmit={(event) => {
                        event.preventDefault();
                        let amount = this.withdraw.value;
                        this.props.withdraw(amount);
                    }}
                >
                    <label>
                        <input 
                            type="text" 
                            ref={(input) => {
                                this.withdraw = input;
                            }}
                            placeholder="0"
                            name="withdraw_amount" 
                        />
                    </label>
                    <input type="submit" value="Withdraw" />
                </form>
            </div>
        );
    }
}

export default WithdrawDeposit;