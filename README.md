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

Any type of service can be defined, checked, and scored. Scoring can be performed by any script by simply pulling service properties/users from the database.

### Example Check

A simple script (written in any language) pulls all services and their properties with a protocol of "ping" across all teams from the database. For each service the script performs it's action which in this example is a ping against the address associated with service (address defined by a service property). If the address responds then it is determined to "pass" and a database insert is performed with the required check parameters (passed, request, response). 

## Rails Frontend

The rails frontend is a fully functional application that can authenticate members and provides them access to their teams servers and services. This allows them to view their current status and position in the competition. Whiteteam members have full access to all parts of the application while blueteam members can only access their own information.

## Setup

Install ruby (version >= 1.9.3) - Ruby Version Manager [rvm](https://rvm.io/rvm/install/)

    # From fresh installation (minimal) as root
    yum install -y bash tar curl git patch httpd sqlite sqlite-devel # Changing sqlite to postgres soon
    curl -L https://get.rvm.io | bash -s stable
    source /etc/profile.d/rvm.sh
    rvm requirements # run install command for ruby dependencies 
    # Example - Fedora 17:
    yum install gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel
    rvm install 1.9.3 --verify-downloads 1
    rvm use 1.9.3 --default
    rvm gemset create cyberengine
    rvm gemset use cyberengine 


Download cyberengine 

    mkdir /var/rails
    cd /var/rails
    git clone -v https://github.com/griffithchaffee/cyberengine.git
    chown -R apache:apache /var/rails/cyberengine # If you dont do this you may get permission errors
    cd cyberengine
    bundle install
    rake db:drop          # Should not be any db to start with
    rake db:migrate       # Build db schema
    rake db:seed          # Testing seed data
    ./quickstart.sh       # test installation - not ment for production

  
Apache hosting is done using a mod called phusion passenger. It is very easy to setup. 

    # Documentation: http://www.modrails.com/documentation/Users%20guide%20Apache.html
    passenger-install-apache2-module # run install command for apache dependencies
    # Example - Fedora 17:
    yum install httpd-devel apr-devel apr-util-devel curl-devel

    
/etc/httpd/conf/httpd.conf # I appended to end of file

    LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.3-p374@cyberengine/gems/passenger-3.0.19/ext/apache2/mod_passenger.so
    PassengerRoot /usr/local/rvm/gems/ruby-1.9.3-p374@cyberengine/gems/passenger-3.0.19
    PassengerRuby /usr/local/rvm/wrappers/ruby-1.9.3-p374@cyberengine/ruby
    NameVirtualHost *:80
    <VirtualHost *:80>
      RailsEnv development
      ServerName 192.168.122.159
      ServerAlias 192.168.122.159
      # !!! Be sure to point DocumentRoot to 'public'!
      DocumentRoot /var/rails/cyberengine/public
      <Directory /var/rails/cyberengine/public>
         #order allow,deny
         #allow from all
         # This relaxes Apache security settings.
         AllowOverride all
         # MultiViews must be turned off.
         Options -MultiViews
      </Directory>
    </VirtualHost>
    

Default login:

    Username: whiteteam
    Password: whiteteam 


Other logins:

    redteam:redteam
    team1:team1
    team2:team2


