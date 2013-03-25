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
# Disable selinux
sed -i 's/^/#/g' /etc/selinux/config
echo 'SELINUX=disabled' >> /etc/selinux/config
echo 'SELINUXTYPE=targeted' >> /etc/selinux/config
# Dont need iptables messing things up for now
systemctl stop iptables.service
systemctl disable iptables.service
reboot
```

2. Install all required packages for: checks, rvm/ruby, database, and apache
```bash
# Basic/Checks
yum install -y bash tar git curl curl-devel vim bind-utils iputils iproute
# RVM/Ruby (copied from: rvm requirements) 
yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison iconv-devel
# Database
yum install -y postgresql postgresql-devel postgresql-server
# Apache
yum install -y httpd httpd-devel apr-devel apr-util-devel mod_ssl
```

3. Install ruby (version >= 1.9.3) via Ruby Version Manager (RVM) - https://rvm.io/rvm/install
```bash
curl -kL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm install 1.9.3 --verify-downloads 1
rvm use 1.9.3 --default
# Answer yes to any 'cp: overwrite' options
```

4. Setup database
```bash
postgresql-setup initdb
# Enable/start server
systemctl enable postgresql.service
systemctl start postgresql.service
# Create cyberengine user/password (cyberengine:cyberengine) - change password in competition
# If password changed, rails file config/database.yml will have to be updated
su postgres
psql -c "CREATE ROLE cyberengine PASSWORD 'cyberengine' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN"
exit
# Expected output:
# could not change directory to "/root"
# CREATE ROLE
# Listen on all interfaces
echo "listen_addresses = '*'" >> /var/lib/pgsql/data/postgresql.conf 
# Comment out all current lines in pg access file
sed -i 's/^/#/g' /var/lib/pgsql/data/pg_hba.conf
# Allow valid username/password combinations access via sockets (localhost)
echo 'local all all md5' >> /var/lib/pgsql/data/pg_hba.conf 
# Allow valid username/password combinations access via tcp/ip
echo 'host all all  0.0.0.0/0 md5' >> /var/lib/pgsql/data/pg_hba.conf 
echo 'host all all  ::/0 md5' >> /var/lib/pgsql/data/pg_hba.conf 
# Restart server for new permissions to take effect
# cyberengine user is now super user for postgresql server
systemctl restart postgresql.service
```

5. Download cyberengine and install gems (libraries)
```bash
mkdir -p /var/rails
cd /var/rails
git clone -v https://github.com/griffithchaffee/cyberengine.git
# If you dont do this you may get permission errors
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
# This command compiles mod_passenger.so
passenger-install-apache2-module
# Press <enter> and go through installation
# Ignore ending apache configuration hints
# Generate httpd.conf file
cp /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig
rake cyberengine:apache > /etc/httpd/conf/httpd.conf
# SUPER IMPORTANT - apache must own everything
chown -R apache:apache /var/rails/cyberengine 
# Start apache
# Troubleshoot any errors with /var/log/messages and /var/rails/cyberengine/log/apache_error.log
service httpd start
```

7. Optional: Run in production mode. By default rails runs in development mode where logs are verbose, files not compressed, and nothing is cached. Production mode compiles all HTTP/JS/CSS files and compresses them for performance and caching is used. 300ms loadtimes become 30ms.
```bash
service httpd stop
# Add production data
RAILS_ENV=production rake cyberengine:setup
# Change apache configuration to run in production mode (replaces RailsEnv option)
RAILS_ENV=production rake cyberengine:apache > /etc/httpd/conf/httpd.conf
# Compiles assets into public/assests 
RAILS_ENV=production rake assets:precompile
# SUPER IMPORTANT - apache must own everything. Compiled assets in public/assets are owned by root by default and will cause errors.
chown -R apache:apache /var/rails/cyberengine 
# Start apache back up in production
service httpd start
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
* Please see [cyberengine-checks](https://github.com/griffithchaffee/cyberengine-checks)

#### Defaults
* All defaults are defined under whiteteam. These defaults are used if they are not defined for a team. The most common example is the timeout property which specifies after how many seconds a check should be cancled.
* Typically answer properties are also defined at the whiteteam level but can be overridden per team. There are two common types of answer properties: full-text-regex and each-line-regex. If either of these match the check is deemed to pass. DNS is one service that does not use this, instead domain answers are defined on a per team level.
* Majority of checks use unix command line tools such as curl. This is to make it easier to debug. While many could be completly written using a language library, it would be difficult to troubleshoot errors for both blueteams and whiteteam.


## License
Cyberengine is released under the [MIT License](http://www.opensource.org/licenses/MIT)
