#!/bin/bash
set -e

echo "======================================"
echo "Ubuntu Server Setup for AI Stack"
echo "======================================"
echo

# 1. System update
echo "[1/9] Updating system packages..."
apt-get update && apt-get upgrade -y
echo "✓ System updated"

# 2. Install basic utilities
echo
echo "[2/9] Installing basic utilities..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    git \
    wget \
    htop \
    net-tools \
    ufw
echo "✓ Basic utilities installed"

# 3. Install Docker
echo
echo "[3/9] Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
echo "✓ Docker installed"

# 4. Install Docker Compose
echo
echo "[4/9] Installing Docker Compose..."
DOCKER_COMPOSE_VERSION="v2.24.0"
curl -SL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "✓ Docker Compose ${DOCKER_COMPOSE_VERSION} installed"

# 5. Configure Docker to start on boot
echo
echo "[5/9] Configuring Docker service..."
systemctl enable docker
systemctl start docker
echo "✓ Docker service configured"

# 6. Add current user to docker group
echo
echo "[6/9] Adding user to docker group..."
usermod -aG docker "$USER"
echo "✓ User added to docker group (re-login required)"

# 7. Enable firewall (optional, secure setup)
echo
echo "[7/9] Configuring firewall (basic setup)..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw allow 3080/tcp
ufw --force enable
echo "✓ Firewall configured (ports 22, 3080 open)"

# 8. Create necessary directories
echo
echo "[8/9] Creating project directories..."
mkdir -p /home/"$USER"/ai-stack
chown "$USER":"$USER" /home/"$USER"/ai-stack
echo "✓ Project directories created"

# 9. Verify installation
echo
echo "[9/9] Verifying installation..."
docker --version
docker-compose --version
echo "✓ Installation verified"

echo
echo "======================================"
echo "Setup Complete!"
echo "======================================"
echo
echo "Next steps:"
echo "1. Re-login or run: newgrp docker"
echo "2. Copy your ai-stack project to /home/$USER/ai-stack"
echo "3. Navigate to the project folder and run:"
echo "   docker compose up -d"
echo
