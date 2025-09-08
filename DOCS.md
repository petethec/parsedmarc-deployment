# parsedmarc Documentation Index

This document provides a comprehensive overview of all available documentation for the parsedmarc DMARC report parser and analyzer.

## 📚 Quick Start Documentation

### Getting Started
- **[Main README](README.md)** - Project overview and quick start guide
- **[Deployment Guide](README-DEPLOYMENT.md)** - Comprehensive deployment instructions
- **[Installation Guide](docs/source/installation.md)** - Detailed installation options

### Configuration
- **[Usage Guide](docs/source/usage.md)** - How to use parsedmarc
- **[Configuration Examples](config/parsedmarc.ini)** - Example configuration files
- **[Environment Variables](env.example)** - Environment variable reference

## 🚀 Deployment Documentation

### Docker Deployment
- **[Docker Compose](docker-compose.yml)** - Basic Docker Compose setup
- **[Full Stack Deployment](docker-compose.full.yml)** - Complete monitoring stack
- **[Deploy Script](deploy.sh)** - Automated deployment script

### Cloud Deployment
- **[AWS Deployment](README-DEPLOYMENT.md#aws-deployment)** - Amazon Web Services setup
- **[Azure Deployment](README-DEPLOYMENT.md#azure-deployment)** - Microsoft Azure setup
- **[Google Cloud](README-DEPLOYMENT.md#google-cloud-platform)** - Google Cloud Platform setup

### Local Development
- **[Local Installation](docs/source/installation.md)** - Local Python installation
- **[Development Setup](docs/source/contributing.md)** - Development environment setup

## 📊 Monitoring & Visualization

### Dashboard Setup
- **[Kibana Setup](docs/source/kibana.md)** - Kibana dashboard configuration
- **[Grafana Dashboards](grafana/README.md)** - Grafana dashboard setup and import
- **[Splunk Integration](splunk/README.md)** - Splunk setup and dashboard import
- **[OpenSearch Setup](docs/source/opensearch.md)** - OpenSearch configuration

### Data Sources
- **[Elasticsearch Setup](docs/source/elasticsearch.md)** - Elasticsearch configuration
- **[OpenSearch Setup](docs/source/opensearch.md)** - OpenSearch configuration
- **[Splunk Setup](splunk/README.md)** - Splunk configuration

## 🔧 Technical Documentation

### API Reference
- **[API Documentation](docs/source/api.md)** - Complete API reference
- **[Output Formats](docs/source/output.md)** - Output format documentation
- **[Data Structures](docs/source/dmarc.md)** - DMARC data structure reference

### Integration Guides
- **[Email Providers](docs/source/davmail.md)** - Email provider setup
- **[Microsoft Graph](docs/source/usage.md#microsoft-graph)** - Office 365 integration
- **[Gmail API](docs/source/usage.md#gmail-api)** - Gmail integration
- **[IMAP Setup](docs/source/usage.md#imap)** - IMAP configuration

### Advanced Topics
- **[Mailing Lists](docs/source/mailing-lists.md)** - Mailing list configuration
- **[Troubleshooting](README-DEPLOYMENT.md#troubleshooting)** - Common issues and solutions
- **[Performance Tuning](README-DEPLOYMENT.md#production-considerations)** - Performance optimization

## 📁 File Structure

```
parsedmarc/
├── README.md                    # Main project documentation
├── README-DEPLOYMENT.md         # Comprehensive deployment guide
├── DOCS.md                      # This documentation index
├── config/
│   └── parsedmarc.ini           # Example configuration
├── docs/
│   └── source/
│       ├── api.md              # API documentation
│       ├── installation.md     # Installation guide
│       ├── usage.md            # Usage guide
│       ├── elasticsearch.md    # Elasticsearch setup
│       ├── opensearch.md       # OpenSearch setup
│       ├── kibana.md           # Kibana setup
│       ├── splunk.md           # Splunk setup
│       ├── davmail.md          # Email provider setup
│       ├── dmarc.md            # DMARC reference
│       ├── output.md           # Output formats
│       └── mailing-lists.md    # Mailing list setup
├── grafana/
│   └── README.md               # Grafana dashboard guide
├── splunk/
│   └── README.md               # Splunk integration guide
├── deploy.sh                   # Deployment script
├── docker-compose.yml          # Basic Docker setup
├── docker-compose.full.yml     # Full stack Docker setup
└── env.example                 # Environment variables
```

## 🎯 Documentation by Use Case

### For System Administrators
- **[Deployment Guide](README-DEPLOYMENT.md)** - Complete deployment instructions
- **[Production Considerations](README-DEPLOYMENT.md#production-considerations)** - Production setup
- **[Troubleshooting](README-DEPLOYMENT.md#troubleshooting)** - Common issues and solutions
- **[Security](README-DEPLOYMENT.md#security)** - Security best practices

### For Developers
- **[API Documentation](docs/source/api.md)** - API reference
- **[Contributing Guide](docs/source/contributing.md)** - How to contribute
- **[Development Setup](docs/source/contributing.md)** - Development environment
- **[Output Formats](docs/source/output.md)** - Data structure reference

### For Data Analysts
- **[Kibana Setup](docs/source/kibana.md)** - Kibana dashboard configuration
- **[Grafana Dashboards](grafana/README.md)** - Advanced analytics setup
- **[Splunk Integration](splunk/README.md)** - Enterprise analysis setup
- **[Data Structures](docs/source/dmarc.md)** - Understanding DMARC data

### For Security Teams
- **[DMARC Overview](docs/source/dmarc.md)** - DMARC protocol explanation
- **[Email Security](docs/source/usage.md)** - Email security configuration
- **[Monitoring Setup](README-DEPLOYMENT.md#monitoring-and-dashboards)** - Security monitoring
- **[Alerting](README-DEPLOYMENT.md#monitoring-and-dashboards)** - Alert configuration

## 🔍 Finding Specific Information

### Quick Reference
- **Getting Started**: [Main README](README.md)
- **Deployment**: [Deployment Guide](README-DEPLOYMENT.md)
- **Configuration**: [Usage Guide](docs/source/usage.md)
- **Troubleshooting**: [Troubleshooting Section](README-DEPLOYMENT.md#troubleshooting)

### Search Tips
- Use `Ctrl+F` to search within documents
- Check the table of contents in each document
- Look for emoji icons (🚀, 📊, 🔧) for quick navigation
- Use the file structure above to locate specific topics

## 📝 Contributing to Documentation

### How to Improve Documentation
1. **Identify gaps**: Look for missing or unclear information
2. **Check accuracy**: Verify that instructions work as written
3. **Improve clarity**: Make complex topics easier to understand
4. **Add examples**: Include practical examples and code snippets
5. **Update regularly**: Keep documentation current with code changes

### Documentation Standards
- Use clear, concise language
- Include code examples where helpful
- Add screenshots for UI-related instructions
- Keep formatting consistent
- Test all instructions before submitting

## 🆘 Getting Help

### Documentation Issues
- **Missing information**: Open an issue on GitHub
- **Incorrect instructions**: Submit a pull request with fixes
- **Unclear explanations**: Suggest improvements via GitHub issues

### Technical Support
- **GitHub Issues**: [Report bugs and request features](https://github.com/domainaware/parsedmarc/issues)
- **GitHub Discussions**: [Ask questions and share ideas](https://github.com/domainaware/parsedmarc/discussions)
- **Community**: Join the community discussions

## 📄 License

This documentation is provided under the same license as parsedmarc (Apache License 2.0).

---

**Last Updated**: September 2024  
**Version**: 1.0  
**Maintainer**: [petethec](https://github.com/petethec)
