# Configuration Management

## Environment Variables

### ECS Task Definition Environment Variables

The ECS task definition (`task-definition-s3-complete.json`) contains the following environment variables:

#### IMAP Configuration (Disabled)
```json
{
  "name": "IMAP_HOST",
  "value": "disabled"
},
{
  "name": "IMAP_USER", 
  "value": "disabled"
},
{
  "name": "IMAP_PASSWORD",
  "value": "disabled"
},
{
  "name": "IMAP_PASS",
  "value": "disabled"
}
```

#### S3 Configuration
```json
{
  "name": "S3_BUCKET",
  "value": "ray-dmarc-processed-167290361699"
},
{
  "name": "S3_PREFIX",
  "value": "reports"
},
{
  "name": "S3_RAW_BUCKET",
  "value": "ray-dmarc-raw-167290361699"
},
{
  "name": "S3_RAW_PREFIX",
  "value": "raw"
},
{
  "name": "AWS_DEFAULT_REGION",
  "value": "us-west-1"
}
```

#### Processing Configuration
```json
{
  "name": "PROCESS_MODE",
  "value": "s3"
},
{
  "name": "WATCH",
  "value": "True"
},
{
  "name": "PARSEDMARC_CONFIG_FILE",
  "value": "/app/config/parsedmarc.ini"
}
```

#### Webhook Configuration
```json
{
  "name": "WEBHOOK_AGGREGATE_URL",
  "value": "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook"
},
{
  "name": "WEBHOOK_FORENSIC_URL",
  "value": "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook"
},
{
  "name": "WEBHOOK_SMTP_TLS_URL",
  "value": "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook"
},
{
  "name": "DMARC_INGEST_TOKEN",
  "value": "A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"
}
```

## Configuration Files

### parsedmarc Configuration (`config/parsedmarc-s3.ini`)

```ini
# parsedmarc S3-Only Configuration
# This configuration is optimized for S3-based DMARC report processing

[general]
# Save parsed reports to backends
save_aggregate = True
save_forensic = True
save_smtp_tls = True

# Output settings
output = /app/data/output
aggregate_json_filename = aggregate.json
forensic_json_filename = forensic.json
smtp_tls_json_filename = smtp_tls.json
aggregate_csv_filename = aggregate.csv
forensic_csv_filename = forensic.csv
smtp_tls_csv_filename = smtp_tls.csv

# Processing settings
offline = False
strip_attachment_payloads = True
n_procs = 2
dns_timeout = 2.0
nameservers = 8.8.8.8, 1.1.1.1

# Logging
debug = False
verbose = True
log_file = /app/logs/parsedmarc.log

# S3 Configuration - ENABLED for S3 processing
[s3]
bucket = ray-dmarc-processed-167290361699
path = reports
region_name = us-west-1

# Webhook Configuration - ENABLED for Supabase integration
[webhook]
aggregate_url = https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook
forensic_url = https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook
smtp_tls_url = https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook
timeout = 30

# Disable all email-related configurations
# [mailbox] - DISABLED for S3 processing
# [imap] - DISABLED for S3 processing
# [msgraph] - DISABLED for S3 processing
# [gmail_api] - DISABLED for S3 processing
```

## Authentication Tokens

### DMARC Ingest Token
- **Purpose**: Authenticate webhook calls to Supabase Edge Functions
- **Current Value**: `A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456`
- **Location**: ECS task definition environment variables
- **Usage**: Bearer token in Authorization header

### AWS Credentials
- **IAM Role**: `ray-parsedmarc-task-role`
- **Execution Role**: `ecsTaskExecutionRole`
- **Permissions**: S3 read/write access, CloudWatch logs

## Docker Configuration

### Dockerfile.s3
```dockerfile
FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories
RUN mkdir -p /app/data/output /app/logs

# Copy configuration files
COPY config/parsedmarc-s3.ini /app/config/parsedmarc.ini

# Copy custom entrypoint
COPY entrypoint-s3.sh /app/entrypoint-s3.sh
RUN chmod +x /app/entrypoint-s3.sh

# Set entrypoint
ENTRYPOINT ["/app/entrypoint-s3.sh"]
```

