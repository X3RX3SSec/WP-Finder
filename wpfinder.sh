#!/bin/bash
# Yes, It is always good to check the code before use! :D
MAGENTA="\033[1;35m"
GREEN="\033[1;32m"
RESET="\033[0m"

echo -e "${MAGENTA}"
cat << "EOF"
    ___       _________       ______________       _________
    __ |     / /__  __ \      ___  ____/__(_)____________  /____________
    __ | /| / /__  /_/ /________  /_   __  /__  __ \  __  /_  _ \_  ___/
    __ |/ |/ / _  ____/_/_____/  __/   _  / _  / / / /_/ / /  __/  /
    ____/|__/  /_/            /_/      /_/  /_/ /_/\__,_/  \___//_/
EOF

echo -e "${GREEN}  Shodan WP Finder By X3RX3S [@mindfuckerrrr] https://github.com/X3RX3SSec${RESET}"
echo -e "           A simple tool for finding WordPress powered sites."
echo -e " "

QUERY='http.html:"wp-content"'
LIMIT=500
THREADS=30

KEEP_IPS=false
KEEP_CLOUD=false

for arg in "$@"; do
  case $arg in
    --keep-ips) KEEP_IPS=true ;;
    --keep-cloud) KEEP_CLOUD=true ;;
  esac
done

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RAW_RESULTS="raw_$TIMESTAMP.txt"
OUTPUT_FILE="wordpress_live_$TIMESTAMP.txt"

mkdir -p logs
LOG_FILE="logs/log_$TIMESTAMP.txt"

if ! shodan info &>/dev/null; then
  echo "[!] Run: shodan init YOUR_API_KEY" | tee -a "$LOG_FILE"
  exit 1
fi
# Looking for b( • )( • )bies ??? You found them!
echo "[*] Querying Shodan..." | tee -a "$LOG_FILE"
shodan search --fields hostnames,ip_str,port "$QUERY" --limit "$LIMIT" > "$RAW_RESULTS"

echo "[*] Extracting URLs..." | tee -a "$LOG_FILE"
> temp_urls.txt

while IFS=$'\t' read -r hostnames ip port; do
  [[ -z "$hostnames" ]] && hostnames="$ip"
  IFS=';' read -ra domains <<< "$hostnames"
  for domain in "${domains[@]}"; do
    proto="http"; [[ "$port" == "443" ]] && proto="https"
    url="$proto://$domain"

    if [[ "$domain" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      $KEEP_IPS || continue
    fi

    if [[ "$domain" =~ (amazonaws\.com|vultrusercontent\.com|poneytelecom\.eu|your-server\.de|ip-[0-9]|rev-|hostwindsdns\.com|accessdomain\.com) ]]; then
      $KEEP_CLOUD || continue
    fi

    echo "$url" >> temp_urls.txt
  done
done < "$RAW_RESULTS"

TOTAL=$(wc -l < temp_urls.txt)
echo "[*] After filtering: $TOTAL candidate domains" | tee -a "$LOG_FILE"

echo "[*] Validating live hosts..." | tee -a "$LOG_FILE"
> "$OUTPUT_FILE"
export OUTPUT_FILE

cat temp_urls.txt | xargs -P "$THREADS" -I {} bash -c '
  url="$1"
  host=$(echo "$url" | awk -F[/:] "{print \$4}")
  status=$(curl -s -o /dev/null -w "%{http_code}" -H "Host: $host" --connect-timeout 7 --max-time 10 "$url")
  if [[ "$status" == "200" || "$status" == "301" || "$status" == "302" ]]; then
    echo "$url" >> "$OUTPUT_FILE"
  fi
' _ {}

FINAL=$(wc -l < "$OUTPUT_FILE")
echo "[✓] Found $FINAL live WordPress domains"
echo "[✓] Saved to: $OUTPUT_FILE"

rm -f temp_urls.txt "$RAW_RESULTS"

