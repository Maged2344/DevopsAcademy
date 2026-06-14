#!/usr/bin/env python3
"""
DevOps Academy — Automated Facebook Page Post with AI-Generated Images
Posts one course promotion per day with an AI-generated image.

Requires:
  - FB_PAGE_ID: Facebook Page ID
  - FB_ACCESS_TOKEN: Page Access Token (pages_manage_posts permission)
  - OPENAI_API_KEY: OpenAI API key for DALL-E image generation

Usage:
  python3 fb_post.py              # Post today's content with AI image
  python3 fb_post.py --dry-run    # Preview text + generate image without posting
  python3 fb_post.py --text-only  # Post without image
  python3 fb_post.py --list       # List all posts in the pool
"""

import os
import sys
import json
import urllib.request
import urllib.parse
import urllib.error
import uuid
import mimetypes
from datetime import date
from pathlib import Path

# ===== Configuration =====
FB_PAGE_ID = os.environ.get("FB_PAGE_ID", "")
FB_ACCESS_TOKEN = os.environ.get("FB_ACCESS_TOKEN", "")
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "")
GRAPH_API_URL = "https://graph.facebook.com/v19.0"
OPENAI_API_URL = "https://api.openai.com/v1/images/generations"
SCRIPT_DIR = Path(__file__).parent
POSTS_FILE = SCRIPT_DIR / "posts.json"
LOG_FILE = SCRIPT_DIR / "post_log.json"
IMAGES_DIR = SCRIPT_DIR / "generated_images"
SITE_URL = "https://devopsacademy.cloud-stacks.com"


def load_posts():
    with open(POSTS_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def get_post_log():
    if LOG_FILE.exists():
        with open(LOG_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    return {"posted": [], "history": []}


def save_post_log(log):
    with open(LOG_FILE, "w", encoding="utf-8") as f:
        json.dump(log, f, indent=2, ensure_ascii=False)


def select_todays_post(posts):
    log = get_post_log()
    posted_ids = set(log.get("posted", []))

    for post in posts:
        if post["id"] not in posted_ids:
            return post

    # All posted — reset cycle
    log["posted"] = []
    save_post_log(log)
    return posts[0] if posts else None


# ===== AI Image Generation (DALL-E 3) =====
def generate_image(prompt, post_id):
    """Generate an image using OpenAI DALL-E 3 API."""
    if not OPENAI_API_KEY:
        print("WARNING: OPENAI_API_KEY not set — skipping image generation.")
        return None

    IMAGES_DIR.mkdir(parents=True, exist_ok=True)

    # Use cached image if available
    cached = IMAGES_DIR / f"{post_id}.png"
    if cached.exists():
        print(f"📷 Using cached image: {cached}")
        return str(cached)

    print("🎨 Generating image with DALL-E 3...")
    print(f"   Prompt: {prompt[:120]}...")

    data = json.dumps({
        "model": "dall-e-3",
        "prompt": prompt,
        "n": 1,
        "size": "1024x1024",
        "quality": "standard"
    }).encode("utf-8")

    req = urllib.request.Request(
        OPENAI_API_URL,
        data=data,
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {OPENAI_API_KEY}"
        },
        method="POST"
    )

    try:
        with urllib.request.urlopen(req, timeout=120) as response:
            result = json.loads(response.read().decode("utf-8"))
            image_url = result["data"][0]["url"]

            # Download and cache
            urllib.request.urlretrieve(image_url, str(cached))
            print(f"✅ Image saved: {cached}")
            return str(cached)

    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8")
        print(f"ERROR: OpenAI API returned {e.code}")
        print(error_body)
        return None
    except Exception as e:
        print(f"ERROR: Image generation failed: {e}")
        return None


# ===== Facebook Posting =====
def post_text_only(message, link=None):
    """Post text-only to Facebook Page."""
    url = f"{GRAPH_API_URL}/{FB_PAGE_ID}/feed"
    data = {"message": message, "access_token": FB_ACCESS_TOKEN}
    if link:
        data["link"] = link

    encoded = urllib.parse.urlencode(data).encode("utf-8")
    req = urllib.request.Request(url, data=encoded, method="POST")

    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode("utf-8"))


