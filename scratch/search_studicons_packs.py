import json

print("Searching Studicon packs in HAR...")
with open("YPT Completo.har", "r", encoding="utf-8", errors="ignore") as f:
    data = json.load(f)

entries = data.get("log", {}).get("entries", [])
for entry in entries:
    req = entry.get("request", {})
    url = req.get("url", "")
    method = req.get("method", "")
    
    if "studicon" in url.lower() or "store" in url.lower():
        print(f"=== {method} {url} ===")
        res = entry.get("response", {}).get("content", {}).get("text", "")
        if res and len(res) < 1000:
            print("Response Snippet:", res)
        elif res:
            print("Response Snippet:", res[:400])
        print()
