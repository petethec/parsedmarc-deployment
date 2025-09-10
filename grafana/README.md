# Grafana Dashboards for parsedmarc

This directory contains Grafana dashboard configurations for visualizing DMARC reports processed by parsedmarc.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Dashboard Import](#dashboard-import)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)

## Overview

The Grafana dashboards provide comprehensive visualization of:

- **DMARC Aggregate Reports**: Summary statistics and trends
- **DMARC Forensic Reports**: Detailed failure analysis
- **SMTP TLS Reports**: TLS reporting data
- **Geographic Analysis**: IP geolocation data
- **Domain Performance**: Per-domain DMARC compliance

## Installation

### Prerequisites

- Grafana 7.0+ installed and running
- Elasticsearch or OpenSearch as data source
- parsedmarc configured to send data to your data store

### Quick Start with Docker

```bash
# Start Grafana with Docker
docker run -d \
  --name grafana \
  -p 3000:3000 \
  -e "GF_SECURITY_ADMIN_PASSWORD=admin" \
  grafana/grafana:latest
```

Access Grafana at `http://localhost:3000` (admin/admin)

## Dashboard Import

### Method 1: Import from Files

1. **Access Grafana**:
   - Navigate to `http://localhost:3000`
   - Login with admin/admin (change password on first login)

2. **Import Dashboard**:
   - Click **+** → **Import**
   - Click **Upload JSON file**
   - Select `Grafana-DMARC_Reports.json`
   - Click **Load**

3. **Configure Data Source**:
   - Select your Elasticsearch/OpenSearch data source
   - Set the index pattern (e.g., `dmarc_*`)
   - Click **Import**

### Method 2: Import via API

```bash
# Import main dashboard
curl -X POST \
  http://admin:admin@localhost:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @Grafana-DMARC_Reports.json
```

### Method 3: Import via Grafana CLI

```bash
# Install Grafana CLI
npm install -g @grafana/toolkit

# Import dashboard
grafana-toolkit import-dashboard \
  --input-file Grafana-DMARC_Reports.json \
  --output-dir /var/lib/grafana/dashboards/
```

## Configuration

### Data Source Setup

#### Elasticsearch Data Source

1. Go to **Configuration > Data Sources**
2. Click **Add data source**
3. Select **Elasticsearch**
4. Configure:
   - **URL**: `http://elasticsearch:9200`
   - **Index name**: `dmarc_*`
   - **Time field**: `@timestamp`

#### OpenSearch Data Source

1. Go to **Configuration > Data Sources**
2. Click **Add data source**
3. Select **OpenSearch**
4. Configure:
   - **URL**: `http://opensearch:9200`
   - **Index name**: `dmarc_*`
   - **Time field**: `@timestamp`

### Dashboard Variables

Configure these variables for optimal dashboard performance:

- **$time_range**: Default time range (e.g., "Last 30 days")
- **$domain**: Domain filter (e.g., "example.com")
- **$org_name**: Organization name filter
- **$index**: Index pattern (e.g., "dmarc_*")

## Available Dashboards

### 1. DMARC Aggregate Reports (`Grafana-DMARC_Reports.json`)

**Features**:
- Summary statistics overview
- Pass/fail rate trends
- Top failing domains
- Geographic distribution
- Policy compliance metrics

**Panels**:
- Total reports processed
- Pass/fail percentages
- Policy alignment statistics
- Geographic heat map
- Time series charts

### 2. DMARC Forensic Reports

**Features**:
- Detailed failure analysis
- Authentication failure reasons
- Source IP analysis
- Message authentication details

**Panels**:
- Forensic report count
- Failure reason breakdown
- Source IP distribution
- Authentication method analysis

### 3. SMTP TLS Reports

**Features**:
- TLS connection analysis
- Certificate validation status
- Encryption strength metrics
- Connection failure analysis

**Panels**:
- TLS report count
- Certificate validation status
- Encryption cipher analysis
- Connection success rates

## Customization

### Adding New Panels

1. **Edit Dashboard**:
   - Click **Settings** → **JSON Model**
   - Modify the JSON structure
   - Save changes

2. **Create Custom Queries**:
   ```json
   {
     "query": {
       "bool": {
         "must": [
           {"term": {"report_type": "aggregate"}},
           {"range": {"@timestamp": {"gte": "$__timeFrom", "lte": "$__timeTo"}}}
         ]
       }
     }
   }
   ```

### Modifying Visualizations

1. **Change Chart Types**:
   - Edit panel settings
   - Select visualization type
   - Configure display options

2. **Add Filters**:
   - Use dashboard variables
   - Configure template variables
   - Set default values

## Troubleshooting

### Common Issues

1. **No data showing**:
   - Verify data source connection
   - Check index pattern matches
   - Ensure time range is correct

2. **Dashboard not loading**:
   - Check JSON syntax
   - Verify all required fields
   - Check Grafana logs

3. **Performance issues**:
   - Optimize queries
   - Use time-based filters
   - Consider data retention policies

### Debugging

#### Check Data Source

```bash
# Test Elasticsearch connection
curl http://localhost:9200/_cluster/health

# Check indices
curl http://localhost:9200/_cat/indices/dmarc_*
```

#### Check Grafana Logs

```bash
# Docker logs
docker logs grafana

# System logs
journalctl -u grafana-server
```

#### Verify Dashboard JSON

```bash
# Validate JSON syntax
python -m json.tool Grafana-DMARC_Reports.json
```

## Performance Optimization

### Query Optimization

1. **Use time-based filters**:
   - Always include time range
   - Use appropriate time intervals
   - Avoid querying all data

2. **Index optimization**:
   - Use proper index patterns
   - Configure index lifecycle management
   - Set appropriate refresh intervals

3. **Dashboard optimization**:
   - Limit number of panels
   - Use appropriate refresh rates
   - Cache frequently used queries

### Resource Management

1. **Memory usage**:
   - Monitor Grafana memory consumption
   - Adjust query limits
   - Use data source caching

2. **Network optimization**:
   - Use local data sources when possible
   - Configure connection pooling
   - Monitor network latency

## Security

### Access Control

1. **User Management**:
   - Create specific users for dashboard access
   - Use role-based access control
   - Enable authentication

2. **Data Protection**:
   - Secure data source connections
   - Use HTTPS for all connections
   - Regular security updates

### Best Practices

- Change default passwords
- Use strong authentication
- Regular security audits
- Monitor access logs
- Keep Grafana updated

## Support

For additional help:

- [Grafana Documentation](https://grafana.com/docs/)
- [parsedmarc Issues](https://github.com/domainaware/parsedmarc/issues)
- [Grafana Community](https://community.grafana.com/)

## Contributing

To contribute dashboard improvements:

1. Fork the repository
2. Create your dashboard modifications
3. Test thoroughly
4. Submit a pull request

## License

These dashboards are provided under the same license as parsedmarc (Apache License 2.0).

