# parsedmarc Deployment Guide

This guide provides comprehensive instructions for deploying the parsedmarc DMARC report parsing tool in various environments.

## Table of Contents

- [Quick Start](#quick-start)
- [Deployment Options](#deployment-options)
- [Configuration](#configuration)
- [Email Provider Setup](#email-provider-setup)
- [Monitoring and Dashboards](#monitoring-and-dashboards)
- [Troubleshooting](#troubleshooting)
- [Production Considerations](#production-considerations)

## Quick Start

### Option 1: Full Stack Deployment (Recommended)

Deploy with Elasticsearch, Kibana, OpenSearch, and Grafana:

```bash
./deploy.sh docker-full
```

### Option 2: Basic Deployment

Deploy with just Elasticsearch and Kibana:

```bash
./deploy.sh docker-basic
```

### Option 3: OpenSearch Only

Deploy with OpenSearch and OpenSearch Dashboards:

```bash
./deploy.sh docker-opensearch
```

### Option 4: Local Python Installation

```bash
./deploy.sh local
```

## Deployment Options

### 1. Docker Compose Deployment

The easiest way to deploy parsedmarc is using Docker Compose. This method provides:

- **Isolated environment** with all dependencies
- **Easy scaling** and management
- **Pre-configured** monitoring stack
- **Automatic restarts** and health checks

#### Prerequisites

- Docker 20.10+
- Docker Compose 2.0+
- At least 4GB RAM
- 10GB free disk space

#### Services Included

- **parsedmarc**: Main application
- **Elasticsearch**: Primary data store
- **Kibana**: Data visualization
- **OpenSearch**: Alternative data store
- **OpenSearch Dashboards**: Alternative visualization
- **Grafana**: Advanced dashboards
- **Redis**: Caching (optional)

### 2. Local Python Installation

For development or simple deployments:

```bash
# Install Python 3.8+
pip install -e .

# Configure
cp config/parsedmarc.ini.example config/parsedmarc.ini
# Edit configuration file

# Run
parsedmarc -c config/parsedmarc.ini
```

### 3. Cloud Deployment

#### AWS Deployment

1. **EC2 Instance**:
   ```bash
   # Launch EC2 instance (t3.medium or larger)
   sudo yum update -y
   sudo yum install -y docker
   sudo systemctl start docker
   sudo usermod -a -G docker ec2-user
   
   # Clone and deploy
   git clone <repository>
   cd parsedmarc
   ./deploy.sh docker-full
   ```

2. **ECS with Fargate**:
   - Use the provided Dockerfile
   - Configure ECS task definition
   - Set up RDS for data persistence

3. **EKS (Kubernetes)**:
   - Use Helm charts for Elasticsearch
   - Deploy parsedmarc as a Kubernetes job or cron job

#### Azure Deployment

1. **Container Instances**:
   ```bash
   az container create \
     --resource-group myResourceGroup \
     --name parsedmarc \
     --image parsedmarc:latest \
     --cpu 2 \
     --memory 4
   ```

2. **Azure Kubernetes Service (AKS)**:
   - Deploy using Kubernetes manifests
   - Use Azure Monitor for logging

#### Google Cloud Platform

1. **Cloud Run**:
   ```bash
   gcloud run deploy parsedmarc \
     --image gcr.io/PROJECT_ID/parsedmarc \
     --platform managed \
     --region us-central1
   ```

2. **Google Kubernetes Engine (GKE)**:
   - Deploy using Kubernetes manifests
   - Use Cloud Logging and Monitoring

## Configuration

### Configuration File

The main configuration file is `config/parsedmarc.ini`. Key sections:

#### General Settings
```ini
[general]
save_aggregate = True
save_forensic = True
save_smtp_tls = True
offline = False
n_procs = 2
```

#### Email Provider Configuration

Choose one of the following:

**IMAP (Gmail, Outlook, etc.)**:
```ini
[imap]
host = imap.gmail.com
port = 993
ssl = True
user = your-email@gmail.com
password = your-app-password
```

**Microsoft Graph (Office 365)**:
```ini
[msgraph]
auth_method = UsernamePassword
user = your-email@company.com
password = your-password
client_id = your-client-id
client_secret = your-client-secret
tenant_id = your-tenant-id
```

**Gmail API**:
```ini
[gmail_api]
credentials_file = /app/config/gmail-credentials.json
token_file = /app/config/gmail-token.json
scopes = https://www.googleapis.com/auth/gmail.modify
```

#### Data Storage

**Elasticsearch**:
```ini
[elasticsearch]
hosts = elasticsearch:9200
ssl = False
index_prefix = dmarc_
```

**OpenSearch**:
```ini
[opensearch]
hosts = opensearch:9200
ssl = False
index_prefix = dmarc_
```

**Splunk**:
```ini
[splunk_hec]
url = https://your-splunk:8088/services/collector
token = your-hec-token
index = email
```

## Email Provider Setup

### Gmail Setup

1. **Enable 2-Factor Authentication**
2. **Generate App Password**:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate password for "Mail"

3. **Configure IMAP**:
   ```ini
   [imap]
   host = imap.gmail.com
   port = 993
   ssl = True
   user = your-email@gmail.com
   password = your-16-character-app-password
   ```

### Office 365 Setup

1. **Register Application**:
   - Go to Azure Portal
   - Azure Active Directory → App registrations
   - New registration
   - Add API permissions for Microsoft Graph

2. **Configure Microsoft Graph**:
   ```ini
   [msgraph]
   auth_method = UsernamePassword
   user = your-email@company.com
   password = your-password
   client_id = your-client-id
   client_secret = your-client-secret
   tenant_id = your-tenant-id
   ```

### Other IMAP Providers

Most email providers support IMAP. Common settings:

- **Outlook.com**: `outlook.office365.com:993`
- **Yahoo**: `imap.mail.yahoo.com:993`
- **iCloud**: `imap.mail.me.com:993`

## Monitoring and Dashboards

### Kibana Dashboards

Access Kibana at `http://localhost:5601`

Pre-built dashboards available:
- DMARC Summary Dashboard
- DMARC Trends Dashboard
- Forensic Report Analysis

### Grafana Dashboards

Access Grafana at `http://localhost:3000` (admin/admin)

Import dashboards from `grafana/` directory:
- DMARC Aggregate Reports
- DMARC Forensic Reports
- SMTP TLS Reports

### OpenSearch Dashboards

Access at `http://localhost:5602` (admin/admin123)

## Management Commands

### Start Services
```bash
./deploy.sh docker-full
```

### Stop Services
```bash
./deploy.sh stop
```

### View Logs
```bash
./deploy.sh logs
./deploy.sh logs parsedmarc  # Specific service
```

### Check Status
```bash
./deploy.sh status
```

### Clean Up
```bash
./deploy.sh clean
```

## Troubleshooting

### Common Issues

1. **Elasticsearch not starting**:
   - Check memory limits
   - Ensure `vm.max_map_count` is set correctly
   - Check disk space

2. **Email connection failed**:
   - Verify credentials
   - Check firewall settings
   - Ensure IMAP is enabled

3. **Permission denied**:
   - Check file permissions
   - Ensure Docker has access to volumes

### Logs

Check logs for specific services:
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f parsedmarc
docker-compose logs -f elasticsearch
```

### Health Checks

Verify services are running:
```bash
# Elasticsearch
curl http://localhost:9200/_cluster/health

# Kibana
curl http://localhost:5601/api/status

# OpenSearch
curl http://localhost:9201/_cluster/health
```

## Production Considerations

### Security

1. **Change default passwords**
2. **Enable SSL/TLS**
3. **Use secrets management**
4. **Regular security updates**

### Performance

1. **Allocate sufficient resources**:
   - Elasticsearch: 2GB+ RAM
   - parsedmarc: 1GB+ RAM
   - Total: 4GB+ RAM recommended

2. **Configure indices**:
   - Set appropriate shard counts
   - Configure retention policies
   - Enable index lifecycle management

3. **Monitor resource usage**:
   - CPU and memory usage
   - Disk I/O
   - Network traffic

### Backup

1. **Elasticsearch snapshots**:
   ```bash
   # Create snapshot repository
   curl -X PUT "localhost:9200/_snapshot/backup" -H 'Content-Type: application/json' -d'
   {
     "type": "fs",
     "settings": {
       "location": "/backup"
     }
   }'
   ```

2. **Configuration backup**:
   - Backup configuration files
   - Backup Grafana dashboards
   - Document custom settings

### Scaling

1. **Horizontal scaling**:
   - Add more Elasticsearch nodes
   - Use load balancers
   - Implement clustering

2. **Vertical scaling**:
   - Increase memory allocation
   - Use faster storage (SSD)
   - Optimize JVM settings

## Support

For additional help:

- **Documentation**: [Official Docs](https://domainaware.github.io/parsedmarc)
- **Issues**: [GitHub Issues](https://github.com/domainaware/parsedmarc/issues)
- **Community**: [Discussions](https://github.com/domainaware/parsedmarc/discussions)

## License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

