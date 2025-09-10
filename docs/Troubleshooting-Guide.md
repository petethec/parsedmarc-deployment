# Troubleshooting Guide

## Common Issues and Solutions

### 1. ECS Service Not Starting

#### Symptoms
- Service shows "PENDING" status
- Tasks keep stopping
- No logs appearing in CloudWatch

#### Diagnosis
```bash
# Check service status
aws ecs describe-services --cluster ray-core --services ray-parsedmarc-svc

# Check task status
aws ecs list-tasks --cluster ray-core --service-name ray-parsedmarc-svc

# Check task details
aws ecs describe-tasks --cluster ray-core --tasks <task-arn>
```

#### Solutions
1. **IMAP Configuration Issues**
   - Ensure all IMAP environment variables are set to "disabled"
   - Check task definition includes all required IMAP variables

2. **Resource Constraints**
   - Verify CPU and memory allocation (512 CPU, 1024 MB memory)
   - Check if Fargate has sufficient capacity in the region

3. **IAM Permissions**
   - Verify task role has S3 read/write permissions
   - Check execution role has ECR pull permissions

### 2. Webhook Authentication Failures

#### Symptoms
- 401 Unauthorized errors in logs
- "Invalid token" messages
- Webhook calls failing

#### Diagnosis
```bash
# Test webhook authentication
curl -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

#### Solutions
1. **Token Verification**
   - Verify `DMARC_INGEST_TOKEN` in ECS task definition
   - Check token is correctly set in Supabase Edge Function
   - Ensure token hasn't expired

2. **Token Format**
   - Ensure token is exactly 64 characters
   - Check for any whitespace or special characters
   - Verify token matches exactly in both places

### 3. S3 Access Issues

#### Symptoms
- "Access Denied" errors in logs
- No reports being processed
- S3 bucket not found errors

#### Diagnosis
```bash
# Test S3 access
aws s3 ls s3://ray-dmarc-raw-167290361699/
aws s3 ls s3://ray-dmarc-processed-167290361699/

# Check IAM permissions
aws iam get-role --role-name ray-parsedmarc-task-role
```

#### Solutions
1. **IAM Permissions**
   - Add S3 read/write permissions to task role
   - Ensure bucket policies allow ECS task access
   - Check for any IP restrictions

2. **Bucket Configuration**
   - Verify bucket names are correct
   - Check bucket exists and is accessible
   - Ensure region matches (us-west-1)

### 4. Database Connection Issues

#### Symptoms
- "Domain not found" errors
- Database connection timeouts
- Supabase function failures

#### Diagnosis
```bash
# Test Supabase connectivity
curl -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d '{
    "report_id": "test-123",
    "org_name": "example.com",
    "org_email": "test@example.com",
    "report_begin": "2022-01-01T20:00:00Z",
    "report_end": "2022-01-02T19:59:59Z",
    "policy_domain": "example.com",
    "policy_p": "quarantine",
    "policy_sp": "quarantine",
    "policy_pct": 100,
    "policy_adkim": "r",
    "policy_aspf": "r",
    "sources": [{"source_ip": "127.0.0.1", "provider_guess": "localhost", "message_count": 1, "dkim_pass": 1, "spf_pass": 1}]
  }'
```

#### Solutions
1. **Domain Registration**
   - Add domain to Supabase domains table
   - Verify domain exists before sending reports
   - Check domain format and validity

2. **Database Schema**
   - Verify all required tables exist
   - Check RPC functions are properly created
   - Ensure proper permissions on tables

### 5. Parsedmarc Processing Issues

#### Symptoms
- No reports being processed
- Parsedmarc errors in logs
- Malformed JSON output

#### Diagnosis
```bash
# Check parsedmarc logs
aws logs tail /ecs/ray-parsedmarc --follow

