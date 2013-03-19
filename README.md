# Introduction

Cyberengine is the combination of a Ruby on Rails web front-end and backend service checks. Cyberengine is designed to check and score common network services used in "blueteam-redteam-whiteteam" competitions and provide a web interface for teams about their servers and services.


## Setup Overview

* There are many **Teams** of type _white_, _red_, and _blue_
* A team can have many **Members** 
* **Teams** have many **Servers**
* **Servers** have many **Services** each defining a _protocol_ (dns, ftp, ssh...) and _version_ (ipv4 or ipv6) 
* **Services** have many **Properties** that outline how the **Service** will be checked
* **Properties** include the _address_, timeout period, options, and random options for checks
* **Services** can have many **Users** that have a _username_/ _password_ and are randomly selected in checks
* **Services** have many **Checks** that are _pass_ or _fail_ and provide information about the request/response


## Rails Frontend

The rails frontend is a fully functional application that can authenticate members and provides them access to their teams servers and services. This allows them to view their current status and position in the competition. Whiteteam members have full access to all parts of the application while blueteam members can only access their own information. Teams can update service user's individually or CSV style. 


## Cyberengine Installation Process 
### Tested on a minimal Fedora 17 installation (must be root)

1. Disable selinux

```bash
echo 'SELINUX=disabled' >> /etc/selinux/config
reboot
```

2. Install all required packages for: checks, rvm/ruby, database, and apache

```bash
# Basic/Checks
yum install -y bash tar git curl curl-devel bind-utils
# RVM/Ruby (copied from: rvm requirements) 
yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel
# Database
yum install -y postgresql-server
# Apache
yum install -y httpd httpd-devel apr-devel apr-util-devel mod_ssl
```

3. Install ruby (version >= 1.9.3) via Ruby Version Manager (RVM) - https://rvm.io/rvm/install

```bash
curl -kL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 1.9.3 --verify-downloads 1
rvm use 1.9.3 --default
rvm gemset create cyberengine-checks
rvm gemset create cyberengine
```

4. Setup database

```bash
postgresql-setup initdb
systemctl enable postgresql.service
systemctl start postgresql.service

# Create cyberengine user/password (cyberengine:cyberengine)
su postgres
psql -c "CREATE ROLE cyberengine PASSWORD 'cyberengine' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN"
exit
```

5. Download cyberengine and install gems (libraries)

```bash
mkdir -p /var/rails
cd /var/rails
git clone -v https://github.com/griffithchaffee/cyberengine.git
# If you dont do this you may get permission errors
chown -R apache:apache /var/rails/cyberengine 
cd cyberengine
# Do you wish to trust this .rvmrc file? (/root/cyberengine/.rvmrc)
# y[es], n[o], v[iew], c[ancel]> yes
bundle install
# Creates database tables, redteam, whiteteam, and an example blueteam
rake cyberengine:setup
```

6. Setup apache and mod_passenger. Phusion Passenger contains an apache mod that serves rails applications

```bash
# Documentation: http://www.modrails.com/documentation/Users%20guide%20Apache.html
# Passenger should already be installed from "bundle install", if not run: gem install passenger
# This command quickly compiles mod_passenger.so
passenger-install-apache2-module
# Generate httpd.conf file
cp /etc/httpd/conf/httpd.conf.orig
rake cyberengine:apache > /etc/httpd/conf/httpd.conf
```


## Important files

**config/initializers/cyberengine.rb**
* Cyberengine configuration file
* Define application title (Default: ISTS)
* Define application brand (Default: ISTS)
* Different team permissions can be setup in this file (E.g: allow username updates)

**app/views/static/welcome.html.erb** 
* Basic welcome page
* Should be modified to contain information about competition and sponsors

**config/database.yml**
* Database connection setup - default: PostgreSQL - Username: cyberengine - Password: cyberengine


## Checks

### Properties
* Lowercase with hyphen delimiters

#### Property Categories
```bash
# There are four property categories
# Defines a service address (each check will be run against all addresses)
category: 'address'
# Defines a unique service property (DNS query type: A vs AAAA vs PTR)
category: 'option'
# Defines an property with many options (HTTP useragents)
category: 'random'
# Defines a property used to check for success/failure of a check
category: 'answer'
```


#### Defaults
* All defaults are defined under whiteteam. These defaults are used if they are not defined for a team. The most common example is the timeout property which specifies after how many seconds a check should be cancled.
* Typically answer properties are also defined at the whiteteam level but can be overridden per team. There are two common types of answer properties: full-text-regex and each-line-regex. If either of these match the check is deemed to pass. DNS is one service that does not use this, instead domain answers are defined on a per team level.
* Majority of checks use unix command line tools such as curl. This is to make it easier to debug. While many could be completly written using a language library, it would be difficult to troubleshoot errors for both blueteams and whiteteam.


## Available Checks ##

