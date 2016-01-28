namespace :cyberengine do
  task :apache => :environment do

    environment = Rails.env
    cyberengine_dir = File.expand_path(__FILE__).split('/')[1..-4].join('/').prepend('/')
    cyberengine_public_dir = cyberengine_dir + '/public'
    cyberengine_ssl_certificate = cyberengine_dir + '/config/ssl_certificate.pem'
    apache_document_dir = File.expand_path(__FILE__).split('/')[1..-5].join('/').prepend('/')
    apache_log_dir = cyberengine_dir + '/log'

    ip_address = "FILL_ME_IN"
    passenger_mod = "FILL_ME_IN"
    passenger_dir = "FILL_ME_IN"
    ruby = "FILL_ME_IN"

httpd_conf = %Q[
Listen 80
Listen 443

User apache
Group apache

# Signature
ServerTokens Prod
ServerSignature off

# Logging
logformat "%h -> %v %>s %u %m %U - %q" shortformat
logformat "%h -> %v %>s %u %r - '%{User-Agent}i' '%{Referer}i' %t %b \\r\\n" longformat
customlog #{apache_log_dir}/apache_short.log shortformat env=!staticfiles
customlog #{apache_log_dir}/apache_long.log longformat
errorlog #{apache_log_dir}/apache_error.log

# Modules
LoadModule actions_module modules/mod_actions.so
LoadModule alias_module modules/mod_alias.so
LoadModule auth_digest_module modules/mod_auth_digest.so
LoadModule dir_module modules/mod_dir.so
LoadModule env_module modules/mod_env.so
LoadModule log_config_module modules/mod_log_config.so
LoadModule mime_module modules/mod_mime.so
LoadModule negotiation_module modules/mod_negotiation.so
LoadModule setenvif_module modules/mod_setenvif.so
LoadModule status_module modules/mod_status.so

# SSL
LoadModule ssl_module modules/mod_ssl.so
SSLCertificateFile #{cyberengine_ssl_certificate}
SSLCertificateKeyFile #{cyberengine_ssl_certificate}

# Errors - normally handled by rails app
ErrorDocument 400 "<h1>400 Bad Request</h1>"
ErrorDocument 403 "<h1>403 Access Denied</h1>"
ErrorDocument 404 "<h1>404 Not Found</h1>"
ErrorDocument 500 "<h1>500 Server Error</h1>"
ErrorDocument 503 "<h1>503 Service Unavailable</h1>"

# Passenger Configuration
LoadModule passenger_module #{passenger_mod}
<IfModule mod_passenger.c>
  PassengerRoot #{passenger_dir}
  PassengerDefaultRuby #{ruby}
</IfModule>

<VirtualHost *:80>
  RailsEnv #{environment}

  ServerName #{ip_address}
  ServerAlias #{ip_address}

  DocumentRoot #{cyberengine_public_dir}
  <Directory #{cyberengine_public_dir}>
     AllowOverride all
     Options -MultiViews
     Require all granted
  </Directory>
</VirtualHost>
<VirtualHost *:443>
  SSLEngine on
  RailsEnv #{environment}

  ServerName #{ip_address}
  ServerAlias https://#{ip_address}

  DocumentRoot #{cyberengine_public_dir}
  <Directory #{cyberengine_public_dir}>
     AllowOverride all
     Options -MultiViews
     Require all granted
  </Directory>
</VirtualHost>
]

    puts httpd_conf
  end
end

