#!/usr/bin/env python3
"""
DevOps Academy — Automated Facebook Page Post Script
Posts one course promotion per day to the Facebook Page.

Setup:
  1. Create a Facebook App at https://developers.facebook.com/apps/
  2. Add "Pages" product to the app
  3. Generate a Page Access Token with 'pages_manage_posts' and 'pages_read_engagement' permissions
  4. Convert to a long-lived token (60-day) or a permanent page token
  5. Set environment variables:
       export FB_PAGE_ID="your_page_id"
       export FB_ACCESS_TOKEN="your_page_access_token"

Usage:
  python3 fb_post.py              # Post today's scheduled content
  python3 fb_post.py --dry-run    # Preview without posting
  python3 fb_post.py --list       # List all posts in the pool
"""

import os
import sys
import json
import hashlib
import urllib.request
import urllib.parse
import urllib.error
from datetime import datetime, date
from pathlib import Path

# ===== Configuration =====
FB_PAGE_ID = os.environ.get("FB_PAGE_ID", "")
FB_ACCESS_TOKEN = os.environ.get("FB_ACCESS_TOKEN", "")
GRAPH_API_URL = "https://graph.facebook.com/v19.0"
SCRIPT_DIR = Path(__file__).parent
POSTS_FILE = SCRIPT_DIR / "posts.json"
LOG_FILE = SCRIPT_DIR / "post_log.json"
SITE_URL = "https://devopsacademy.cloud-stacks.com"

# ===== Post Content Pool =====
def load_posts():
    """Load posts from the JSON content file."""
    with open(POSTS_FILE, "r", encoding="utf-8") as f:
        return json.load(f)

def get_post_log():
    """Load the log of previously posted content."""
    if LOG_FILE.exists():
        with open(LOG_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {"posted": []}

def save_post_log(log):
    """Save the post log."""
    with open(LOG_FILE, "w", encoding="utf-8") as f:
        json.dump(log, f, indent=2)

def select_todays_post(posts):
    """Select today's post — cycles through the pool based on the day of the year."""
    log = get_post_log()
    posted_ids = set(log.get("posted", []))

    # First pass: find unposted content
    for post in posts:
        if post["id"] not in posted_ids:
            return post

    # All posted — reset cycle and start over
    log["posted"] = []
    save_post_log(log)
    return posts[0] if posts else None

def post_to_facebook(message, link=None):
    """Post a message to the Facebook Page using the Graph API."""
    if not FB_PAGE_ID or not FB_ACCESS_TOKEN:
        print("ERROR: FB_PAGE_ID and FB_ACCESS_TOKEN environment variables are required.")
        print("  export FB_PAGE_ID='your_page_id'")
        print("  export FB_ACCESS_TOKEN='your_page_access_token'")
        sys.exit(1)

    url = f"{GRAPH_API_URL}/{FB_PAGE_ID}/feed"
    data = {
        "message": message,
        "access_token": FB_ACCESS_TOKEN,
    }
    if link:
        data["link"] = link

    encoded_data = urllib.parse.urlencode(data).encode("utf-8")
    req = urllib.request.Request(url, data=encoded_data, method="POST")

    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode("utf-8"))
            return result
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8")
        print(f"ERROR: Facebook API returned {e.code}")
        print(error_body)
        sys.exit(1)

def format_post(post):
    """Format a post object into the Facebook message text."""
    lines = []

    # Emoji header
    lines.append(post.get("emoji", "🚀") + " " + post["title"])
    lines.append("")

    # Body
    lines.append(post["body"])
    lines.append("")

    # Highlights
    if "highlights" in post:
        for h in post["highlights"]:
            lines.append(f"✅ {h}")
        lines.append("")

    # Call to action
    if "cta" in post:
        lines.append(post["cta"])
        lines.append("")

    # Link
    course_id = post.get("course_id", "")
    if course_id:
        lines.append(f"🔗 Enroll now: {SITE_URL}/course.html?id={course_id}")
    else:
        lines.append(f"🔗 Browse all courses: {SITE_URL}")

    lines.append("")

    # Hashtags
    hashtags = post.get("hashtags", ["#DevOps", "#DevOpsAcademy", "#DevOpsEgypt"])
    lines.append(" ".join(hashtags))

    return "\n".join(lines)

def main():
    dry_run = "--dry-run" in sys.argv
    list_all = "--list" in sys.argv

    posts = load_posts()

    if list_all:
        print(f"📋 Total posts in pool: {len(posts)}\n")
        for i, p in enumerate(posts, 1):
            print(f"  {i}. [{p['id']}] {p['emoji']} {p['title']}")
        return

    post = select_todays_post(posts)
    if not post:
        print("No posts available.")
        return

    message = format_post(post)
    link = None
    if post.get("course_id"):
        link = f"{SITE_URL}/course.html?id={post['course_id']}"

    print(f"📅 {date.today()} — Post #{post['id']}")
    print("=" * 60)
    print(message)
    print("=" * 60)

    if dry_run:
        print("\n🔸 DRY RUN — not posted.")
        return

    result = post_to_facebook(message, link)
    print(f"\n✅ Posted successfully! Post ID: {result.get('id', 'unknown')}")

    # Log it
    log = get_post_log()
    log["posted"].append(post["id"])
    log.setdefault("history", []).append({
        "post_id": post["id"],
        "fb_post_id": result.get("id"),
        "date": str(date.today()),
        "title": post["title"]
    })
    save_post_log(log)

if __name__ == "__main__":
    main()
