#!/bin/bash

# Stop script on error
set -e

echo "=========================================="
echo "   Bitsafe VPS Auto-Installer & Deployer  "
echo "=========================================="

# 1. System Updates
echo "[1/6] Updating system packages..."
apt-get update -y
apt-get install -y curl git build-essential

# 2. Install Node.js (v18 LTS)
echo "[2/6] Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
else
    echo "Node.js is already installed: $(node -v)"
fi

# 3. Install PM2 Global
echo "[3/6] Installing PM2 Process Manager..."
npm install -g pm2

# 4. Project Setup
echo "[4/6] Installing Project Dependencies..."
# Install root deps
if [ -f "package.json" ]; then
    npm install
fi

# Install server deps
cd server
npm install
cd ..

# 5. Start Server with PM2
echo "[5/6] Starting Server..."
# Delete existing process if it exists to ensure fresh start
pm2 delete bitsafe-server 2>/dev/null || true

# Start server/index.js
pm2 start server/index.js --name "bitsafe-server"

# 6. Save Configuration
echo "[6/6] Saving PM2 Configuration..."
pm2 save
pm2 startup | grep "sudo" | bash # Try to auto-execute startup command if possible

echo "=========================================="
echo "   DEPLOYMENT SUCCESSFUL!                 "
echo "=========================================="
echo "Your app is running on port 3001."
echo "To view logs: pm2 logs bitsafe-server"
