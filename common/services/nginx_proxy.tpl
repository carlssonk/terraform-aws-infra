#!/bin/bash

sudo yum update -y
sudo yum install -y nginx

# Create nginx config
sudo tee /etc/nginx/nginx.conf <<'EOF'
events {
    worker_connections 1024;
}

http {
    map $http_host $upstream {
        hostnames;
        %{ for domain, backend in services_map ~}
        ${domain} ${backend};
        %{ endfor ~}
    }
    
    server {
        listen 80;
        server_name ${server_name};

        resolver ${dns_resolver_ip};

        location / {
            proxy_pass http://$upstream;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
}
EOF

# Restart NGINX to apply changes
sudo systemctl restart nginx