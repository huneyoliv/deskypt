import json
import re

print("Searching YPT Completo.har...")
with open("YPT Completo.har", "r", encoding="utf-8", errors="ignore") as f:
    har_text = f.read()

urls = set(re.findall(r'https://[a-zA-Z0-9\.\-_/]+', har_text))

print("Found URLs in HAR:")
for url in sorted(urls):
    if "tgclab.com" in url:
        print(url)
