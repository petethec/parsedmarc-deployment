#!/bin/bash

# DMARC Integration Test Script
# Tests both the current flattened format and provides instructions for compatibility webhook

set -e

echo "🧪 Testing DMARC Integration..."

# Test 1: Current flattened format (requires domain to exist first)
echo "📋 Test 1: Flattened format (requires domain in dashboard first)"
echo "   Domain: example.com must exist in /domains"
echo "   If you get 'Domain not found', add the domain first"

curl -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d '{
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
  }' \
  -s | jq .

echo ""
echo "📋 Test 2: Parsedmarc native format (will fail until compatibility webhook is created)"
echo "   This is what parsedmarc actually sends"

curl -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d '{
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
  }' \
  -s | jq .

echo ""
echo "✅ Test Complete!"
echo ""
echo "📝 Next Steps:"
echo "1. Add 'example.com' domain in your dashboard at /domains"
echo "2. Create the parsedmarc-webhook compatibility function"
echo "3. Re-run this test to verify both formats work"
echo "4. Deploy the updated ECS task definition"
echo ""
echo "🔗 Monitor logs at:"
echo "   https://supabase.com/dashboard/project/buctxwcqzitrqruoomkz/functions/internal-ingest-dmarc/logs"
