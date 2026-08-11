import json

print("Searching group members endpoint in HAR...")
with open("YPT Completo.har", "r", encoding="utf-8", errors="ignore") as f:
    data = json.load(f)

entries = data.get("log", {}).get("entries", [])
for entry in entries:
    req = entry.get("request", {})
    url = req.get("url", "")
    method = req.get("method", "")
    
    if "group/member" in url or "group/members" in url or "group/dialog" in url:
        print(f"=== {method} {url} ===")
        post_data = req.get("postData", {}).get("text", "")
        if post_data:
            print("Request Body:", post_data[:200])
        res = entry.get("response", {}).get("content", {}).get("text", "")
        if res:
            print("Response Snippet:", res[:400])
        print()