# Test parsedmarc configuration
aws ecs execute-command --cluster ray-core --task <task-arn> --container parsedmarc --interactive --command "/bin/bash"
```

#### Solutions
1. **Configuration Issues**
   - Verify parsedmarc.ini configuration
   - Check S3 bucket and path settings
   - Ensure webhook URLs are correct

2. **Report Format Issues**
   - Check if reports are valid XML
   - Verify report structure matches expected format
   - Test with sample reports

### 6. Performance Issues

#### Symptoms
- Slow report processing
- High memory usage
- Timeout errors

#### Diagnosis
```bash
# Check ECS metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ServiceName,Value=ray-parsedmarc-svc Name=ClusterName,Value=ray-core \
  --start-time 2023-01-01T00:00:00Z \
  --end-time 2023-01-02T00:00:00Z \
  --period 300 \
  --statistics Average
```

#### Solutions
1. **Resource Scaling**
   - Increase CPU and memory allocation
   - Consider using larger Fargate instance types
   - Implement auto-scaling if needed

2. **Processing Optimization**
   - Adjust `n_procs` setting in configuration
   - Optimize DNS timeout settings
   - Consider batch processing for large volumes

## Monitoring and Logging

### CloudWatch Logs
```bash
# View recent logs
aws logs tail /ecs/ray-parsedmarc --follow

# Search for specific errors
aws logs filter-log-events \
  --log-group-name /ecs/ray-parsedmarc \
  --filter-pattern "ERROR"
```

### ECS Service Monitoring
```bash
# Check service status
aws ecs describe-services --cluster ray-core --services ray-parsedmarc-svc

# Check running tasks
aws ecs list-tasks --cluster ray-core --service-name ray-parsedmarc-svc

# Check task health
aws ecs describe-tasks --cluster ray-core --tasks <task-arn>
```

### Supabase Monitoring
- Check Edge Function logs in Supabase dashboard
- Monitor database performance
- Review authentication logs

## Emergency Procedures

### Service Restart
```bash
# Force new deployment
aws ecs update-service --cluster ray-core --service ray-parsedmarc-svc --force-new-deployment

# Scale down and up
aws ecs update-service --cluster ray-core --service ray-parsedmarc-svc --desired-count 0
aws ecs update-service --cluster ray-core --service ray-parsedmarc-svc --desired-count 1
```

### Configuration Rollback
```bash
# Rollback to previous task definition
aws ecs update-service --cluster ray-core --service ray-parsedmarc-svc --task-definition ray-parsedmarc:9
```

### Data Recovery
```bash
# Check S3 for processed reports
aws s3 ls s3://ray-dmarc-processed-167290361699/reports/ --recursive

# Re-process reports if needed
# (Manual process - would need to trigger parsedmarc manually)
```

## Health Checks

### Automated Health Check Script
```bash
#!/bin/bash

# Check ECS service
SERVICE_STATUS=$(aws ecs describe-services --cluster ray-core --services ray-parsedmarc-svc --query 'services[0].status' --output text)
echo "ECS Service Status: $SERVICE_STATUS"

# Check running tasks
TASK_COUNT=$(aws ecs list-tasks --cluster ray-core --service-name ray-parsedmarc-svc --query 'taskArns | length(@)')
echo "Running Tasks: $TASK_COUNT"

# Check webhook connectivity
WEBHOOK_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d '{"test": "health"}')
echo "Webhook Status: $WEBHOOK_STATUS"

# Check S3 access
S3_STATUS=$(aws s3 ls s3://ray-dmarc-raw-167290361699/ > /dev/null 2>&1 && echo "OK" || echo "FAIL")
echo "S3 Access: $S3_STATUS"
```

## Support Contacts

- **AWS Support**: AWS Console → Support
- **Supabase Support**: Supabase Dashboard → Support
- **Logs**: CloudWatch Logs → `/ecs/ray-parsedmarc`
- **ECS Console**: AWS ECS → Clusters → ray-core → Services → ray-parsedmarc-svc