### Custom Entrypoint (`entrypoint-s3.sh`)
```bash
#!/bin/bash

# Custom entrypoint for S3-based parsedmarc processing
# This script handles S3 processing mode without requiring IMAP configuration

set -e

echo "Starting parsedmarc in S3 processing mode..."

# Set default values for S3 processing
export PROCESS_MODE=${PROCESS_MODE:-"s3"}
export S3_BUCKET=${S3_BUCKET:-"ray-dmarc-processed-167290361699"}
export S3_PREFIX=${S3_PREFIX:-"reports"}
export S3_RAW_BUCKET=${S3_RAW_BUCKET:-"ray-dmarc-raw-167290361699"}
export S3_RAW_PREFIX=${S3_RAW_PREFIX:-"raw"}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-"us-west-1"}

# Create necessary directories
mkdir -p /app/data/output
mkdir -p /app/logs

# Copy the S3 configuration file
if [ -f "/app/config/parsedmarc-s3.ini" ]; then
    echo "Using S3-specific configuration..."
    cp /app/config/parsedmarc-s3.ini /app/config/parsedmarc.ini
else
    echo "S3 configuration file not found, using default..."
fi

# Update the configuration file with environment variables
if [ ! -z "$S3_BUCKET" ]; then
    sed -i "s/bucket = .*/bucket = $S3_BUCKET/" /app/config/parsedmarc.ini
fi

if [ ! -z "$S3_PREFIX" ]; then
    sed -i "s|path = .*|path = $S3_PREFIX|" /app/config/parsedmarc.ini
fi

if [ ! -z "$AWS_DEFAULT_REGION" ]; then
    sed -i "s/region_name = .*/region_name = $AWS_DEFAULT_REGION/" /app/config/parsedmarc.ini
fi

echo "Configuration updated:"
echo "  S3 Bucket: $S3_BUCKET"
echo "  S3 Path: $S3_PREFIX"
echo "  AWS Region: $AWS_DEFAULT_REGION"

# Display webhook configuration
if [ ! -z "$WEBHOOK_AGGREGATE_URL" ]; then
    echo "  Webhook Aggregate URL: $WEBHOOK_AGGREGATE_URL"
fi

if [ ! -z "$WEBHOOK_FORENSIC_URL" ]; then
    echo "  Webhook Forensic URL: $WEBHOOK_FORENSIC_URL"
fi

if [ ! -z "$WEBHOOK_SMTP_TLS_URL" ]; then
    echo "  Webhook SMTP TLS URL: $WEBHOOK_SMTP_TLS_URL"
fi

# Start parsedmarc with S3 processing
echo "Starting parsedmarc with S3 processing..."
exec parsedmarc -c /app/config/parsedmarc.ini --watch
```

## AWS Resources

### S3 Buckets
- **Raw Reports**: `ray-dmarc-raw-167290361699`
- **Processed Reports**: `ray-dmarc-processed-167290361699`
- **Region**: `us-west-1`

### ECS Resources
- **Cluster**: `ray-core`
- **Service**: `ray-parsedmarc-svc`
- **Task Definition**: `ray-parsedmarc:10`
- **Launch Type**: FARGATE
- **CPU**: 512
- **Memory**: 1024 MB

### IAM Roles
- **Task Role**: `ray-parsedmarc-task-role`
- **Execution Role**: `ecsTaskExecutionRole`

### CloudWatch
- **Log Group**: `/ecs/ray-parsedmarc`
- **Log Stream**: `ecs/ray-parsedmarc/{task-id}`

## Supabase Configuration

### Project Details
- **Project ID**: `buctxwcqzitrqruoomkz`
- **Region**: `us-west-2`
- **Database**: PostgreSQL

### Edge Functions
- **internal-ingest-dmarc**: Primary ingestion endpoint
- **parsedmarc-webhook**: Compatibility layer for parsedmarc format

### Database Tables
- `dmarc_reports`: Main report metadata
- `dmarc_sources`: Source IP data
- `dmarc_rollups`: Aggregated dashboard data