def post_with_photo(message, image_path):
    """Post a photo with caption to Facebook Page using multipart upload."""
    url = f"{GRAPH_API_URL}/{FB_PAGE_ID}/photos"
    boundary = f"----PythonBoundary{uuid.uuid4().hex}"

    body = bytearray()

    # Message field
    body.extend(f"--{boundary}\r\n".encode())
    body.extend(b'Content-Disposition: form-data; name="message"\r\n\r\n')
    body.extend(message.encode("utf-8"))
    body.extend(b"\r\n")

    # Access token field
    body.extend(f"--{boundary}\r\n".encode())
    body.extend(b'Content-Disposition: form-data; name="access_token"\r\n\r\n')
    body.extend(FB_ACCESS_TOKEN.encode("utf-8"))
    body.extend(b"\r\n")

    # Image file
    filename = os.path.basename(image_path)
    mime_type = mimetypes.guess_type(image_path)[0] or "image/png"
    body.extend(f"--{boundary}\r\n".encode())
    body.extend(f'Content-Disposition: form-data; name="source"; filename="{filename}"\r\n'.encode())
    body.extend(f"Content-Type: {mime_type}\r\n\r\n".encode())
    with open(image_path, "rb") as img:
        body.extend(img.read())
    body.extend(b"\r\n")

    body.extend(f"--{boundary}--\r\n".encode())

    req = urllib.request.Request(
        url,
        data=bytes(body),
        headers={"Content-Type": f"multipart/form-data; boundary={boundary}"},
        method="POST"
    )

    with urllib.request.urlopen(req) as response:
        return json.loads(response.read().decode("utf-8"))


def format_post(post):
    """Format a post object into the Facebook message text."""
    lines = []

    lines.append(post.get("emoji", "🚀") + " " + post["title"])
    lines.append("")
    lines.append(post["body"])
    lines.append("")

    if "highlights" in post:
        for h in post["highlights"]:
            lines.append(f"✅ {h}")
        lines.append("")

    if "cta" in post:
        lines.append(post["cta"])
        lines.append("")

    course_id = post.get("course_id", "")
    if course_id:
        lines.append(f"🔗 سجل الآن: {SITE_URL}/course.html?id={course_id}")
    else:
        lines.append(f"🔗 تصفح جميع الكورسات: {SITE_URL}")

    lines.append("")

    hashtags = post.get("hashtags", ["#DevOps", "#DevOpsAcademy", "#DevOpsAcademyEgypt"])
    lines.append(" ".join(hashtags))

    return "\n".join(lines)


def main():
    dry_run = "--dry-run" in sys.argv
    text_only = "--text-only" in sys.argv
    list_all = "--list" in sys.argv

    posts = load_posts()

    if list_all:
        print(f"📋 Total posts in pool: {len(posts)}\n")
        for i, p in enumerate(posts, 1):
            has_img = "🖼️" if p.get("image_prompt") else "📝"
            print(f"  {i}. [{p['id']}] {has_img} {p['emoji']} {p['title']}")
        return

    if not FB_PAGE_ID or not FB_ACCESS_TOKEN:
        if not dry_run:
            print("ERROR: FB_PAGE_ID and FB_ACCESS_TOKEN are required.")
            sys.exit(1)

    post = select_todays_post(posts)
    if not post:
        print("No posts available.")
        return

    message = format_post(post)

    print(f"📅 {date.today()} — Post #{post['id']}")
    print("=" * 60)
    print(message)
    print("=" * 60)

    # Generate AI image
    image_path = None
    if not text_only and post.get("image_prompt"):
        image_path = generate_image(post["image_prompt"], post["id"])

    if dry_run:
        print(f"\n🔸 DRY RUN — not posted.")
        if image_path:
            print(f"🖼️  Image: {image_path}")
        return

    # Post to Facebook
    try:
        if image_path:
            result = post_with_photo(message, image_path)
            print(f"\n✅ Posted with photo! Post ID: {result.get('post_id', result.get('id', 'unknown'))}")
        else:
            link = f"{SITE_URL}/course.html?id={post['course_id']}" if post.get("course_id") else None
            result = post_text_only(message, link)
            print(f"\n✅ Posted (text only)! Post ID: {result.get('id', 'unknown')}")
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8")
        print(f"ERROR: Facebook API returned {e.code}")
        print(error_body)
        sys.exit(1)

    # Log
    log = get_post_log()
    log["posted"].append(post["id"])
    log["history"].append({
        "post_id": post["id"],
        "fb_post_id": result.get("post_id", result.get("id")),
        "date": str(date.today()),
        "title": post["title"],
        "had_image": image_path is not None
    })
    save_post_log(log)


if __name__ == "__main__":
    main()
