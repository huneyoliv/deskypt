import json

print("Searching notification delete endpoints in HAR...")
with open("YPT Completo.har", "r", encoding="utf-8", errors="ignore") as f:
    data = json.load(f)

entries = data.get("log", {}).get("entries", [])
for entry in entries:
    req = entry.get("request", {})
    url = req.get("url", "")
    method = req.get("method", "")
    
    if "notice" in url.lower() or "notification" in url.lower():
        print(f"=== {method} {url} ===")
        post_data = req.get("postData", {}).get("text", "")
        if post_data:
            print("Request Body:", post_data[:200])
        res = entry.get("response", {}).get("content", {}).get("text", "")
        if res:
            print("Response Snippet:", res[:300])
        print()
