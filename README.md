# Welcome to Cyberengine

Cyberengine is a Ruby on Rails web front-end designed to check and score common network services used in "blueteam-redteam-whiteteam" competitions.

## Schema Overview

* There are many **Teams** of type _white_, _red_, and _blue_
* A **Member** belongs to a team
* **Teams** have many **Servers**
* **Servers** have many **Services** each defining a _protocol_ (dns, ftp, ssh...) and _version_ (ipv4 or ipv6) 
* **Services** have many **Properties** that define that **Service** such as _address_ and _port_
* **Services** have many **Checks** that are _pass_ or _fail_
* **Services** can have many **Users** that have a _username_ and _password_

``` 
Teams:
  Members
  Servers:
    Services
      Properties
      Checks
      Users
```

## Checks

Any type of service can be defined, checked, and scored. The scoring is done by a script that usually pulls service's properties and users from the database and performs the required checks.

### Example Check

A simple script (written in any language) pulls all services and their properties with a protocol of "ping" across all teams from the database. For each service the script performs it's action which in this example is a ping against the address associated with service. If the address responds then it is determined to "pass" and a database insert is performed with the required check parameters. 

## Rails Frontend

The rails frontend is a fully functional application that can authenticate members and provides them access to their teams servers and services. This allows them to view their current status and position in the competition. Whiteteam members have full access to all parts of the application while blueteam members can only access their own information.

## Setup

Install ruby (version >= 1.9.3) - Ruby Version Manager [rvm](https://rvm.io/rvm/install/)

    curl -L https://get.rvm.io | bash -s stable
    source ~/.bashrc
    rvm requirements # install dependencies 
    rvm install 1.9.3
    rvm use 1.9.3 --default


Download cyberengine 

    git clone https://github.com/griffithchaffee/cyberengine.git
    cd cyberengine
    bundle install
    rake db:drop # Should not be any db to start with
    rake db:migrate
    rake db:seed
    gem install passenger
    ./quickstart.sh
  

Default login:

Username: whiteteam

Password: whiteteam 
