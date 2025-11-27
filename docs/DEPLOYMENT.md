# Deployment Guide

This guide explains how to deploy your application to a VPS using Docker and GitHub Actions.

## Prerequisites

1. A VPS with:
   - Docker installed
   - Docker Compose installed
   - Git installed
   - SSH access configured

2. GitHub repository with this code

## VPS Setup

### 1. Install Docker and Docker Compose on VPS

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose -y

# Verify installation
docker --version
docker-compose --version
```

### 2. Clone Repository on VPS

```bash
# SSH into your VPS
ssh user@your-vps-ip

# Clone your repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO

# Create .env file
cp .env.example .env
nano .env  # Edit with your actual values
```

### 3. Configure Environment Variables on VPS

Edit the `.env` file on your VPS:

```bash
PORT=8080
TURSO_CONNECTION_URL=your_actual_database_url
TURSO_AUTH_TOKEN=your_actual_auth_token
```

## GitHub Secrets Configuration

Add the following secrets to your GitHub repository:

**Settings → Secrets and variables → Actions → New repository secret**

| Secret Name | Description | Example |
|------------|-------------|---------|
| `VPS_HOST` | Your VPS IP address or domain | `123.45.67.89` or `yourdomain.com` |
| `VPS_USERNAME` | SSH username for VPS | `root` or `ubuntu` |
| `VPS_SSH_KEY` | Private SSH key for authentication | Your private key content |
| `VPS_PORT` | SSH port (usually 22) | `22` |
| `VPS_PROJECT_PATH` | Full path to project on VPS | `/home/user/learn-cicd-typescript-starter` |

### Generating SSH Key for GitHub Actions

On your VPS:

```bash
# Generate a new SSH key pair
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github-actions

# Add the public key to authorized_keys
cat ~/.ssh/github-actions.pub >> ~/.ssh/authorized_keys

# Display the private key (copy this to GitHub secrets as VPS_SSH_KEY)
cat ~/.ssh/github-actions
```

Copy the entire private key output (including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`) and add it as `VPS_SSH_KEY` secret in GitHub.

## Deployment Workflow

### Automatic Deployment

The CD workflow automatically deploys when code is pushed to the `main` branch:

1. Code is pushed to `main` branch
2. GitHub Actions runs the CD workflow
3. Builds and tests the application
4. SSHs into your VPS
5. Pulls latest code
6. Rebuilds and restarts Docker containers

### Manual Deployment on VPS

If you need to deploy manually on your VPS:

```bash
cd /path/to/your/project
bash deploy.sh
```

## Verify Deployment

Check if containers are running:

```bash
docker-compose ps
```

Check logs:

```bash
docker-compose logs -f app
```

Test the API:

```bash
curl http://localhost:8080/v1/healthz
```

## Firewall Configuration

Allow HTTP/HTTPS traffic:

```bash
# If using ufw
sudo ufw allow 8080/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

## Nginx Reverse Proxy (Optional but Recommended)

For production, use Nginx as a reverse proxy:

```bash
# Install Nginx
sudo apt install nginx -y

# Create Nginx config
sudo nano /etc/nginx/sites-available/your-app
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name yourdomain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/your-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## SSL Certificate with Let's Encrypt

```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com
```

## Troubleshooting

### Check Docker logs
```bash
docker-compose logs -f
```

### Restart containers
```bash
docker-compose restart
```

### Rebuild from scratch
```bash
docker-compose down -v
docker-compose up -d --build
```

### Check GitHub Actions logs
Go to your repository → Actions tab → Click on the latest workflow run

## Maintenance

### Update application
Just push to main branch - automatic deployment will handle it!

### Manual update on VPS
```bash
cd /path/to/project
git pull origin main
bash deploy.sh
```

### View running containers
```bash
docker ps
```

### Stop application
```bash
docker-compose down
```

### Start application
```bash
docker-compose up -d
```
