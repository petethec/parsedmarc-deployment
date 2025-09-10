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
