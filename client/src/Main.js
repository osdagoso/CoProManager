import React, { Component } from 'react';
import { Switch, Route } from 'react-router-dom'

import Error404 from './components/Error404/Error404';

// Main component serves as our main switch and container for general site content
// Props: isLogged (boolean) and isAdmin (boolean)
class Main extends Component {
    render() {
        // Replace Error404 component with the correct one once a specific page is developed
        return(
            <Switch>
                <Route exact path='/' component= {Error404} />
                { /* If logged and admin, show Users page */ }
                { this.props.isLogged && this.props.isAdmin &&
                    <Route path='/users' render={Error404}/>
                }
                { /* If logged, show Contests page; otherwise show Login page */ }
                <Route path='/contests' render= {this.props.isLogged ? Error404 : Error404} />
                { /* If logged, show Profile page; otherwise show Login page */ }
                <Route exact path='/profile' render= {this.props.isLogged ? Error404 : Error404} />
                { /* If logged, show Login page; otherwise show Home page */ }
                <Route exact path='/login' render= {this.props.isLogged ? Error404 : Error404} />
                { /* If logged, show Home page; otherwise show Sign Up page */ }
                <Route exact path='/signup' render= {this.props.isLogged ? Error404 : Error404} />

                { /* Otherwise show 404 page */ }
                <Route component= {Error404} />
            </Switch>
        );
    }
}

export default Main;

