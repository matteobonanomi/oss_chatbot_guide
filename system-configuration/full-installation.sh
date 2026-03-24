#!/bin/bash
set -e

echo "======================================"
echo "Full Installation Script for AI Stack"
echo "======================================"
echo

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Step 1: Run Ubuntu setup script
echo "[Step 1/5] Running Ubuntu setup..."
echo "======================================"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UBUNTU_SETUP_SCRIPT="${SCRIPT_DIR}/system-configuration/ubuntu-setup.sh"

if [ -f "$UBUNTU_SETUP_SCRIPT" ]; then
    bash "$UBUNTU_SETUP_SCRIPT"
    echo "✓ Ubuntu setup completed"
else
    echo "Error: Ubuntu setup script not found at $UBUNTU_SETUP_SCRIPT"
    exit 1
fi
echo

# Step 2: Clone the repository
echo "[Step 2/5] Cloning oss_chatbot_guide repository..."
echo "======================================"
cd /home/"$SUDO_USER"
if [ -d "/home/$SUDO_USER/oss_chatbot_guide" ]; then
    echo "Repository already exists, pulling latest changes..."
    cd /home/"$SUDO_USER"/oss_chatbot_guide
    git pull
else
    git clone https://github.com/matteobonanomi/oss_chatbot_guide.git
    cd /home/"$SUDO_USER"/oss_chatbot_guide
fi
echo "✓ Repository cloned/updated"
echo

# Step 3: Copy configuration files
echo "[Step 3/5] Copying configuration files..."
echo "======================================"
ENV_SOURCE="/home/$SUDO_USER/ai-stack/.env"
LIBRECHAT YAML_SOURCE="/home/$SUDO_USER/ai-stack/librechat.yaml"

if [ -f "$ENV_SOURCE" ]; then
    cp "$ENV_SOURCE" /home/"$SUDO_USER"/oss_chatbot_guide/.env
    echo "✓ .env copied"
else
    echo "Warning: .env not found at $ENV_SOURCE"
fi

if [ -f "$LIBRECHAT_YAML_SOURCE" ]; then
    cp "$LIBRECHAT_YAML_SOURCE" /home/"$SUDO_USER"/oss_chatbot_guide/librechat.yaml
    echo "✓ librechat.yaml copied"
else
    echo "Warning: librechat.yaml not found at $LIBRECHAT_YAML_SOURCE"
fi

CHOWN -R "$SUDO_USER":"$SUDO_USER" /home/"$SUDO_USER"/oss_chatbot_guide
echo "✓ Configuration files copied"
echo

# Step 4: Pull Docker images
echo "[Step 4/5] Pulling Docker images..."
echo "======================================"
cd /home/"$SUDO_USER"/oss_chatbot_guide
docker compose pull
echo "✓ Docker images pulled"
echo

# Step 5: Start the services
echo "[Step 5/5] Starting services..."
echo "======================================"
docker compose up -d
echo "✓ Services started"
echo

echo "======================================"
echo "Full Installation Complete!"
echo "======================================"
echo
echo "Your AI Stack is now running!"
echo "Access the application at: https://chat.mb_projects.uk"
echo
echo "Useful commands:"
echo "  - Check status:    docker compose ps"
echo "  - View logs:       docker compose logs -f"
echo "  - Stop services:   docker compose down"
echo "  - Restart services: docker compose restart"
echo
