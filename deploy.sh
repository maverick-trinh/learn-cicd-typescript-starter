#!/bin/bash

# Deployment script for VPS
set -e

echo "Starting deployment..."

# Pull latest changes
echo "Pulling latest code..."
git pull origin main

# Stop and remove old containers
echo "Stopping old containers..."
docker compose down

# Build and start new containers
echo "Building and starting containers..."
docker compose up -d --build

# Clean up old images
echo "Cleaning up old images..."
docker image prune -f

echo "Deployment completed successfully!"
echo "Checking container status..."
docker compose ps
