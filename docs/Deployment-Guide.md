# Deployment Guide

## Prerequisites

### AWS CLI Configuration
```bash
# Verify AWS CLI is configured
aws sts get-caller-identity

# Ensure you have the following permissions:
# - ECS: Create/update services, task definitions
# - S3: Read/write access to DMARC buckets
# - IAM: Create/update roles and policies
# - CloudWatch: Create log groups
```

### Required AWS Resources
- ECS Cluster: `ray-core`
- S3 Buckets: `ray-dmarc-raw-167290361699`, `ray-dmarc-processed-167290361699`
- IAM Roles: `ray-parsedmarc-task-role`, `ecsTaskExecutionRole`
- CloudWatch Log Group: `/ecs/ray-parsedmarc`

### Supabase Configuration
- Project ID: `buctxwcqzitrqruoomkz`
- Edge Functions: `internal-ingest-dmarc`, `parsedmarc-webhook`
- Database tables: `dmarc_reports`, `dmarc_sources`, `dmarc_rollups`
- Authentication token: `DMARC_INGEST_TOKEN`

## Deployment Steps

### 1. Build and Push Docker Image

```bash
# Build the Docker image
docker build -f Dockerfile.s3 -t parsedmarc-s3 .

# Tag for ECR
docker tag parsedmarc-s3:latest 167290361699.dkr.ecr.us-west-1.amazonaws.com/ray/parsedmarc:latest

# Login to ECR
aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 167290361699.dkr.ecr.us-west-1.amazonaws.com

# Push to ECR
docker push 167290361699.dkr.ecr.us-west-1.amazonaws.com/ray/parsedmarc:latest
```

### 2. Update Task Definition

```bash
# Register new task definition
aws ecs register-task-definition --cli-input-json file://task-definition-s3-complete.json

# Verify registration
aws ecs describe-task-definition --task-definition ray-parsedmarc
```

### 3. Deploy Service Update

```bash
# Update ECS service
aws ecs update-service \
  --cluster ray-core \
  --service ray-parsedmarc-svc \
  --task-definition ray-parsedmarc:latest

# Wait for deployment to complete
aws ecs wait services-stable --cluster ray-core --services ray-parsedmarc-svc
```

### 4. Verify Deployment

```bash
# Check service status
aws ecs describe-services --cluster ray-core --services ray-parsedmarc-svc

# Check running tasks
aws ecs list-tasks --cluster ray-core --service-name ray-parsedmarc-svc

# Check logs
aws logs tail /ecs/ray-parsedmarc --follow
```

## Automated Deployment Script

Use the provided deployment script for automated deployment:

```bash
# Make script executable
chmod +x deploy-dmarc-integration.sh

# Run deployment
./deploy-dmarc-integration.sh
```

### Deployment Script Contents
```bash
#!/bin/bash

set -e

echo "🚀 Starting DMARC Integration Deployment..."

TASK_DEFINITION_FILE="/Users/petecrosby/parsedmarc/parsedmarc/task-definition-s3-complete.json"
CLUSTER_NAME="ray-core"
SERVICE_NAME="ray-parsedmarc-svc"
TASK_FAMILY="ray-parsedmarc"

# 1. Register the updated task definition
echo "📝 Registering updated task definition..."
REGISTER_OUTPUT=$(aws ecs register-task-definition --cli-input-json file://${TASK_DEFINITION_FILE})
TASK_DEFINITION_ARN=$(echo ${REGISTER_OUTPUT} | jq -r '.taskDefinition.taskDefinitionArn')
TASK_DEFINITION_REVISION=$(echo ${REGISTER_OUTPUT} | jq -r '.taskDefinition.revision')

echo "✅ Task definition registered: ${TASK_DEFINITION_ARN}"

# 2. Update the ECS service to use the new task definition
echo "🔄 Updating ECS service..."
aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_DEFINITION_REVISION} --desired-count 1

echo "⏳ Waiting for deployment to complete..."
aws ecs wait services-stable --cluster ${CLUSTER_NAME} --services ${SERVICE_NAME}

# 3. Check service status
echo "📊 Checking service status..."
aws ecs describe-services --cluster ${CLUSTER_NAME} --services ${SERVICE_NAME} --query 'services[0].{DesiredCount:desiredCount,RunningCount:runningCount,Status:status,TaskDefinition:taskDefinition}' --output table

echo "✅ DMARC Integration Deployment Complete!"
```

## Configuration Updates

