#!/bin/bash
(echo 'US'; echo 'New York'; echo 'Rochester'; echo 'SPARSA'; echo 'ISTS'; echo '*'; echo 'nobody@cyberengine.ists';) | openssl req -new -x509 -nodes -out ssl_certificate.pem -keyout ssl_certificate.pem
echo ''
echo ''
echo 'SSL certificate and key placed in: ssl_certificate.pem'
echo ''
