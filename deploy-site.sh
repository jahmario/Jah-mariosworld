#!/bin/bash

# Jah'mario Website Deployment Script
# Use this script to deploy any changes to your website

set -e  # Exit on any error

usage() {
    echo "🎵 Jah'mario Website Deployment"
    echo "=============================="
    echo ""
    echo "Usage: $0 [local|remote] [commit_message]"
    echo ""
    echo "Commands:"
    echo "  local   - Build and start local server (no deploy)"
    echo "  remote  - Build, commit, and deploy to production (default)"
    echo ""
    echo "Examples:"
    echo "  $0 local"
    echo "  $0 remote \"Updated jahmario page\""
    echo "  $0 \"Quick update\"  # defaults to remote"
    echo ""
}

DEPLOY_TYPE="${1:-remote}"
COMMIT_MSG="${2:-}"

# Handle help flag
if [[ "$1" == "-h" || "$1" == "--help" || "$1" == "help" ]]; then
    usage
    exit 0
fi

# Check if we're in the right directory
if [ ! -f "config.toml" ]; then
    echo "❌ Error: Not in website directory."
    echo "   Please run: cd '/Users/m326652/Documents/Jah'mario/website'"
    exit 1
fi

echo "📁 Working directory: $(pwd)"
echo ""

# Step 1: Build the site
echo "🔨 Building Hugo site..."
hugo --minify
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed!"
    exit 1
fi

echo ""

# Handle local deployment
if [ "$DEPLOY_TYPE" = "local" ]; then
    echo "🚀 Starting local server..."
    echo "🌐 Your site will be available at: http://localhost:1313"
    echo "📱 CMS: http://localhost:1313/admin"
    echo "Press Ctrl+C to stop the server"
    echo ""
    hugo server -D
    exit 0
fi

# Handle remote deployment
echo "📊 Checking for changes..."
CHANGED_FILES=$(git status --porcelain | wc -l)
if [ $CHANGED_FILES -eq 0 ]; then
    echo "ℹ️  No changes detected. Site is already up to date."
    exit 0
fi

echo "📝 Found $CHANGED_FILES changed file(s)"

# Step 3: Show what's changed
echo ""
echo "📋 Changes to be committed:"
git status --short

# Step 4: Add all changes
echo ""
echo "📝 Adding all changes..."
git add .

# Step 5: Commit with timestamp and optional message
if [ -z "$COMMIT_MSG" ]; then
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    COMMIT_MSG="Update website - $TIMESTAMP"
fi

echo "💾 Committing: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# Step 6: Push to GitHub
echo ""
echo "☁️  Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCESS! Website deployed successfully!"
    echo "🌐 Your site: https://jahmario-music.netlify.app"
    echo "📱 CMS: https://jahmario-music.netlify.app/admin"
    echo "⏱️  Changes will be live in 1-2 minutes"
else
    echo "❌ Push failed! Check your git configuration."
    exit 1
fi

echo ""
echo "🔧 To test locally: $0 local"

