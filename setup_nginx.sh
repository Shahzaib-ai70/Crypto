#!/bin/bash

# Stop script on error
set -e

echo "=========================================="
echo "   Bitsafe Nginx Auto-Configurator        "
echo "=========================================="

# 1. Install Nginx (if missing)
echo "[1/4] Checking Nginx..."
if ! command -v nginx &> /dev/null; then
    apt-get update
    apt-get install -y nginx
fi

# 2. Backup Default Config
echo "[2/4] Backing up default config..."
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/default.bak || true
fi

# 3. Create New Config
echo "[3/4] Creating new Nginx config..."
cat > /etc/nginx/sites-available/bitsafe <<EOF
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

# Link the config
ln -sf /etc/nginx/sites-available/bitsafe /etc/nginx/sites-enabled/

# 4. Restart Nginx
echo "[4/4] Restarting Nginx..."
nginx -t
systemctl restart nginx

echo "=========================================="
echo "   NGINX CONFIG SUCCESSFUL!               "
echo "=========================================="
echo "You can now access your site at: http://YOUR_VPS_IP"