### Updating Environment Variables

To update environment variables, modify the task definition and redeploy:

```bash
# Edit task-definition-s3-complete.json
# Update the environment variables in the containerDefinitions section

# Register updated task definition
aws ecs register-task-definition --cli-input-json file://task-definition-s3-complete.json

# Update service
aws ecs update-service --cluster ray-core --service ray-parsedmarc-svc --task-definition ray-parsedmarc:latest
```

### Updating Webhook URLs

```bash
# Update webhook URLs in task definition
# Change the WEBHOOK_*_URL environment variables

# Redeploy
./deploy-dmarc-integration.sh
```

### Updating Authentication Token

```bash
# Update DMARC_INGEST_TOKEN in task definition
# Ensure token matches Supabase configuration

# Redeploy
./deploy-dmarc-integration.sh
```

## Rollback Procedures

### Rollback to Previous Version

```bash
# List available task definitions
aws ecs list-task-definitions --family-prefix ray-parsedmarc

# Rollback to specific revision
aws ecs update-service --cluster ray-core --service ray-parsedmarc-svc --task-definition ray-parsedmarc:9

# Wait for rollback to complete
aws ecs wait services-stable --cluster ray-core --services ray-parsedmarc-svc
```

### Emergency Stop

```bash
# Scale service to 0
aws ecs update-service --cluster ray-core --service ray-parsedmarc-svc --desired-count 0

# Wait for tasks to stop
aws ecs wait services-stable --cluster ray-core --services ray-parsedmarc-svc
```

## Testing Deployment

### Pre-deployment Testing

```bash
# Test webhook endpoints
./test-dmarc-integration.sh

# Verify S3 access
aws s3 ls s3://ray-dmarc-raw-167290361699/
aws s3 ls s3://ray-dmarc-processed-167290361699/
```

### Post-deployment Testing

```bash
# Check service health
aws ecs describe-services --cluster ray-core --services ray-parsedmarc-svc

# Monitor logs
aws logs tail /ecs/ray-parsedmarc --follow

# Test with sample data
curl -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d '{"report_id": "deployment-test", "org_name": "example.com", ...}'
```

## Monitoring and Alerts

### CloudWatch Alarms

```bash
# Create alarm for service down
aws cloudwatch put-metric-alarm \
  --alarm-name "ray-parsedmarc-service-down" \
  --alarm-description "Alert when parsedmarc service has no running tasks" \
  --metric-name RunningCount \
  --namespace AWS/ECS \
  --statistic Average \
  --period 300 \
  --threshold 1 \
  --comparison-operator LessThanThreshold \
  --dimensions Name=ServiceName,Value=ray-parsedmarc-svc Name=ClusterName,Value=ray-core \
  --evaluation-periods 2
```

### Log Monitoring

```bash
# Set up log group retention
aws logs put-retention-policy \
  --log-group-name /ecs/ray-parsedmarc \
  --retention-in-days 30
```

## Security Considerations

### IAM Permissions

Ensure the task role has minimal required permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::ray-dmarc-raw-167290361699/*",
        "arn:aws:s3:::ray-dmarc-processed-167290361699/*",
        "arn:aws:s3:::ray-dmarc-raw-167290361699",
        "arn:aws:s3:::ray-dmarc-processed-167290361699"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:us-west-1:167290361699:log-group:/ecs/ray-parsedmarc:*"
    }
  ]
}
```

### Network Security

- ECS tasks run in private subnets with NAT gateway
- Security groups restrict outbound traffic
- HTTPS only for webhook communications

### Data Encryption

- S3 buckets use server-side encryption
- HTTPS for all API communications
- Bearer token authentication for webhooks

## Maintenance

### Regular Updates

1. **Docker Image Updates**
   - Update base image regularly
   - Apply security patches
   - Test updates in staging environment

2. **Configuration Updates**
   - Review and update environment variables
   - Update webhook URLs if needed
   - Rotate authentication tokens

3. **Monitoring**
   - Review CloudWatch logs regularly
   - Monitor service health
   - Check for error patterns

### Backup Procedures

1. **Task Definition Backup**
   - Export task definitions before changes
   - Keep version history
   - Document configuration changes

2. **S3 Data Backup**
   - Enable S3 versioning
   - Set up cross-region replication if needed
   - Regular backup verification

3. **Database Backup**
   - Supabase handles automatic backups
   - Export data regularly for additional safety
   - Test restore procedures
