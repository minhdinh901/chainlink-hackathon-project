import React, { Component } from 'react'
import Navbar from './Navbar'
import './Home.css'

class Home extends Component {

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
              <div className="content mr-auto ml-auto"
                   style = {{display: 'flex', justifyContent:'center'}}>

                <h1>Upcoming NBA Games Today</h1>

              </div>
            </main>
          </div>
        </div>
      </div>
    );
  }
}

export default Home;
