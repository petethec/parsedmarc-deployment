# API Integration Guide

## Supabase Edge Functions

### 1. Internal Ingest Function
**Endpoint**: `https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc`

**Purpose**: Primary endpoint for DMARC report ingestion

**Authentication**: Bearer token required
```
Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456
```

**Expected Payload Format** (Flattened):
```json
{
  "report_id": "unique-report-id",
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

**Response**:
```json
{
  "ok": true,
  "report_id": "unique-report-id",
  "warnings": []
}
```

### 2. Parsedmarc Webhook Function
**Endpoint**: `https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook`

**Purpose**: Compatibility layer for parsedmarc native format

**Authentication**: Same Bearer token as above

**Expected Payload Format** (Parsedmarc Native):
```json
{
  "xml_schema": "draft",
  "report_metadata": {
    "org_name": "example.com",
    "org_email": "noreply-dmarc-support@example.com",
    "report_id": "unique-report-id",
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

**Response**:
```json
{
  "ok": true,
  "forwarded": {
    "ok": true,
    "message": "Report already processed"
  }
}
```

## Database Schema

### Tables

#### dmarc_reports
Stores main DMARC report metadata
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
Stores individual source IP data
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
Stores aggregated data for dashboard
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
Automatically calculates daily rollups
```sql
CREATE OR REPLACE FUNCTION calculate_dmarc_rollup()
RETURNS TRIGGER AS $$
BEGIN
  -- Rollup calculation logic
  INSERT INTO dmarc_rollups (domain, date, total_messages, dkim_pass, spf_pass, dmarc_pass)
  VALUES (NEW.policy_domain, DATE(NEW.report_begin), 
          COALESCE(SUM(s.message_count), 0),
          COALESCE(SUM(s.dkim_pass), 0),
          COALESCE(SUM(s.spf_pass), 0),
          COALESCE(SUM(CASE WHEN s.dkim_pass > 0 AND s.spf_pass > 0 THEN s.message_count ELSE 0 END), 0))
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

## Error Handling

### Common Error Responses

#### 401 Unauthorized
```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing authentication token"
}
```

#### 400 Bad Request
```json
{
  "error": "Missing required fields",
  "message": "Required field 'report_id' is missing"
}
```

#### 404 Not Found
```json
{
  "error": "Domain not found",
  "message": "Domain 'example.com' not found in domains table"
}
```

#### 500 Internal Server Error
```json
{
  "error": "Forwarding failed",
  "details": {
    "name": "FunctionsHttpError",
    "context": {}
  }
}
```

## Testing

### Test Script
Use the provided test script to verify integration:
```bash
./test-dmarc-integration.sh
```

### Manual Testing
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
