#!/bin/bash

# Jah'mario Website Deployment Script
# This script builds and deploys the interactive doors website

set -e  # Exit on any error

echo "🚀 Jah'mario Website Deployment Script"
echo "======================================"

# Check if we're in the right directory
if [ ! -f "config.toml" ]; then
    echo "❌ Error: Not in website directory. Please run: cd /Users/m326652/Documents/Jah'mario/website"
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

# Step 2: Check git status
echo "📊 Checking git status..."
git status --porcelain
if [ $? -ne 0 ]; then
    echo "❌ Not a git repository or git error"
    exit 1
fi

# Step 3: Add all changes
echo "📝 Adding all changes to git..."
git add .

# Step 4: Commit with timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
COMMIT_MSG="Update website - $TIMESTAMP"
echo "💾 Committing changes: $COMMIT_MSG"
git commit -m "$COMMIT_MSG"

# Step 5: Push to GitHub
echo "☁️  Pushing to GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 SUCCESS! Website deployed successfully!"
    echo "🌐 Your site will be live at: https://jahmario-music.netlify.app"
    echo "⏱️  Deployment may take 1-2 minutes to complete"
    echo ""
    echo "🚪 Interactive doors should be visible with:"
    echo "   • Red door (Jah'mario) → /about"
    echo "   • Purple door (Music) → /music"  
    echo "   • Blue door (Operation 555) → /posts"
else
    echo "❌ Push failed! Check your git configuration and try again."
    exit 1
fi

echo ""
echo "🔧 To test locally, run: hugo server -D"
echo "📱 To access CMS: https://jahmario-music.netlify.app/admin"

