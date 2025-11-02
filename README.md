
# Shodan WP Finder

A powerful and fast WordPress discovery tool using Shodan search engine results. (Shodan API required)
<img width="526" height="235" alt="Screenshot From 2025-11-02 19-06-31" src="https://github.com/user-attachments/assets/5deb1c04-be9f-4375-9ce1-6311ecdd747f" />

## Features

- Automatically detects WordPress sites via Shodan search
- Filters out cloud infrastructure hostnames for cleaner results
- Live URL validation using parallel `curl` requests
- Optional flags:
  - `--keep-ips` → include raw IP hosts
  - `--keep-cloud` → include cloud reverse-DNS hosts
- Saves only **live** WordPress URLs
- Clean and optimized for Kali Linux and penetration testing environments 
- Works on Kali Linux- Nethunter, Termux.

## Requirements

- Shodan CLI  
- Bash  
- curl

### Install Shodan CLI

```bash
pip install shodan
shodan init YOUR_API_KEY
```

## Usage

Default (clean output — human domains only):

```bash
./wpfinder.sh
```

Include IP addresses:

```bash
./wpfinder.sh --keep-ips
```

Include cloud/infra hosts:

```bash
./wpfinder.sh --keep-cloud
```

Include everything:

```bash
./wpfinder.sh --keep-ips --keep-cloud
```

## Output

Results are stored in:

```
wordpress_live_YYYYMMDD_HHMMSS.txt
```

Only **working** WordPress URLs are included.

## Disclaimer

This tool is for **security research and authorized penetration testing only**.  
Do not scan or interact with systems without explicit permission, not that we ever listen to that :).

## Wanna contribute?

Feel free to hit me up on instagram. Any help or recommendations are welcome! :)
---

### Scrambled togheter by  
X3RX3S / [@mindfuckerrrr](https://instagram.com/mindfuckerrrr)  


