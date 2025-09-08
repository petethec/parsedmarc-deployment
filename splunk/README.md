# Splunk Integration

This guide explains how to set up Splunk for use with parsedmarc DMARC report analysis.

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Dashboard Setup](#dashboard-setup)
- [Example Configuration](#example-configuration)

## Installation

### Install Splunk with Docker

Download the latest Splunk image:

```bash
docker pull splunk/splunk:latest
```

### Run Splunk with Docker

#### Option 1: Listen on all network interfaces

```bash
docker run -d \
  -p 8000:8000 \
  -p 8088:8088 \
  -e "SPLUNK_START_ARGS=--accept-license" \
  -e "SPLUNK_PASSWORD=password1234" \
  -e "SPLUNK_HEC_TOKEN=hec-token-1234" \
  --name splunk \
  splunk/splunk:latest
```

#### Option 2: Listen on localhost (for reverse proxy)

```bash
docker run -d \
  -p 127.0.0.1:8000:8000 \
  -p 127.0.0.1:8088:8088 \
  -e "SPLUNK_START_ARGS=--accept-license" \
  -e "SPLUNK_PASSWORD=password1234" \
  -e "SPLUNK_HEC_TOKEN=hec-token-1234" \
  -e "SPLUNK_ROOT_ENDPOINT=/splunk" \
  --name splunk \
  splunk/splunk:latest
```

#### Reverse Proxy Setup (Apache2)

Add to your Apache configuration:

```apache
ProxyPass /splunk http://127.0.0.1:8000/splunk
ProxyPassReverse /splunk http://127.0.0.1:8000/splunk
```

## Configuration

### Access Splunk Web UI

1. Navigate to `http://127.0.0.1:8000`
2. Login with `admin:password1234`

### Create App and Index

#### Create Index

1. Go to **Settings > Data > Indexes**
2. Click **New Index**
3. Set index name to `email`

#### Verify HEC Token

1. Go to **Settings > Data > Data inputs > HTTP Event Collector**
2. Verify the HEC token `hec-token-1234` is configured

#### Create App

1. Go to **Apps > Manage Apps**
2. Click **Create app**
3. Set name to `parsedmarc`
4. Set folder name to `parsedmarc`

## Dashboard Setup

### Import DMARC Dashboards

#### 1. Aggregate DMARC Dashboard

1. Navigate to your app (or create a new app called "DMARC")
2. Click **Dashboards**
3. Click **Create New Dashboard**
4. Use title: "Aggregate DMARC Data"
5. Click **Create Dashboard**
6. Click **Source** button
7. Paste content from `dmarc_aggregate_dashboard.xml`
8. If your index is not named "email", replace `index="email"` accordingly
9. Click **Save**

#### 2. Forensic DMARC Dashboard

1. Click **Dashboards**
2. Click **Create New Dashboard**
3. Use title: "Forensic DMARC Data"
4. Click **Create Dashboard**
5. Click **Source** button
6. Paste content from `dmarc_forensic_dashboard.xml`
7. If your index is not named "email", replace `index="email"` accordingly
8. Click **Save**

#### 3. SMTP TLS Dashboard

1. Click **Dashboards**
2. Click **Create New Dashboard**
3. Use title: "SMTP TLS Reports"
4. Click **Create Dashboard**
5. Click **Source** button
6. Paste content from `smtp_tls_dashboard.xml`
7. If your index is not named "email", replace `index="email"` accordingly
8. Click **Save**

## Example Configuration

### parsedmarc.ini

```ini
[splunk_hec]
url = https://127.0.0.1:8088/
token = hec-token-1234
index = email
skip_certificate_verification = True
```

> **Security Note**: `skip_certificate_verification = True` disables security checks. Only use this in development environments.

### Run parsedmarc

```bash
python3 -m parsedmarc.cli -c parsedmarc.ini
```

## Troubleshooting

### Common Issues

1. **Connection refused**: Check if Splunk is running and ports are accessible
2. **Authentication failed**: Verify HEC token and credentials
3. **Index not found**: Ensure the "email" index is created
4. **Dashboard not loading**: Check that the XML content is properly formatted

### Health Checks

```bash
# Check if Splunk is running
docker ps | grep splunk

# Check Splunk logs
docker logs splunk

# Test HEC endpoint
curl -k https://127.0.0.1:8088/services/collector \
  -H "Authorization: Splunk hec-token-1234" \
  -d '{"event": "test"}'
```

## Security Considerations

- Change default passwords in production
- Use proper SSL certificates
- Restrict network access to Splunk
- Regularly update Splunk version
- Monitor access logs

## Support

For additional help:

- [Splunk Documentation](https://docs.splunk.com/)
- [parsedmarc Issues](https://github.com/domainaware/parsedmarc/issues)
- [Splunk Community](https://community.splunk.com/)
