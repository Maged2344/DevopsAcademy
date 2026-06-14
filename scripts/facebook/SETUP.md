# Facebook Auto-Poster with AI-Generated Images

## Prerequisites

1. **Facebook App** — Create at [developers.facebook.com/apps](https://developers.facebook.com/apps/)
2. **Page Access Token** with `pages_manage_posts` and `pages_read_engagement` permissions
3. **OpenAI API Key** — Get at [platform.openai.com/api-keys](https://platform.openai.com/api-keys) (for DALL-E 3 image generation)
4. **Python 3** installed on the server

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
# Create /home/maged/.fb_env
cat > /home/maged/.fb_env << 'EOF'
export FB_PAGE_ID="YOUR_PAGE_ID"
export FB_ACCESS_TOKEN="YOUR_PAGE_ACCESS_TOKEN"
export OPENAI_API_KEY="YOUR_OPENAI_API_KEY"
EOF
chmod 600 /home/maged/.fb_env
```

## Step 4: Test the Script

```bash
cd /home/maged/devopsacademy/scripts/facebook

# Load environment
source /home/maged/.fb_env

# Preview without posting (will generate image if OPENAI_API_KEY is set)
python3 fb_post.py --dry-run

# List all available posts
python3 fb_post.py --list

# Post text only (no image)
python3 fb_post.py --text-only

# Post with AI-generated image
python3 fb_post.py
```

## Step 5: Set Up Daily Cron Job

```bash
crontab -e

# Posts every day at 10:00 AM Egypt time with AI image:
0 10 * * * source /home/maged/.fb_env && cd /home/maged/devopsacademy/scripts/facebook && python3 fb_post.py >> /home/maged/devopsacademy/scripts/facebook/cron.log 2>&1
```

## How It Works

1. Selects the next unposted content from `posts.json`
2. Generates an image using **OpenAI DALL-E 3** based on the post's `image_prompt`
3. Caches the image in `generated_images/` (won't regenerate if cached)
4. Uploads the image + Arabic text to your Facebook Page
5. Logs the post to `post_log.json`
6. After all posts are used, resets and cycles again

## Content Details

- **28 posts** — Arabic content with course promotions, DevOps tips, career advice
- Each post has an `image_prompt` for DALL-E 3 to generate a unique visual
- Images are 1024x1024 and cached locally after first generation
- Cost: ~$0.04 per image (DALL-E 3 standard quality)

## Content Management

Edit `posts.json` to add or modify posts:
```json
{
  "id": "unique-id",
  "emoji": "🚀",
  "title": "عنوان البوست بالعربي",
  "body": "محتوى البوست...",
  "highlights": ["نقطة 1", "نقطة 2"],
  "cta": "Call to action",
  "course_id": "docker",
  "hashtags": ["#DevOps", "#Docker"],
  "image_prompt": "English prompt for DALL-E 3 image generation. Describe the visual you want. Always end with 'No text.'"
}
```

## Files

| File | Purpose |
|------|---------|
| `fb_post.py` | Main script — generates image + posts to Facebook |
| `posts.json` | Content pool (28 Arabic posts with image prompts) |
| `post_log.json` | Auto-generated log of posted content |
| `generated_images/` | Cached AI-generated images |
| `SETUP.md` | This file |
