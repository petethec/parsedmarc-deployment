# parsedmarc - DMARC Report Parser and Analyzer

[![Build Status](https://github.com/domainaware/parsedmarc/actions/workflows/python-tests.yml/badge.svg)](https://github.com/domainaware/parsedmarc/actions/workflows/python-tests.yml)
[![Code Coverage](https://codecov.io/gh/domainaware/parsedmarc/branch/master/graph/badge.svg)](https://codecov.io/gh/domainaware/parsedmarc)
[![PyPI Package](https://img.shields.io/pypi/v/parsedmarc.svg)](https://pypi.org/project/parsedmarc/)
[![PyPI - Downloads](https://img.shields.io/pypi/dm/parsedmarc?color=blue)](https://pypistats.org/packages/parsedmarc)

<p align="center">
  <img src="https://github.com/domainaware/parsedmarc/raw/master/docs/source/_static/screenshots/dmarc-summary-charts.png?raw=true" alt="A screenshot of DMARC summary charts in Kibana"/>
</p>

`parsedmarc` is a comprehensive Python module and CLI utility for parsing DMARC reports. When used with Elasticsearch/Kibana, OpenSearch, or Splunk, it works as a self-hosted open-source alternative to commercial DMARC report processing services such as Agari Brand Protection, Dmarcian, OnDMARC, ProofPoint Email Fraud Defense, and Valimail.

> **Note**: **Domain-based Message Authentication, Reporting, and Conformance** (DMARC) is an email authentication protocol that helps protect your domain from email spoofing and phishing attacks.

## 🚀 Quick Start

### Deploy with Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/petethec/parsedmarc-deployment.git
cd parsedmarc-deployment

# Deploy full stack with monitoring
./deploy.sh docker-full

# Or deploy basic stack
./deploy.sh docker-basic
```

### Local Installation

```bash
# Install from source
pip install -e .

# Configure
cp config/parsedmarc.ini.example config/parsedmarc.ini
# Edit configuration file

# Run
parsedmarc -c config/parsedmarc.ini
```

## 📋 Table of Contents

- [Features](#-features)
- [Deployment Options](#-deployment-options)
- [Configuration](#-configuration)
- [Monitoring & Dashboards](#-monitoring--dashboards)
- [Documentation](#-documentation)
- [Contributing](#-contributing)
- [Support](#-support)

## ✨ Features

### Core Functionality
- **DMARC Report Parsing**: Parses draft and 1.0 standard aggregate/rua DMARC reports
- **Forensic Analysis**: Parses forensic/failure/ruf DMARC reports
- **TLS Reporting**: Parses reports from SMTP TLS Reporting
- **Multiple Email Sources**: Supports IMAP, Microsoft Graph, and Gmail API
- **Compression Handling**: Transparently handles gzip or zip compressed reports
- **Data Export**: Simple JSON and/or CSV output
- **Email Integration**: Optionally email the results

### Data Storage & Visualization
- **Elasticsearch Integration**: Send results to Elasticsearch for analysis
- **OpenSearch Support**: Alternative data store with OpenSearch
- **Splunk Integration**: Send reports to Splunk for enterprise analysis
- **Kafka Support**: Send reports to Apache Kafka for streaming
- **Pre-built Dashboards**: Ready-to-use dashboards for Kibana, Grafana, and Splunk

### Advanced Features
- **Geographic Analysis**: IP geolocation and mapping
- **Trend Analysis**: Historical data and compliance tracking
- **Alerting**: Configurable alerts for policy violations
- **Multi-tenant**: Support for multiple domains and organizations
- **API Access**: RESTful API for integration with other tools

## 🚀 Deployment Options

### 1. Docker Compose (Recommended)

The easiest way to deploy parsedmarc with full monitoring stack:

```bash
# Full stack with Elasticsearch, Kibana, OpenSearch, and Grafana
./deploy.sh docker-full

# Basic stack with Elasticsearch and Kibana
./deploy.sh docker-basic

# OpenSearch only
./deploy.sh docker-opensearch
```

**Services Included**:
- parsedmarc (main application)
- Elasticsearch (primary data store)
- Kibana (data visualization)
- OpenSearch (alternative data store)
- OpenSearch Dashboards (alternative visualization)
- Grafana (advanced dashboards)
- Redis (caching, optional)

### 2. Cloud Deployment

#### AWS
- **EC2**: Launch instance and run Docker Compose
- **ECS**: Use provided Dockerfile with Fargate
- **EKS**: Deploy with Kubernetes manifests

#### Azure
- **Container Instances**: Deploy with Azure Container Instances
- **AKS**: Use Azure Kubernetes Service

#### Google Cloud
- **Cloud Run**: Serverless deployment
- **GKE**: Google Kubernetes Engine

### 3. Local Development

```bash
# Install dependencies
pip install -e .

# Configure
cp config/parsedmarc.ini.example config/parsedmarc.ini
# Edit configuration

# Run
parsedmarc -c config/parsedmarc.ini
```

## ⚙️ Configuration

### Quick Configuration

1. **Copy example configuration**:
   ```bash
   cp config/parsedmarc.ini.example config/parsedmarc.ini
   ```

2. **Configure email provider** (choose one):
   - **Gmail**: Use IMAP with app password
   - **Office 365**: Use Microsoft Graph API
   - **Other IMAP**: Standard IMAP configuration

3. **Configure data storage**:
   - **Elasticsearch**: For Kibana dashboards
   - **OpenSearch**: For OpenSearch Dashboards
   - **Splunk**: For enterprise analysis

### Example Configuration

```ini
[general]
save_aggregate = True
save_forensic = True
save_smtp_tls = True

[imap]
host = imap.gmail.com
port = 993
ssl = True
user = your-email@gmail.com
password = your-app-password

[elasticsearch]
hosts = elasticsearch:9200
ssl = False
index_prefix = dmarc_
```

## 📊 Monitoring & Dashboards

### Kibana Dashboards
- **Access**: `http://localhost:5601`
- **Features**: DMARC summary, trends, forensic analysis
- **Setup**: Automatic with Docker deployment

### Grafana Dashboards
- **Access**: `http://localhost:3000` (admin/admin)
- **Features**: Advanced analytics, geographic mapping
- **Import**: Use files in `grafana/` directory

### Splunk Integration
- **Access**: `http://localhost:8000`
- **Features**: Enterprise-grade analysis
- **Setup**: See `splunk/README.md`

### OpenSearch Dashboards
- **Access**: `http://localhost:5602` (admin/admin123)
- **Features**: Alternative to Kibana
- **Setup**: Automatic with OpenSearch deployment

## 📚 Documentation

### Quick Links
- **[Deployment Guide](README-DEPLOYMENT.md)** - Comprehensive deployment instructions
- **[Splunk Setup](splunk/README.md)** - Splunk integration guide
- **[Grafana Dashboards](grafana/README.md)** - Grafana dashboard setup
- **[API Documentation](docs/source/api.md)** - API reference
- **[Usage Guide](docs/source/usage.md)** - Detailed usage instructions

### Additional Resources
- **[Installation Guide](docs/source/installation.md)** - Installation options
- **[Elasticsearch Setup](docs/source/elasticsearch.md)** - Elasticsearch configuration
- **[OpenSearch Setup](docs/source/opensearch.md)** - OpenSearch configuration
- **[Kibana Setup](docs/source/kibana.md)** - Kibana configuration
- **[Output Formats](docs/source/output.md)** - Output format documentation

## 🤝 Contributing

This project is maintained by one developer. We welcome contributions!

### How to Contribute
1. **Review open issues** on [GitHub Issues](https://github.com/domainaware/parsedmarc/issues)
2. **Fork the repository**
3. **Create a feature branch**
4. **Make your changes**
5. **Submit a pull request**

### Areas Needing Help
- Documentation improvements
- Bug fixes
- Feature enhancements
- User support
- Testing

Thanks to all [contributors](https://github.com/domainaware/parsedmarc/graphs/contributors)!

## 🆘 Support

### Getting Help
- **Documentation**: Check the [docs](docs/source/) directory
- **Issues**: [GitHub Issues](https://github.com/domainaware/parsedmarc/issues)
- **Discussions**: [GitHub Discussions](https://github.com/domainaware/parsedmarc/discussions)

### Common Issues
- **Email connection problems**: Check credentials and IMAP settings
- **Elasticsearch not starting**: Verify memory limits and disk space
- **Dashboard not loading**: Check data source configuration

### Troubleshooting
```bash
# Check service status
./deploy.sh status

# View logs
./deploy.sh logs

# Health checks
curl http://localhost:9200/_cluster/health  # Elasticsearch
curl http://localhost:5601/api/status       # Kibana
```

## 📄 License

This project is licensed under the Apache License 2.0. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Original parsedmarc project by [domainaware](https://github.com/domainaware/parsedmarc)
- Dashboard contributions by [Bhozar](https://github.com/Bhozar)
- All contributors and users who help improve this project
