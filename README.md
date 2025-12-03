# ReconForge  
Automated Reconnaissance Pipeline for Security Researchers

ReconForge is a lightweight, fast, and efficient Bash-based reconnaissance framework designed for penetration testers and bug bounty hunters.  
It integrates Subfinder, HTTPx, Katana, and Nuclei into a seamless end-to-end workflow for asset discovery and vulnerability scanning.

This project is built to simplify recon, automate repetitive tasks, and generate clean, structured output for further analysis.

---

## 🚀 Features

- Automated recon workflow
- Subdomain enumeration
- HTTP/S probing for live hosts
- URL crawling & discovery
- Vulnerability scanning with Nuclei
- Organized output directory with timestamp
- Simple one-script execution
- Easy installation via `requirements.sh`

---

## 🧩 Tools Used

ReconForge relies on the following tools:

- **Subfinder** – Passive subdomain enumeration  
- **HTTPx** – Probe HTTP services & gather metadata  
- **Katana** – High-performance web crawler  
- **Nuclei** – Vulnerability scanning engine  

These must be installed before running the script.

---

## 📦 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/piyush295/reconforge
cd reconforge
chmod +x requirements.sh
./requirements.sh
./reconforge.sh example.com
