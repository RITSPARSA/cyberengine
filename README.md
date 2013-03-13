# Welcome to Cyberengine

Cyberengine is a Ruby on Rails web front-end designed to check and score common network services used in "blueteam-redteam-whiteteam" competitions.

## Schema Overview

* There are many **Teams** of type _white_, _red_, and _blue_
* A **Member** belongs to a team
* **Teams** have many **Servers**
* **Servers** have many **Services** each defining a _protocol_ (dns, ftp, ssh...) and _version_ (ipv4, ipv6...) 
* **Services** have many **Properties** that define that **Service** such as _address_ and _port_
* **Services** have many **Checks** that are _pass_ or _fail_
* **Services** can have many **Users** that have a _username_ and _password_

``` 
Teams:
    Servers:
        Services
            Properties
            Checks
            Users
```

## Checks

Any type of service can be defined, checked, and scored. Scoring can be performed by any script by simply pulling service properties/users from the database.

### Example Check

A script (written in any language) pulls services called "Alive" across all teams from the database. For each service, the script pings the address property associated with the service. If the destination responds then the service "passes". A database insert is performed with the required check parameters (passed, request, response, created_at. 

## Rails Frontend

The rails frontend is a fully functional application that can authenticate members and provides them access to their teams servers and services. This allows them to view their current status and position in the competition. Whiteteam members have full access to all parts of the application while blueteam members can only access their own information. Teams can update service user's individually or CSV style. 

## Setup

1. Install ruby (version >= 1.9.3) - Ruby Version Manager [rvm](https://rvm.io/rvm/install/)

```bash
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
```

2. Download cyberengine 

```bash
mkdir /var/rails
cd /var/rails
git clone -v https://github.com/griffithchaffee/cyberengine.git
chown -R apache:apache /var/rails/cyberengine # If you dont do this you may get permission errors
cd cyberengine
bundle install

# Resets databases 
# Installs basic teams
# Basic teams: 
## Whiteteam: whiteteam:whiteteam
## Redteam: redteam:redteam
rake setup:reset      

# Test installation 
# Browse to port 80 on localhost
bash quickstart.sh      
```

3. Database Setup (Fedora - PostgreSQL):

```bash
# Install PostgreSQL
yum install postgresql-server
postgresql-setup initdb
systemctl enable postgresql.service
systemctl start postgresql.service

# Create cyberengine user/password
su postgres
psql -c "CREATE ROLE cyberengine PASSWORD 'cyberengine' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN"

# Test database connection
# Database connection information config/database.yml (defaults should be fine)
cd <cyberengine-base-directory>
rails console
ActiveRecord::Base.establish_connection(Rails.configuration.database_configuration[Rails.env])
exit

# Reset/Create databases
rake cyberengine:reset

# Create Whiteteam and Redteam with default logins: whiteteam:whiteteam redteam:redteam
rake cyberengine:basic
```

4. Apache hosting is done using a mod called phusion passenger. It is very easy to setup. 

```bash
# Apache on Fedora 17:
# Documentation: http://www.modrails.com/documentation/Users%20guide%20Apache.html
yum install httpd httpd-devel apr-devel apr-util-devel curl-devel

# Follow install walkthrough 
passenger-install-apache2-module # Read output
```

5. Update httpd.conf

```bash    
# Append to /etc/httpd/conf/httpd.conf 
# Configuration will need some modification

# Paths may be different
LoadModule passenger_module /usr/local/rvm/gems/ruby-1.9.3-p374@cyberengine/gems/passenger-3.0.19/ext/apache2/mod_passenger.so
PassengerRoot /usr/local/rvm/gems/ruby-1.9.3-p374@cyberengine/gems/passenger-3.0.19
PassengerRuby /usr/local/rvm/wrappers/ruby-1.9.3-p374@cyberengine/ruby

NameVirtualHost *:80
<VirtualHost *:80>
  # Default to development, change to "production"
  RailsEnv development
  # Uncomment below for production
  #RailsEnv production

  # Change addresses (DNS?)
  ServerName 192.168.1.10
  ServerAlias 192.168.1.10

  # Be sure to point DocumentRoot to 'public' directory
  DocumentRoot /var/rails/cyberengine/public
  <Directory /var/rails/cyberengine/public>
     Order allow,deny
     Allow from all
     # This relaxes Apache security settings.
     AllowOverride all
     # MultiViews must be turned off.
     Options -MultiViews
  </Directory>
</VirtualHost>
```

## Important files

**config/initializers/cyberengine.rb**
* Define application title (Default: ISTS)
* Define application brand (Default: ISTS)

**app/views/static/welcome.html.erb** 
* Basic welcome page
* Contains information about competition and sponsors

**app/model/ability.rb**
* Defines permissions
* Option to allow username updates
* Option to allow viewing of other all teams users/passwords (popular at end of competitions)

**config/database.yml**
* Database connection setup - default: PostgreSQL - cyberengine:cyberengine
* Example default configurations: config/{database.yml.pg, database.yml.sqlite, database.yml.mysql}

**checks/database.yml**
* Database connection setup for checks


## Property Best Practices
* General groups
* Should not take the place of the property option

### Property Categories
```bash
category: 'address'
# Almost always required
# The address category is used to identify the domain or IP the service should be checked at.
# Each address provided will have the the checks run against it.
# This means there will be multiple checks per round if there are multiple addresses.
# The advantage to this is that services can be checked by both IP and domain.
# If the domain is not available (DNS is down) the team will still be getting checks by IP 
```
```bash
category: 'random'
# The random category is used when there are many properties with the same 'property' but different 'values' 
# For example, many 'uri' properties could be defined for an HTTP Availability check but only one should be used per check
# A SQL 'ORDER BY RANDOM() LIMIT(1)' statement is used to pull the random property
```
```bash
category: 'option'
# Optional category properties are not required for the check but may be desired
# For example, the destination user/domain of an SMTP check defaults to whiteteam@cyberengine.ists
# The user or domain could be changed using: category: 'option', property: 'rcpt-domain', value: 'whiteteam.ccdc'
```
```bash
category: 'answer'
# Used to map random category properties to answers
# For example, a DNS domain mapped to it's 'answer' address
# Full example:
# category: 'random', property: 'domain', value: 'google-public-dns-a.google.com'
# category: 'answer', property: 'google-public-dns-a.google.com', value: '8.8.8.8'
```

### Properties
* Lowercase with hyphen delimiters
```bash
# Good
category: 'option', property: 'from-domain'
category: 'option', property: 'file-name'
# Bad
category: 'option', property: 'From Domain'
category: 'option', property: 'from_domain'
```

## Prebuilt Checks ##


### Ping Check
* checks/ipv4/ping.rb
* checks/ipv6/ping.rb

#### Service
```bash
name: 'Ping'
version: 'ipv4' or 'ipv6'
protocol: 'icmp'
```
#### Properties
* Required
```bash
category: 'address'
property: 'domain' or 'ip'
```

 
### FTP Upload Check
* checks/ipv4/ftp-upload.rb
* checks/ipv6/ftp-upload.rb
#### Service
```bash
name: 'FTP Upload'
version: 'ipv4' or 'ipv6'
protocol: 'ftp'
```
#### Properties
* Required
```bash
category: 'address'
property: 'domain' or 'ip'
```


### FTP Download Check
* checks/ipv4/ftp-download.rb
* checks/ipv6/ftp-download.rb
#### Service
```bash
name: 'FTP Download'
version: 'ipv4' or 'ipv6'
protocol: 'ftp'
```
#### Properties
* Required
```bash
category: 'address'
property: 'domain' or 'ip'
```
* Optional
```bash
category: 'option'
property: 'file-path'
# Default: cyberengine
# Example: /var/log/messages
# Note: Users usually start in home directory so 'cyberengine' is really /home/<user>/cyberengine if not chrooted
# Note: ~/file will not work
```


### POP3 Login Check
* checks/ipv4/pop3-login.rb
* checks/ipv6/pop3-login.rb
#### Service
```bash
name: 'POP3 Login'
version: 'ipv4' or 'ipv6'
protocol: 'pop3'
```
#### Properties
* Required
```bash
category: 'address'
property: 'domain' or 'ip'
```


### SMTP Send Mail Check
* checks/ipv4/smtp-send-mail.rb
* checks/ipv6/smtp-send-mail.rb
#### Service
```bash
name: 'SMTP Send Mail'
version: 'ipv4' or 'ipv6'
protocol: 'smtp'
```
#### Properties
* Required
```bash
category: 'address'
property: 'domain' or 'ip'
```
```bash
category: 'option'
property: 'from-domain'
# Mail domain: --mail-from username@<from-domain>
# If no rcpt-domain is specified this domain is also used for the rcpt-user
```
* Optional
* Note: Without rcpt-user and rcpt-domain the destination email address defaults to user for the same service (aka: internal email). Only set these if you want outbound mail (Example: whiteteam@whiteteam.ists)
```bash
category: 'option'
property: 'rcpt-user'
# Default: whiteteam if no users otherwise a random user
```
```bash
category: 'option'
property: 'rcpt-domain'
# Default: from-domain
```


### DNS Forward Check
* checks/ipv4/dns-forward.rb
* checks/ipv6/dns-forward.rb
#### Service
```bash
name: 'DNS Forward'
version: 'ipv4' or 'ipv6'
protocol: 'dns'
```
#### Properties
* Required
```bash
category: 'address'
property: 'domain' or 'ip'
```
```bash
category: 'random'
property: 'domain'
# Domain to check
# Example value: 'google-public-dns-a.google.com'
```
```bash
category: 'answer'
property: <domain>  # 'google-public-dns-a.google.com'
# Address domain should resolve too
# Example value: '8.8.8.8'
```
