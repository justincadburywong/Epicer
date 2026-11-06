# Production Deployment Guide

This guide covers deploying Epicer in production mode.

## Prerequisites

- Ruby 3.3.0+
- PostgreSQL
- Tesseract OCR
- ImageMagick
- Redis (for background jobs)

## Installation

### macOS
```bash
brew install postgresql tesseract imagemagick redis
```

### Ubuntu/Debian
```bash
sudo apt-get install postgresql tesseract-ocr imagemagick redis-server
```

### CentOS/RHEL
```bash
sudo yum install postgresql-server tesseract imagemagick redis
```

## Setup

### 1. Environment Variables

Create a `.env.production` file or set in your shell:

```bash
export RAILS_ENV=production
export SECRET_KEY_BASE=$(bin/rails secret)
```

### 2. Database Setup

```bash
# Create production database
RAILS_ENV=production bin/rails db:create

# Run migrations
RAILS_ENV=production bin/rails db:migrate
```

### 3. Asset Precompilation

```bash
RAILS_ENV=production bin/rails assets:precompile
```

### 4. Start Redis (for background jobs)

**macOS:**
```bash
brew services start redis
```

**Linux:**
```bash
sudo systemctl start redis
sudo systemctl enable redis
```

### 5. Start the Server

```bash
RAILS_ENV=production bin/rails server -p 3000
```

## Running as a Background Service

### Using systemd (Linux)

Create `/etc/systemd/system/epicer.service`:
```ini
[Unit]
Description=Epicer Rails App
After=network.target

[Service]
Type=simple
User=your-user
WorkingDirectory=/path/to/epicer
Environment="RAILS_ENV=production"
Environment="SECRET_KEY_BASE=your-secret-key-base"
ExecStart=/path/to/epicer/bin/rails server -p 3000
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable epicer
sudo systemctl start epicer
```

### Using launchd (macOS)

Create `~/Library/LaunchAgents/com.epicer.plist`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>com.epicer</string>
  <key>ProgramArguments</key>
  <array>
    <string>/path/to/epicer/bin/rails</string>
    <string>server</string>
    <string>-e</string>
    <string>production</string>
    <string>-p</string>
    <string>3000</string>
  </array>
  <key>WorkingDirectory</key>
  <string>/path/to/epicer</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>RAILS_ENV</key>
    <string>production</string>
    <key>SECRET_KEY_BASE</key>
    <string>your-secret-key-base</string>
  </dict>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/path/to/epicer/log/epicer.log</string>
  <key>StandardErrorPath</key>
  <string>/path/to/epicer/log/epicer-error.log</string>
</dict>
</plist>
```

Load the service:
```bash
launchctl load ~/Library/LaunchAgents/com.epicer.plist
```

## Storage Configuration

The app uses ActiveStorage with local storage. Files are stored in the `storage/` directory at the project root. The public file server is enabled in production to serve these files.

Ensure the `storage/` directory has proper permissions:
```bash
chmod -R 755 storage/
```

## Network Access

### Local Access
http://localhost:3000

### Network Access
To access from other devices on your network:

1. Find your server's IP address
2. Add the IP/domain to `config/environments/production.rb`:
   ```ruby
   config.hosts << "your-domain.com"
   config.hosts << "192.168.x.x"
   ```
3. Access from other devices: http://your-domain.com:3000

## SSL/HTTPS

The app is configured with `config.force_ssl = true` in production. If you're running locally without a reverse proxy, you may need to disable this:

```ruby
# config/environments/production.rb
config.force_ssl = false
```

For HTTPS with a reverse proxy (nginx, Apache), keep `force_ssl = true` and configure the proxy to handle SSL termination.

## Reverse Proxy Configuration (Optional)

### Nginx Example

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /rails/active_storage/ {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
    }
}
```

## Troubleshooting

### Images Not Loading
- Ensure `config.public_file_server.enabled = true` in production.rb
- Check storage directory permissions: `ls -la storage/`
- Verify files exist: `ls -la storage/`

### Database Connection Errors
- Ensure PostgreSQL is running
- Check database.yml configuration
- Verify database exists

### Redis Connection Errors
- Ensure Redis is running
- Check Redis connection: `redis-cli ping`

### Port Already in Use
- Find process using port 3000: `lsof -i :3000` (macOS) or `netstat -tulpn | grep 3000` (Linux)
- Kill the process: `kill -9 <PID>`

## Logs

View production logs:
```bash
tail -f log/production.log
```

## Updates

To update the app:

```bash
# Pull latest code
git pull

# Install new dependencies
bundle install

# Run migrations
RAILS_ENV=production bin/rails db:migrate

# Precompile assets
RAILS_ENV=production bin/rails assets:precompile

# Restart the service
# systemd: sudo systemctl restart epicer
# launchd: launchctl unload ~/Library/LaunchAgents/com.epicer.plist && launchctl load ~/Library/LaunchAgents/com.epicer.plist
```
