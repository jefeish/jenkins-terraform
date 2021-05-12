#! /usr/bin/bash

apt -y update
# utilities to secure Jenkins
apt -y install certbot python3-certbot-nginx
# network tools like 'netstat'
apt -y install net-tools
# Java JRE
apt -y install default-jre
# Jenkins installation package
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
# install the packages
apt -y install jenkins
apt -y install nginx
# install 'docker' for docker based jenkins agents
apt install docker.io

# remove the site link to 'default'
rm /etc/nginx/sites-enabled/default

# create a new site entry for jenkins
rm /etc/nginx/sites-available/jenkins
cat <<EOF>>/etc/nginx/sites-available/jenkins
server {
    listen 80;
    server_name $(curl http://169.254.169.254/latest/meta-data/public-hostname);

    location / {
        proxy_pass  "http://127.0.0.1:8080";
    }
}

# This is an example of a 'letsencrypt' secured site
# Leave this commented out!
# If you want to secure this installation, follow the instructions on, 
# "https://phoenixnap.com/kb/letsencrypt-nginx"

# upstream jenkins {
#   server 127.0.0.1:8080 fail_timeout=0;
# }

# server {
#     if ($host = jenkins.jefeish.com) {
#         return 301 https://$host$request_uri;
#     } # managed by Certbot


#   listen 80;
#   server_name jenkins.jefeish.com;
#   return 301 https://$host$request_uri;
# }

# server {
#   listen 443 ssl;
#   server_name jenkins.jefeish.com;
#     ssl_certificate /etc/letsencrypt/live/jenkins.jefeish.com/fullchain.pem; # managed by Certbot
#     ssl_certificate_key /etc/letsencrypt/live/jenkins.jefeish.com/privkey.pem; # managed by Certbot

#   location / {
#     proxy_set_header        Host $host:$server_port;
#     proxy_set_header        X-Real-IP $remote_addr;
#     proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
#     proxy_set_header        X-Forwarded-Proto $scheme;
#     # proxy_redirect http:// https://;
#     proxy_redirect http://localhost:8080 https://jenkins.jefeish.com;
#     proxy_pass              http://localhost:8080;
#     # Required for new HTTP-based CLI
#     proxy_http_version 1.1;
#     proxy_request_buffering off;
#     proxy_buffering off; # Required for HTTP-based CLI to work over SSL
#     # workaround for https://issues.jenkins-ci.org/browse/JENKINS-45651
#     add_header 'X-SSH-Endpoint' 'jenkins.domain.tld:50022' always;
#   }

# }
EOF

# create a new site link to 'jenkins'
ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/jenkins

systemctl restart nginx
systemctl start jenkins