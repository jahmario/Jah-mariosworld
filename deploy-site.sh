#!/bin/bash

# Jah'mario Website Deployment Script
# Use this script to deploy any changes to your website

set -e  # Exit on any error

echo "🎵 Jah'mario Website Deployment"
echo "=============================="

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

# Step 2: Check what files changed
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
if [ -n "$1" ]; then
    COMMIT_MSG="$1"
else
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
echo "🔧 To test locally: hugo server -D"
