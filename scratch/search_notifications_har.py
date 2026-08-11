import json

print("Searching notifications in HAR...")
with open("YPT Completo.har", "r", encoding="utf-8", errors="ignore") as f:
    data = json.load(f)

entries = data.get("log", {}).get("entries", [])
for entry in entries:
    req = entry.get("request", {})
    url = req.get("url", "")
    method = req.get("method", "")
    
    if "notification" in url.lower() or "push" in url.lower() or "alert" in url.lower():
        print(f"=== {method} {url} ===")
        res = entry.get("response", {}).get("content", {}).get("text", "")
        if res:
            print("Response Snippet:", res[:400])
        print()
