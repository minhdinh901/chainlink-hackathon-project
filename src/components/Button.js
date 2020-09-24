import React, { Component } from 'react'

class Button extends Component {
    constructor(props){
        super(props);
        this.label = {
            value: null,
        };
    }

    render(){
        return(
            <a 
            href={this.props.link}
            >
                <button>
                    {this.props.label}
                </button>
            </a>
        )
    }
}
export default Button;