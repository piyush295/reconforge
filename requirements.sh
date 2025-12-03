#!/bin/bash

echo "[*] Installing dependencies for Recon Automation..."

sudo apt update -y
sudo apt install -y git curl build-essential

# Install Go (if missing)
if ! command -v go &> /dev/null; then
    echo "[*] Installing Go..."
    sudo apt install -y golang-go
fi

echo "[*] Setting GOPATH..."
export GOPATH=$HOME/go
export PATH=$PATH:$HOME/go/bin

echo "[*] Installing Subfinder..."
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo "[*] Installing HTTPx..."
go install github.com/projectdiscovery/httpx/cmd/httpx@latest

echo "[*] Installing Katana..."
go install github.com/projectdiscovery/katana/cmd/katana@latest

echo "[*] Installing Nuclei..."
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

echo "[*] Updating Nuclei templates..."
nuclei -update-templates

echo "[*] All tools installed successfully!"
