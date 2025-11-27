# Turso Database Setup Guide

This guide walks you through setting up a Turso database for your application.

## What is Turso?

Turso is a distributed database built on libSQL (SQLite fork) that offers:
- SQLite compatibility
- Edge deployment capabilities
- Built-in replication
- Zero-downtime migrations

## Installation

### 1. Install Turso CLI (Linux/macOS)

```bash
curl --proto '=https' --tlsv1.2 -LsSf https://github.com/tursodatabase/turso/releases/latest/download/turso_cli-installer.sh | sh
```

### 2. Verify Installation

```bash
turso --version
```

## Authentication

### Sign up and authenticate:

```bash
turso auth signup
```

Or if you already have an account:

```bash
turso auth login
```

## Create Your Database

### 1. Create a new database

```bash
turso db create learn-cicd-db
```

Turso will automatically choose the closest location to you. To specify a location:

```bash
turso db create learn-cicd-db --location ord  # Chicago
```

Available locations: https://turso.tech/locations

### 2. Get your database URL

```bash
turso db show learn-cicd-db --url
```

This will output something like:
```
libsql://learn-cicd-db-yourorg.turso.io
```

### 3. Create an authentication token

```bash
turso db tokens create learn-cicd-db
```

This generates a token that your app will use to connect to the database.

**Save this token securely!** You'll need it for your environment variables.

#### Optional: Create token with specific permissions (2025 feature)

```bash
# Read-only access
turso db tokens create learn-cicd-db -p all:data_read

# Specific table permissions
turso db tokens create learn-cicd-db -p all:data_read -p users:data_update
```

## Configure Your Application

### 1. Update your local .env file

```bash
# Copy the example
cp .env.example .env

# Edit with your actual values
nano .env
```

Add your credentials:

```env
PORT=8080

TURSO_CONNECTION_URL=libsql://learn-cicd-db-yourorg.turso.io
TURSO_AUTH_TOKEN=eyJhbGc...your_actual_token_here
```

### 2. Run database migrations

Generate migration files from your schema:

```bash
npm run db:generate
```

Apply migrations to your Turso database:

```bash
npm run db:migrate
```

### 3. Verify connection

Start your development server:

```bash
npm run dev
```

You should see: `Connected to database!`

## Database Management

### List your databases

```bash
turso db list
```

### View database details

```bash
turso db show learn-cicd-db
```

### Access database shell

```bash
turso db shell learn-cicd-db
```

Then you can run SQL commands:

```sql
-- List tables
.tables

-- View table schema
.schema users

-- Query data
SELECT * FROM users;

-- Exit shell
.quit
```

## Production Deployment

### For VPS Deployment

Your VPS needs the Turso credentials as environment variables. You have two options:

#### Option 1: Use the same database (simpler)

Use the same `TURSO_CONNECTION_URL` and `TURSO_AUTH_TOKEN` on your VPS:

```bash
# SSH into your VPS
ssh user@your-vps-ip

# Navigate to your project
cd /path/to/learn-cicd-typescript-starter

# Edit .env file
nano .env
```

Add your Turso credentials (same as local).

#### Option 2: Create separate production database (recommended)

```bash
# Create production database
turso db create learn-cicd-db-prod --location ord

# Get production URL
turso db show learn-cicd-db-prod --url

# Create production token
turso db tokens create learn-cicd-db-prod

# Run migrations on production database
TURSO_CONNECTION_URL=<prod-url> TURSO_AUTH_TOKEN=<prod-token> npm run db:migrate
```

Then use the production credentials on your VPS.

### For Docker Deployment

Your `docker-compose.yml` is already configured to use environment variables:

```yaml
environment:
  - TURSO_CONNECTION_URL=${TURSO_CONNECTION_URL}
  - TURSO_AUTH_TOKEN=${TURSO_AUTH_TOKEN}
```

Just ensure your `.env` file exists on the VPS before running `docker-compose up`.

### For GitHub Actions CI/CD

Add your Turso credentials as GitHub Secrets:

1. Go to your repository on GitHub
2. Navigate to **Settings → Secrets and variables → Actions**
3. Click **New repository secret**
4. Add these secrets:
   - Name: `TURSO_CONNECTION_URL`
   - Value: `libsql://learn-cicd-db-prod-yourorg.turso.io`

   - Name: `TURSO_AUTH_TOKEN`
   - Value: Your production auth token

Then update your VPS `.env` file to use these credentials.

## Database Migrations

### Create a new migration

After modifying `src/db/schema.ts`:

```bash
# Generate migration files
npm run db:generate

# Review the generated migration in src/db/migrations/

# Apply the migration
npm run db:migrate
```

### View migration history

```bash
turso db show learn-cicd-db
```

## Useful Turso Commands

```bash
# List all databases
turso db list

# Show database info and stats
turso db show <database-name>

# Delete a database
turso db destroy <database-name>

# Replicate database to another location
turso db replicate <database-name> <location>

# Create database from dump
turso db create <new-db> --from-dump <file.sql>

# Generate database token with expiration
turso db tokens create <database-name> --expiration 2w

# Invalidate all tokens
turso db tokens invalidate <database-name>
```

## Turso Studio (GUI)

Open a web-based GUI for your database:

```bash
npm run db:studio
```

Or use Turso's hosted studio:

```bash
turso db show learn-cicd-db
# Click on the dashboard URL
```

## Troubleshooting

### Connection Issues

If you get connection errors:

1. Verify your credentials:
   ```bash
   turso db show learn-cicd-db --url
   turso db tokens create learn-cicd-db
   ```

2. Check your .env file has correct values:
   ```bash
   cat .env
   ```

3. Ensure no extra spaces or quotes in .env values

### Token Expired

Tokens expire by default. Create a new one:

```bash
turso db tokens create learn-cicd-db --expiration never
```

### Migration Errors

If migrations fail:

```bash
# Check current database schema
turso db shell learn-cicd-db
.schema

# Drop and recreate (CAUTION: loses data)
turso db destroy learn-cicd-db
turso db create learn-cicd-db
npm run db:migrate
```

### Rate Limits

Turso has rate limits on the free tier. Check your usage:

```bash
turso db show learn-cicd-db
```

## Resources

- [Turso Documentation](https://docs.turso.tech/)
- [Turso CLI Reference](https://docs.turso.tech/reference/turso-cli)
- [Generate Database Auth Token](https://docs.turso.tech/api-reference/databases/create-token)
- [Drizzle + Turso Guide](https://orm.drizzle.team/docs/get-started-sqlite#turso)
- [Turso Locations](https://turso.tech/locations)

## Support

- [Turso Discord](https://discord.gg/turso)
- [GitHub Issues](https://github.com/tursodatabase/libsql)
- [Turso Twitter](https://twitter.com/tursodatabase)
