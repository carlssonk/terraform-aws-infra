
#!/bin/bash

yum update -y
yum install -y nginx certbot python3-certbot-nginx

# Create nginx config
tee /etc/nginx/nginx.conf <<EOF
events {
    worker_connections 1024;
}

http {

    map $http_host $upstream {
        hostnames;
        %{ for domain, backend in services_map ~}
        ${domain} ${backend};
        %{ endfor ~}
        default default_backend;
    }

    server {
        listen 80;
        server_name _;
        return 301 https://$host$request_uri;
    }

    server {
        listen 443 ssl;
        server_name _;

        %{ for domain in root_domains ~}
        ssl_certificate /etc/letsencrypt/live/${domain}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${domain}/privkey.pem;
        %{ endfor ~}

        # Improve SSL settings
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

        location / {
            proxy_pass http://$upstream;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF

# Obtain SSL certificate
certbot --nginx -d ${certbot_domains} --non-interactive --agree-tos -m oliver@carlssonk.com

# Ensure Certbot auto-renewal is enabled
systemctl enable certbot.timer
systemctl start certbot.timer

# Restart NGINX to apply changes
if systemctl is-active --quiet nginx; then
    systemctl reload nginx
else
    systemctl start nginx
    systemctl enable nginx
fi