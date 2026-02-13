#!/bin/bash
# Deployment ID: ${deployment_id}

# --- Robust Logging Setup ---
LOG_FILE="/var/log/user_data.log"
exec > >(tee -a $LOG_FILE /var/log/cloud-init-output.log) 2>&1

echo "--- User Data Script Started: $(date) ---"

# Exit on error, undefined variables, or pipe failures
set -euo pipefail

# Update and Install Docker
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Setup App Directory
echo "Setting up application directory..."
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Write Database Init SQL (Injected by Terraform)
echo "Writing init.sql..."
cat <<'INIT_SQL_EOF' > init.sql
${init_sql_content}
INIT_SQL_EOF

# Write Nginx Configuration
echo "Writing nginx.conf..."
cat <<'NGINX_EOF' > nginx.conf
server {
    listen 80;
    
    location / {
        proxy_pass http://frontend:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /api {
        proxy_pass http://backend:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location /health {
        proxy_pass http://backend:3000/health;
        proxy_set_header Host $host;
    }
}
NGINX_EOF

# Write Docker Compose File
echo "Writing docker-compose.yml..."
cat <<EOF > docker-compose.yml
services:
  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${postgres_user}
      POSTGRES_PASSWORD: ${postgres_password}
      POSTGRES_DB: ${postgres_db}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql

  backend:
    image: ${backend_image}
    restart: unless-stopped
    depends_on:
      - postgres
    environment:
      PORT: 3000
      PG_USER: ${postgres_user}
      PG_PASSWORD: ${postgres_password}
      PG_DATABASE: ${postgres_db}
      PG_HOST: postgres
      PG_PORT: 5432
    ports:
      - "3000:3000" 

  frontend:
    image: ${frontend_image}
    restart: unless-stopped
    depends_on:
      - backend
    ports:
      - "8080:80" 

  proxy:
    image: nginx:alpine
    restart: always
    ports:
      - "80:80"
    volumes:
      - ./nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - backend
      - frontend

volumes:
  postgres_data:
EOF

# Ensure Docker is fully up before proceeding
echo "Waiting for Docker daemon..."
sleep 5

# Explicitly pull the versions of the images
echo "Pulling images..."
sudo docker compose pull

# Start Services
echo "Starting services..."
sudo docker compose up -d

echo "--- User Data Script Completed: $(date) ---"
