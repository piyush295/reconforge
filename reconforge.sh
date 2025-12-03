#!/bin/bash

TARGET=$1

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target-domain>"
    exit 1
fi

DATE=$(date +%F)
WORKDIR="reconforge_${TARGET}_${DATE}"

mkdir -p $WORKDIR/{subs,alive,urls,ports,vulns,extras}

echo "[*] ReconForge initialized for $TARGET"
echo "[*] Workspace: $WORKDIR"

#######################
# 1. SUBDOMAIN ENUM
#######################
echo "[*] Running subdomain enumeration..."

subfinder -d $TARGET -all -recursive -o $WORKDIR/subs/subfinder.txt
assetfinder $TARGET | tee $WORKDIR/subs/assetfinder.txt
amass enum -passive -d $TARGET -o $WORKDIR/subs/amass.txt 2>/dev/null || echo "[!] amass not found or failed, skipping."

cat $WORKDIR/subs/*.txt | sort -u > $WORKDIR/subdomains.txt

#######################
# 2. DNS RESOLUTION
#######################
echo "[*] Resolving valid domains with dnsx..."

dnsx -l $WORKDIR/subdomains.txt -silent -o $WORKDIR/alive/resolved.txt

#######################
# 3. PROBE HTTP(S)
#######################
echo "[*] Probing alive HTTP services with httpx..."

httpx -l $WORKDIR/alive/resolved.txt -silent -threads 200 \
     -o $WORKDIR/alive/httpx.txt

#######################
# 4. PORT SCANNING
#######################
echo "[*] Running Naabu port scan..."

naabu -list $WORKDIR/alive/resolved.txt -top-ports 100 \
      -o $WORKDIR/ports/naabu.txt

#######################
# 5. URL COLLECTION
#######################
echo "[*] Collecting URLs with Katana, gau, waybackurls..."

katana -list $WORKDIR/alive/httpx.txt -silent -o $WORKDIR/urls/katana.txt

gau $TARGET > $WORKDIR/urls/gau.txt 2>/dev/null || echo "[!] gau failed, skipping."
waybackurls $TARGET > $WORKDIR/urls/wayback.txt 2>/dev/null || echo "[!] waybackurls failed, skipping."

cat $WORKDIR/urls/*.txt | sort -u > $WORKDIR/urls/all_urls.txt

#######################
# 6. PARAM DISCOVERY
#######################
echo "[*] Extracting parameterized URLs..."

cat $WORKDIR/urls/all_urls.txt | grep "=" > $WORKDIR/urls/params.txt || touch $WORKDIR/urls/params.txt

#######################
# 7. NUCLEI SCAN
#######################
echo "[*] Launching Nuclei scanning (critical/high/medium)..."

nuclei -l $WORKDIR/alive/httpx.txt \
       -severity critical,high,medium \
       -o $WORKDIR/vulns/nuclei_hosts.txt

nuclei -l $WORKDIR/urls/all_urls.txt \
       -severity critical,high,medium \
       -o $WORKDIR/vulns/nuclei_urls.txt

#######################
# 8. SHODAN ENRICHMENT (optional)
#######################
echo "[*] Enriching with Shodan (if configured)..."

if command -v shodan >/dev/null 2>&1; then
  for ip in $(cut -d '/' -f 3 $WORKDIR/alive/httpx.txt | sed 's/:.*//' | sort -u); do
      shodan host $ip >> $WORKDIR/extras/shodan.txt
  done
else
  echo "[!] Shodan CLI not installed, skipping."
fi

echo "[*] ReconForge completed. Output stored in $WORKDIR/"
