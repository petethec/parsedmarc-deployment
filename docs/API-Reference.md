# API Reference

## Supabase Edge Functions

### Internal Ingest DMARC

**Endpoint**: `POST https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc`

**Description**: Primary endpoint for ingesting DMARC reports in flattened format.

**Authentication**: Bearer token required
```
Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
```

#### Request Body

```typescript
interface DmarcReportRequest {
  report_id: string;           // Unique report identifier
  org_name: string;           // Organization name
  org_email: string;          // Organization email
  report_begin: string;       // Report start time (ISO 8601)
  report_end: string;         // Report end time (ISO 8601)
  policy_domain: string;      // Policy domain
  policy_p: string;           // Policy disposition (none, quarantine, reject)
  policy_sp: string;          // Subdomain policy disposition
  policy_pct: number;         // Policy percentage (0-100)
  policy_adkim: string;       // DKIM alignment mode (r, s)
  policy_aspf: string;        // SPF alignment mode (r, s)
  sources: DmarcSource[];     // Array of source IP data
}

interface DmarcSource {
  source_ip: string;          // Source IP address
  provider_guess: string;     // Provider identification
  message_count: number;      // Number of messages
  dkim_pass: number;          // DKIM pass count
  spf_pass: number;           // SPF pass count
}
```

#### Example Request

```json
{
  "report_id": "test-12345-67890",
  "org_name": "example.com",
  "org_email": "noreply-dmarc-support@example.com",
  "report_begin": "2022-01-01T20:00:00Z",
  "report_end": "2022-01-02T19:59:59Z",
  "policy_domain": "example.com",
  "policy_p": "quarantine",
  "policy_sp": "quarantine",
  "policy_pct": 100,
  "policy_adkim": "r",
  "policy_aspf": "r",
  "sources": [
    {
      "source_ip": "192.168.1.100",
      "provider_guess": "example.com",
      "message_count": 150,
      "dkim_pass": 150,
      "spf_pass": 150
    }
  ]
}
```

#### Response

**Success (200)**:
```json
{
  "ok": true,
  "report_id": "test-12345-67890",
  "warnings": []
}
```

**Error (400)**:
```json
{
  "error": "Missing required fields",
  "message": "Required field 'report_id' is missing"
}
```

**Error (404)**:
```json
{
  "error": "Domain not found",
  "message": "Domain 'example.com' not found in domains table"
}
```

**Error (401)**:
```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing authentication token"
}
```

### Parsedmarc Webhook

**Endpoint**: `POST https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook`

**Description**: Compatibility layer for parsedmarc native format. Transforms parsedmarc JSON to flattened format and forwards to internal-ingest-dmarc.

**Authentication**: Same Bearer token as above

#### Request Body

```typescript
interface ParsedmarcReport {
  xml_schema: string;         // XML schema version
  report_metadata: {
    org_name: string;         // Organization name
    org_email: string;        // Organization email
    report_id: string;        // Report identifier
    begin_date: string;       // Begin date (YYYY-MM-DD HH:MM:SS)
    end_date: string;         // End date (YYYY-MM-DD HH:MM:SS)
  };
  policy_published: {
    domain: string;           // Policy domain
    p: string;                // Policy disposition
    sp: string;               // Subdomain policy disposition
    pct: number;              // Policy percentage
    adkim: string;            // DKIM alignment mode
    aspf: string;             // SPF alignment mode
  };
  records: ParsedmarcRecord[];
}

interface ParsedmarcRecord {
  source: {
    ip_address: string;       // Source IP address
    reverse_dns?: string;     // Reverse DNS name
    base_domain?: string;     // Base domain
  };
  count: number;              // Message count
  alignment: {
    spf: boolean;             // SPF alignment
    dkim: boolean;            // DKIM alignment
    dmarc: boolean;           // DMARC alignment
  };
}
```

#### Example Request

```json
{
  "xml_schema": "draft",
  "report_metadata": {
    "org_name": "example.com",
    "org_email": "noreply-dmarc-support@example.com",
    "report_id": "test-12345-67890",
    "begin_date": "2022-01-01 20:00:00",
    "end_date": "2022-01-02 19:59:59"
  },
  "policy_published": {
    "domain": "example.com",
    "p": "quarantine",
    "sp": "quarantine",
    "pct": 100,
    "adkim": "r",
    "aspf": "r"
  },
  "records": [
    {
      "source": {
        "ip_address": "192.168.1.100",
        "reverse_dns": "test.example.com",
        "base_domain": "example.com"
      },
      "count": 150,
      "alignment": {
        "spf": true,
        "dkim": true,
        "dmarc": true
      }
    }
  ]
}
```

#### Response

**Success (200)**:
```json
{
  "ok": true,
  "forwarded": {
    "ok": true,
    "message": "Report already processed"
  }
}
```

**Error (500)**:
```json
{
  "error": "Forwarding failed",
  "details": {
    "name": "FunctionsHttpError",
    "context": {}
  }
}
```

