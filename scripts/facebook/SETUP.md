# Facebook Auto-Poster Setup

## Prerequisites

1. **Facebook App** — Create at [developers.facebook.com/apps](https://developers.facebook.com/apps/)
2. **Page Access Token** with `pages_manage_posts` and `pages_read_engagement` permissions
3. **Python 3** installed on the server

## Step 1: Get Your Page ID

Your page URL is `https://www.facebook.com/devopsacademy`.
To get the numeric Page ID:
```bash
# Using the Graph API Explorer (https://developers.facebook.com/tools/explorer/)
# Or use: GET /me?fields=id,name with your Page Access Token
```

## Step 2: Generate a Long-Lived Page Access Token

1. Go to [Graph API Explorer](https://developers.facebook.com/tools/explorer/)
2. Select your app
3. Click "Get User Access Token" → select `pages_manage_posts`, `pages_read_engagement`
4. Exchange for long-lived token:
```bash
curl "https://graph.facebook.com/v19.0/oauth/access_token?grant_type=fb_exchange_token&client_id=YOUR_APP_ID&client_secret=YOUR_APP_SECRET&fb_exchange_token=YOUR_SHORT_TOKEN"
```
5. Get permanent Page Token:
```bash
curl "https://graph.facebook.com/v19.0/me/accounts?access_token=YOUR_LONG_LIVED_USER_TOKEN"
```
Copy the `access_token` for your page — this one never expires.

## Step 3: Set Environment Variables on the Server

```bash
# Add to /home/maged/.bashrc or create /home/maged/.fb_env
export FB_PAGE_ID="YOUR_PAGE_ID"
export FB_ACCESS_TOKEN="YOUR_PAGE_ACCESS_TOKEN"
```

## Step 4: Test the Script

```bash
cd /home/maged/devopsacademy/scripts/facebook

# Preview without posting
python3 fb_post.py --dry-run

# List all available posts
python3 fb_post.py --list

# Actually post
python3 fb_post.py
```

## Step 5: Set Up Daily Cron Job

```bash
# Edit crontab
crontab -e

# Add this line (posts every day at 10:00 AM Egypt time):
0 10 * * * source /home/maged/.fb_env && cd /home/maged/devopsacademy/scripts/facebook && python3 fb_post.py >> /home/maged/devopsacademy/scripts/facebook/cron.log 2>&1
```

## How It Works

- **30 posts** in the pool (one per course + general promotions + track promotions)
- Cycles through all posts sequentially — after posting all 30, starts over
- Logs every post to `post_log.json` with date and Facebook post ID
- Each post includes: title, description, highlights, call-to-action, course link, and hashtags

## Content Management

Edit `posts.json` to add, remove, or modify posts. Each post has:
```json
{
  "id": "unique-id",
  "emoji": "🚀",
  "title": "Post Title",
  "body": "Main content text",
  "highlights": ["Point 1", "Point 2"],
  "cta": "Call to action text",
  "course_id": "docker",
  "hashtags": ["#DevOps", "#Docker"]
}
```

If `course_id` is empty, the post links to the main site instead of a specific course page.
