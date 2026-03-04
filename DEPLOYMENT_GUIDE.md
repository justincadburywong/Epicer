# Production Deployment Guide - Active Job with Redis

## 🚀 Redis Setup for Production

### Option 1: External Redis Service (Recommended)
```bash
# Set environment variable for production
export REDIS_URL="redis://your-redis-provider.com:6379/0"
```

### Option 2: Self-hosted Redis
```bash
# Install Redis on server
sudo apt-get install redis-server  # Ubuntu/Debian
brew install redis             # macOS
sudo yum install redis          # CentOS/RHEL

# Start Redis service
sudo systemctl start redis
sudo systemctl enable redis  # Start on boot
```

### Option 3: Docker Redis
```yaml
# docker-compose.yml
version: '3.8'
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    restart: unless-stopped

volumes:
  redis_data:
```

## 🔧 Environment Variables

Set these in your production environment:

```bash
# Required for Redis background jobs
REDIS_URL="redis://your-redis-host:6379/0"

# Optional: Redis password if using auth
REDIS_URL="redis://:password@your-redis-host:6379/0"
```

## 📱 Multi-App Configuration

For multiple Rails apps on same server:

**App 1 (Epicer):**
```ruby
# config/environments/production.rb
config.redis.url = ENV.fetch("REDIS_URL", "redis://localhost:6379/0")
```

**App 2 (Other App):**
```ruby
# config/environments/production.rb  
config.redis.url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")
```

## 🛠️ Deployment Checklist

- [ ] Redis server installed and running
- [ ] REDIS_URL environment variable set
- [ ] Redis gem in Gemfile
- [ ] `config.active_job.queue_adapter = :redis` configured
- [ ] Redis accessible from Rails app
- [ ] Test background job in staging

## 🔍 Testing Redis Connection

```ruby
# Rails console test
Rails.cache.write("test", "value")
Rails.cache.read("test")  # Should return "value"

# Test background job
MyJob.perform_later(arg1, arg2)
```

## 📊 Monitoring Redis

```bash
# Check Redis status
redis-cli ping

# Monitor Redis
redis-cli monitor

# Check queue length
redis-cli llen queue:default
```

## 🚨 Troubleshooting

**Connection Refused:**
- Check Redis is running: `systemctl status redis`
- Verify Redis URL and port
- Check firewall settings

**Memory Issues:**
- Monitor Redis memory: `redis-cli info memory`
- Set max memory in redis.conf
- Consider Redis persistence

**Job Not Processing:**
- Check Rails logs: `tail -f log/production.log`
- Verify Redis queue: `redis-cli llen queue:default`
- Restart Sidekiq/GoodJob if using
