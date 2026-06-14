#!/bin/bash
###############################################################################
# DevOps Academy — Facebook Auto-Poster Setup
# Run this once on your server to configure everything automatically.
#
# Usage: bash /home/maged/devopsacademy/scripts/facebook/setup.sh
###############################################################################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$HOME/.fb_env"
DEPLOY_DIR="/home/maged/devopsacademy"
CRON_CMD="source $HOME/.fb_env && cd $DEPLOY_DIR/scripts/facebook && python3 fb_post.py >> $DEPLOY_DIR/scripts/facebook/cron.log 2>&1"
CRON_SCHEDULE="0 10 * * *"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "=========================================="
echo "  DevOps Academy — Facebook Poster Setup  "
echo "=========================================="
echo ""

# ---------- Step 1: Collect credentials ----------
echo -e "${YELLOW}Step 1: Credentials${NC}"
echo "-------------------------------------------"

# Load existing values if .fb_env already exists
EXISTING_PAGE_ID=""
EXISTING_TOKEN=""
EXISTING_OPENAI=""
if [ -f "$ENV_FILE" ]; then
    echo -e "Found existing config at ${GREEN}$ENV_FILE${NC}"
    source "$ENV_FILE" 2>/dev/null || true
    EXISTING_PAGE_ID="${FB_PAGE_ID:-}"
    EXISTING_TOKEN="${FB_ACCESS_TOKEN:-}"
    EXISTING_OPENAI="${OPENAI_API_KEY:-}"
fi

read_credential() {
    local prompt="$1"
    local existing="$2"
    local value

    if [ -n "$existing" ]; then
        local masked="${existing:0:6}...${existing: -4}"
        read -rp "$prompt [$masked]: " value
        if [ -z "$value" ]; then
            echo "$existing"
            return
        fi
    else
        read -rp "$prompt: " value
        while [ -z "$value" ]; do
            echo "  This field is required."
            read -rp "$prompt: " value
        done
    fi
    echo "$value"
}

FB_PAGE_ID=$(read_credential "Facebook Page ID" "$EXISTING_PAGE_ID")
FB_ACCESS_TOKEN=$(read_credential "Facebook Page Access Token" "$EXISTING_TOKEN")
OPENAI_API_KEY=$(read_credential "OpenAI API Key (for DALL-E 3)" "$EXISTING_OPENAI")

echo ""

# ---------- Step 2: Save environment file ----------
echo -e "${YELLOW}Step 2: Saving credentials${NC}"
echo "-------------------------------------------"

cat > "$ENV_FILE" << EOF
export FB_PAGE_ID="$FB_PAGE_ID"
export FB_ACCESS_TOKEN="$FB_ACCESS_TOKEN"
export OPENAI_API_KEY="$OPENAI_API_KEY"
EOF
chmod 600 "$ENV_FILE"
echo -e "${GREEN}✅ Saved to $ENV_FILE (permissions: 600)${NC}"
echo ""

# ---------- Step 3: Create directories ----------
echo -e "${YELLOW}Step 3: Creating directories${NC}"
echo "-------------------------------------------"
mkdir -p "$SCRIPT_DIR/generated_images"
echo -e "${GREEN}✅ generated_images/ directory ready${NC}"
echo ""

# ---------- Step 4: Verify Facebook API ----------
echo -e "${YELLOW}Step 4: Testing Facebook API connection${NC}"
echo "-------------------------------------------"
FB_TEST=$(curl -s "https://graph.facebook.com/v19.0/${FB_PAGE_ID}?fields=name,id&access_token=${FB_ACCESS_TOKEN}" 2>&1)
if echo "$FB_TEST" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['name'])" 2>/dev/null; then
    PAGE_NAME=$(echo "$FB_TEST" | python3 -c "import sys,json; print(json.load(sys.stdin)['name'])")
    echo -e "${GREEN}✅ Connected to Facebook Page: $PAGE_NAME${NC}"
else
    ERROR_MSG=$(echo "$FB_TEST" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('error',{}).get('message','Unknown error'))" 2>/dev/null || echo "Connection failed")
    echo -e "${RED}❌ Facebook API error: $ERROR_MSG${NC}"
    echo "   Check your Page ID and Access Token."
    echo "   Continuing setup anyway..."
fi
echo ""

# ---------- Step 5: Verify OpenAI API ----------
echo -e "${YELLOW}Step 5: Testing OpenAI API connection${NC}"
echo "-------------------------------------------"
OPENAI_TEST=$(curl -s "https://api.openai.com/v1/models/dall-e-3" \
    -H "Authorization: Bearer ${OPENAI_API_KEY}" 2>&1)
if echo "$OPENAI_TEST" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['id'])" 2>/dev/null; then
    echo -e "${GREEN}✅ OpenAI API key valid — DALL-E 3 accessible${NC}"
else
    ERROR_MSG=$(echo "$OPENAI_TEST" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('error',{}).get('message','Unknown error'))" 2>/dev/null || echo "Connection failed")
    echo -e "${RED}❌ OpenAI API error: $ERROR_MSG${NC}"
    echo "   Images won't be generated — text-only posts will still work."
    echo "   Continuing setup anyway..."
fi
echo ""

# ---------- Step 6: Set up cron job ----------
echo -e "${YELLOW}Step 6: Setting up daily cron job (10:00 AM)${NC}"
echo "-------------------------------------------"

# Check if cron job already exists
EXISTING_CRON=$(crontab -l 2>/dev/null || true)
if echo "$EXISTING_CRON" | grep -q "fb_post.py"; then
    echo "  Existing Facebook cron job found — replacing it."
    EXISTING_CRON=$(echo "$EXISTING_CRON" | grep -v "fb_post.py")
fi

# Add new cron entry
echo "$EXISTING_CRON
# DevOps Academy — Daily Facebook post with AI image (10:00 AM)
$CRON_SCHEDULE $CRON_CMD" | crontab -

echo -e "${GREEN}✅ Cron job installed: every day at 10:00 AM${NC}"
echo "   Schedule: $CRON_SCHEDULE"
echo ""

# ---------- Step 7: Dry run ----------
echo -e "${YELLOW}Step 7: Running a test (dry run)${NC}"
echo "-------------------------------------------"
source "$ENV_FILE"
cd "$SCRIPT_DIR"
python3 fb_post.py --dry-run || echo -e "${RED}Dry run failed — check errors above.${NC}"
echo ""

# ---------- Done ----------
echo ""
echo "=========================================="
echo -e "${GREEN}  ✅ Setup complete!${NC}"
echo "=========================================="
echo ""
echo "  Config:    $ENV_FILE"
echo "  Cron:      Daily at 10:00 AM"
echo "  Posts:     $(python3 -c "import json; print(len(json.load(open('$SCRIPT_DIR/posts.json'))))" 2>/dev/null || echo '?') posts in pool"
echo "  Images:    AI-generated via DALL-E 3"
echo ""
echo "  Useful commands:"
echo "    source ~/.fb_env && cd $DEPLOY_DIR/scripts/facebook"
echo "    python3 fb_post.py --list       # See all posts"
echo "    python3 fb_post.py --dry-run    # Preview next post"
echo "    python3 fb_post.py --text-only  # Post without image"
echo "    python3 fb_post.py              # Post with AI image"
echo ""
