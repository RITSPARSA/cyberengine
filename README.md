# Introduction

Scoringengine is the combination of a Ruby on Rails web front-end and backend service checks. Cyberengine is designed to check and score common network services used in "blueteam-redteam-whiteteam" competitions and provide a web interface for teams about their servers and services.


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

[Installation Steps on Wiki](https://github.com/pwnbus/scoringengine-website/wiki)


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
* Database connection setup - default: MySQL - Username: cyberengine - Password: cyberengine


## Checks
* Please see [cyberengine-checks](https://github.com/griffithchaffee/cyberengine-checks)

#### Defaults
* All defaults are defined under whiteteam. These defaults are used if they are not defined for a team. The most common example is the timeout property which specifies after how many seconds a check should be cancled.
* Typically answer properties are also defined at the whiteteam level but can be overridden per team. There are two common types of answer properties: full-text-regex and each-line-regex. If either of these match the check is deemed to pass. DNS is one service that does not use this, instead domain answers are defined on a per team level.
* Majority of checks use unix command line tools such as curl. This is to make it easier to debug. While many could be completly written using a language library, it would be difficult to troubleshoot errors for both blueteams and whiteteam.


## License
Cyberengine is released under the [MIT License](http://www.opensource.org/licenses/MIT)