## Database Schema

### Tables

#### dmarc_reports
Stores main DMARC report metadata.

```sql
CREATE TABLE dmarc_reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id TEXT UNIQUE NOT NULL,
  org_name TEXT NOT NULL,
  org_email TEXT NOT NULL,
  report_begin TIMESTAMPTZ NOT NULL,
  report_end TIMESTAMPTZ NOT NULL,
  policy_domain TEXT NOT NULL,
  policy_p TEXT NOT NULL,
  policy_sp TEXT NOT NULL,
  policy_pct INTEGER NOT NULL,
  policy_adkim TEXT NOT NULL,
  policy_aspf TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### dmarc_sources
Stores individual source IP data.

```sql
CREATE TABLE dmarc_sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  report_id UUID REFERENCES dmarc_reports(id) ON DELETE CASCADE,
  source_ip INET NOT NULL,
  provider_guess TEXT,
  message_count INTEGER NOT NULL,
  dkim_pass INTEGER NOT NULL,
  spf_pass INTEGER NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### dmarc_rollups
Stores aggregated data for dashboard.

```sql
CREATE TABLE dmarc_rollups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  domain TEXT NOT NULL,
  date DATE NOT NULL,
  total_messages INTEGER DEFAULT 0,
  dkim_pass INTEGER DEFAULT 0,
  spf_pass INTEGER DEFAULT 0,
  dmarc_pass INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(domain, date)
);
```

### RPC Functions

#### calculate_dmarc_rollup
Automatically calculates daily rollups when new reports are inserted.

```sql
CREATE OR REPLACE FUNCTION calculate_dmarc_rollup()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO dmarc_rollups (domain, date, total_messages, dkim_pass, spf_pass, dmarc_pass)
  SELECT 
    NEW.policy_domain,
    DATE(NEW.report_begin),
    COALESCE(SUM(s.message_count), 0),
    COALESCE(SUM(s.dkim_pass), 0),
    COALESCE(SUM(s.spf_pass), 0),
    COALESCE(SUM(CASE WHEN s.dkim_pass > 0 AND s.spf_pass > 0 THEN s.message_count ELSE 0 END), 0)
  FROM dmarc_sources s
  WHERE s.report_id = NEW.id
  ON CONFLICT (domain, date) DO UPDATE SET
    total_messages = EXCLUDED.total_messages,
    dkim_pass = EXCLUDED.dkim_pass,
    spf_pass = EXCLUDED.spf_pass,
    dmarc_pass = EXCLUDED.dmarc_pass;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## Error Codes

### HTTP Status Codes

| Code | Description | Common Causes |
|------|-------------|---------------|
| 200 | Success | Request processed successfully |
| 400 | Bad Request | Missing required fields, invalid JSON |
| 401 | Unauthorized | Invalid or missing authentication token |
| 404 | Not Found | Domain not found in database |
| 500 | Internal Server Error | Database error, function failure |

### Error Response Format

```typescript
interface ErrorResponse {
  error: string;              // Error type
  message?: string;           // Human-readable error message
  details?: {                 // Additional error details
    name?: string;
    context?: any;
  };
}
```

## Rate Limits

- **Internal Ingest**: 100 requests per minute per IP
- **Parsedmarc Webhook**: 100 requests per minute per IP
- **Database**: 1000 queries per minute per connection

## Authentication

### Bearer Token

All API endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
```

### Token Requirements

- **Length**: 64 characters
- **Format**: Hexadecimal string
- **Expiration**: No expiration (rotate manually)
- **Scope**: Full access to DMARC ingestion endpoints

## Testing

### Test Scripts

#### Basic Integration Test
```bash
./test-dmarc-integration.sh
```

#### Manual Testing
```bash
# Test flattened format
curl -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d '{"report_id": "test-123", "org_name": "example.com", ...}'

# Test parsedmarc format
curl -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d '{"xml_schema": "draft", "report_metadata": {...}, ...}'
```

### Health Check

```bash
# Check service health
curl -X GET "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc/health" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456"
```

## SDK Examples

### JavaScript/TypeScript

```typescript
const SUPABASE_URL = 'https://buctxwcqzitrqruoomkz.supabase.co';
const TOKEN = 'A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456';

async function ingestDmarcReport(report: DmarcReportRequest) {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/internal-ingest-dmarc`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${TOKEN}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(report)
  });
  
  return await response.json();
}
```

### Python

```python
import requests
import json

SUPABASE_URL = 'https://buctxwcqzitrqruoomkz.supabase.co'
TOKEN = 'A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456'

def ingest_dmarc_report(report):
    response = requests.post(
        f'{SUPABASE_URL}/functions/v1/internal-ingest-dmarc',
        headers={
            'Authorization': f'Bearer {TOKEN}',
            'Content-Type': 'application/json'
        },
        json=report
    )
    return response.json()
```

### cURL

```bash
# Basic request
curl -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d @report.json

# With verbose output
curl -v -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d @report.json
```
