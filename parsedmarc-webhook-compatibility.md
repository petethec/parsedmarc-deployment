# Parsedmarc Webhook Compatibility

## Overview
This document describes the compatibility webhook that transforms parsedmarc's native JSON format to the flattened format expected by the internal-ingest-dmarc function.

## Implementation Plan

### 1. Create New Edge Function: `parsedmarc-webhook`

**Location**: `/supabase/functions/parsedmarc-webhook/index.ts`

**Purpose**: 
- Accepts parsedmarc's native JSON structure
- Transforms it to flattened DmarcReportRequest format
- Calls internal-ingest-dmarc with transformed data
- Handles authentication and error responses

### 2. Transformation Logic

**Input**: Parsedmarc native JSON
```json
{
  "xml_schema": "draft",
  "report_metadata": {
    "org_name": "example.com",
    "org_email": "noreply@example.com",
    "report_id": "12345",
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

**Output**: Flattened format for internal-ingest-dmarc
```json
{
  "report_id": "12345",
  "org_name": "example.com",
  "org_email": "noreply@example.com",
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
      "source_ptr": "test.example.com",
      "source_base_domain": "example.com",
      "provider_guess": "example.com",
      "message_count": 150,
      "dkim_pass": 150,
      "spf_pass": 150,
      "dkim_fail": 0,
      "spf_fail": 0
    }
  ]
}
```

### 3. Parsedmarc Configuration Update

**File**: `config/parsedmarc-s3.ini`

```ini
[webhook]
aggregate_url = https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook
forensic_url = https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook
smtp_tls_url = https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook
timeout = 30
```

### 4. ECS Task Definition Update

**Environment Variables**:
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
}
```

## Testing Steps

1. **Add Domain**: Ensure the domain exists in the dashboard
2. **Deploy Webhook**: Create the parsedmarc-webhook function
3. **Update Config**: Update parsedmarc configuration
4. **Test**: Send test payload to verify transformation
5. **Monitor**: Check logs and database for data

## Benefits

- ✅ **No Code Changes**: parsedmarc works with native JSON
- ✅ **Backward Compatible**: Existing internal-ingest-dmarc unchanged
- ✅ **Production Ready**: Handles authentication and errors
- ✅ **Maintainable**: Clear separation of concerns
