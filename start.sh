#!/bin/bash

# Colors and styles
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color
BOLD=$(tput bold)
NORMAL=$(tput sgr0)

# Emojis
ROCKET="🚀"
GEAR="⚙️"
CHECK="✅"
WARN="⚠️"
INSTALL="📦"
NODE="⬢"
CHROME="🌐"
ERROR="❌"
INFO="ℹ️"
HAPPY="😊"
SCAN="📱"
SERVER="🖥️"

# Function to display status messages
status() {
  echo -e "\n${PURPLE}${GEAR} ${BOLD}${1}${NORMAL}${NC}"
}

# Function to display success messages
success() {
  echo -e "${GREEN}${CHECK} ${1}${NC}"
}

# Function to display warnings
warning() {
  echo -e "${YELLOW}${WARN} ${1}${NC}"
}

# Function to display errors
error() {
  echo -e "${RED}${ERROR} ${1}${NC}"
}

# Header
echo -e "${BLUE}"
echo -e "╔════════════════════════════════════════════════╗"
echo -e "║    ${ROCKET} ${BOLD}WhatsApp Web JS API - Installation${NORMAL} ${ROCKET}    ║"
echo -e "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

# Installation confirmation
echo -e "${CYAN}${BOLD}This script will:${NORMAL}"
echo -e "  ${INSTALL} Update system packages"
echo -e "  ${INSTALL} Install required dependencies"
echo -e "  ${CHROME} Install Chromium browser"
echo -e "  ${NODE} Install Node.js LTS"
echo -e "  ${INSTALL} Install npm packages"
echo -e "  ${SERVER} Start the WhatsApp API server\n"

read -p "Do you want to continue? [y/N]" yn
case $yn in
  [Yy]* ) ;;
  * ) 
    echo -e "\n${RED}${ERROR} Installation cancelled${NC}"
    exit 0
    ;;
esac

# 1. Update system
status "1. Updating system packages..."
sudo apt-get update && sudo apt-get upgrade -y
success "System updated successfully!"

# 2. Install system dependencies
status "2. Installing system dependencies..."
sudo apt-get install -y \
  curl \
  wget \
  unzip \
  libxss1 \
  libappindicator1 \
  libindicator7 \
  fonts-liberation \
  xdg-utils
success "Dependencies installed successfully!"

# 3. Install Chromium
status "3. Installing Chromium browser..."
if ! command -v chromium-browser >/dev/null 2>&1; then
  sudo apt-get install -y chromium-browser
  success "Chromium installed successfully!"
else
  warning "Chromium is already installed: $(chromium-browser --version | head -n 1)"
fi

# 4. Install Node.js
status "4. Installing Node.js..."
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt-get install -y nodejs
  success "Node.js $(node -v) installed successfully!"
  success "npm $(npm -v) installed successfully!"
else
  warning "Node.js is already installed: $(node -v)"
fi

# 5. Install npm packages
status "5. Installing npm packages..."
npm install
if [ $? -eq 0 ]; then
  success "npm packages installed successfully!"
else
  error "Failed to install npm packages!"
  exit 1
fi

# Final information
echo -e "\n${GREEN}"
echo -e "╔════════════════════════════════════════════════╗"
echo -e "║    ${CHECK} ${BOLD}Installation completed successfully!${NORMAL} ${HAPPY}  ║"
echo -e "╚════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}${BOLD}Next steps:${NORMAL}"
echo -e "  ${SCAN} First time? You'll need to scan the WhatsApp QR code"
echo -e "  ${SERVER} Server will start automatically\n"

# Start the server
status "Starting WhatsApp API server..."
echo -e "${YELLOW}${WARN} Press Ctrl+C to stop the server${NC}\n"

npm run start
