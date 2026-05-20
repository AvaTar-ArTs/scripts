#!/usr/bin/env bash
# deploy.sh
# Deploys Steven Chaplinski website to production

set -e

echo "Starting deployment..."

# Build the project
echo "Building project..."
npm run build

# Export static files
echo "Exporting static files..."
npm run export

# Deploy to Vercel (if using Vercel)
if command -v vercel &> /dev/null; then
    echo "Deploying to Vercel..."
    vercel --prod
fi

echo "Deployment completed successfully!"
