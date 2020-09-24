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
      <div>s
        <Navbar account={this.state.account} />
        
        {/*Title*/}
        <div className="container-fluid mt-5">
          <div className="row">
            <main role="main" className="col-lg-12 ml-auto mr-auto" style={{ maxWidth: '600px' }}>
              <div className="content mr-auto ml-auto"
                   style = {{display: 'flex', justifyContent:'center'}}>
                  <header className="header">
                    <h1>Upcoming NBA Games Today</h1>
                  </header>
              </div>
            </main>
          </div>   
        </div>

        {/*Game boxes*/}
        <div
          style = {{display: 'flex', height: '50%'}}
        >       
          <section className="section">
                <div class="column">Game 1</div>
                <div class="column">Game 2</div>
                <div class="column">Game 3</div>
          </section>
        </div>
    </div>
    );
  }
}

export default Home;
