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
            <button
                href={this.props.link}
            >
                {this.props.label}
            </button>
        )
    }
}
export default Button;