### DNS Domain Query
* ipv4/dns/domain-query
#### Service
```bash
name: "DNS Domain Query", version: 'ipv4', protocol: 'dns'
```
#### Properties
```bash
category: 'address'
category: 'option', property: 'timeout'
category: 'option', property: 'query-type' # A, AAAA, PTR
category: 'random', property: 'query' # Example value: 'google-public-dns-a.google.com'
category: 'answer', property: '<query-property>' # Example property: google-public-dns-a.google.com', value: '8.8.8.8'
```

### FTP Download
* ipv4/ftp/download
#### Service
```bash
name: "FTP Download", version: 'ipv4', protocol: 'ftp'
```
#### Properties
```bash
# Uses random user
# Macro: $USER replaced with current user
category: 'address'
category: 'option', property: 'timeout'
category: 'option', property: 'filename' # file the check attempts to download. Can be a path such as /var/log/messages
category: 'answer', property: 'each-line-regex'
category: 'answer', property: 'full-text-regex'
```

### FTP Upload
* ipv4/ftp/upload
#### Service
```bash
name: "FTP Upload", version: 'ipv4', protocol: 'ftp'
```
#### Properties
```bash
# Uses random user
# Macro: $USER replaced with current user
category: 'address'
category: 'option', property: 'timeout'
category: 'option', property: 'filename' # file the check attempts to upload
category: 'option', property: 'filename-timestamp' # disabled = no filename timestamp
category: 'answer', property: 'each-line-regex'
category: 'answer', property: 'full-text-regex'
```

### HTTP Available
* ipv4/http/available
#### Service
```bash
name: "HTTP Available", version: 'ipv4', protocol: 'http'
```
#### Properties
```bash
category: 'address'
category: 'option', property: 'timeout'
category: 'random', property: 'useragent'
category: 'random', property: 'uri' # Appended to end of address to form URL
category: 'answer', property: 'each-line-regex'
category: 'answer', property: 'full-text-regex'
```
 
### HTTP Content
* ipv4/http/available
#### Service
```bash
name: "HTTP Content", version: 'ipv4', protocol: 'http'
```
#### Properties
```bash
category: 'address'
category: 'option', property: 'timeout'
category: 'random', property: 'useragent'
category: 'random', property: 'uri' # Appended to end of address to form URL
category: 'answer', property: 'each-line-regex'
category: 'answer', property: 'full-text-regex'
```
 
### HTTPS Available
* ipv4/https/available
#### Service
```bash
name: "HTTPS Available", version: 'ipv4', protocol: 'https'
```
#### Properties
```bash
category: 'address'
category: 'option', property: 'timeout'
category: 'random', property: 'useragent'
category: 'random', property: 'uri' # Appended to end of address to form URL
category: 'answer', property: 'each-line-regex'
category: 'answer', property: 'full-text-regex'
```
 
### HTTPS Content
* ipv4/https/available
#### Service
```bash
name: "HTTPS Content", version: 'ipv4', protocol: 'https'
```
#### Properties
```bash
category: 'address'
category: 'option', property: 'timeout'
category: 'random', property: 'useragent'
category: 'random', property: 'uri' # Appended to end of address to form URL
category: 'answer', property: 'each-line-regex'
category: 'answer', property: 'full-text-regex'
```

### ICMP Ping
* ipv4/icmp/ping
#### Service
```bash
name: "ICMP Ping", version: 'ipv4', protocol: 'icmp'
```
#### Properties
```bash
category: 'address'
category: 'option', property: 'timeout'
category: 'answer', property: 'each-line-regex'
category: 'answer', property: 'full-text-regex'
```

#### POP3 Login
* ipv4/pop3/login
#### Service
```bash
name: "POP3 Login", version: 'ipv4', protocol: 'pop3'
```
#### Properties
```bash
# Uses random user
category: 'address'
category: 'option', property: 'timeout'
category: 'answer', property: 'each-line-regex'
category: 'answer', property: 'full-text-regex'
```

#### SMTP Send Mail
* ipv4/smtp/send-mail
#### Service
```bash
name: "SMTP Send Mail", version: 'ipv4', protocol: 'smtp'
```
#### Properties
```bash
# Uses random user
category: 'address'
category: 'option', property: 'timeout'
category: 'random', property: 'from-domain'
category: 'answer', property: 'each-line-regex'
category: 'answer', property: 'full-text-regex'
# Optional
category: 'random', property: 'rcpt-user' # Defaults to random user
category: 'random', property: 'rcpt-domain' # Defaults to from-domain
category: 'random', property: 'from-user' # Defaults to random user
```
 
#### SSH Login
* ipv4/ssh/login
#### Service
```bash
name: "SSH Login", version: 'ipv4', protocol: 'ssh'
```
#### Properties
```bash
# Uses random user
# Macro: $USER replaced with current user
category: 'address'
category: 'option', property: 'timeout'
category: 'random', property: 'command' # command to execute upon logging in
category: 'answer', property: 'each-line-regex'
category: 'answer', property: 'full-text-regex'
```
