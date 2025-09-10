# DMARC Integration Service Overview

## System Architecture

The DMARC integration service processes DMARC reports from AWS S3 and sends them to a Supabase backend for dashboard visualization. The system consists of several components working together:

```
SES → S3 (Raw) → parsedmarc → Supabase → Dashboard
```

### Components

1. **AWS S3 Storage**
   - Raw DMARC reports stored in `ray-dmarc-raw-167290361699`
   - Processed reports stored in `ray-dmarc-processed-167290361699`

2. **AWS ECS Fargate Service**
   - Runs `parsedmarc` container continuously
   - Processes reports from S3
   - Sends data to Supabase via webhooks

3. **Supabase Backend**
   - Edge Functions for data ingestion
   - PostgreSQL database for storage
   - Authentication and API management

4. **Loveable Frontend Dashboard**
   - Displays DMARC data
   - Domain management
   - Report visualization

## Data Flow

1. **Email Processing**: SES receives DMARC reports and stores them in S3 raw bucket
2. **Report Processing**: parsedmarc monitors S3 and processes new reports
3. **Data Transformation**: Native parsedmarc JSON is transformed to dashboard schema
4. **Database Storage**: Transformed data is stored in Supabase PostgreSQL
5. **Dashboard Display**: Frontend queries Supabase to display DMARC data

## Key Features

- **Automated Processing**: Continuous monitoring of S3 for new reports
- **Format Compatibility**: Transforms parsedmarc native format to dashboard schema
- **Secure Authentication**: Bearer token authentication for all API calls
- **Scalable Architecture**: Serverless containers with auto-scaling
- **Real-time Updates**: Webhook-based data delivery to Supabase

## Service Status

- **Status**: ✅ Active and Running
- **ECS Service**: `ray-parsedmarc-svc`
- **Task Definition**: `ray-parsedmarc:10`
- **Cluster**: `ray-core`
- **Region**: `us-west-1`

## Monitoring

- **CloudWatch Logs**: `/ecs/ray-parsedmarc`
- **ECS Console**: AWS ECS service monitoring
- **Supabase Logs**: Edge function execution logs
- **Dashboard**: Real-time data visualization

## Configuration Files

- **ECS Task Definition**: `task-definition-s3-complete.json`
- **parsedmarc Config**: `config/parsedmarc-s3.ini`
- **Docker Image**: `167290361699.dkr.ecr.us-west-1.amazonaws.com/ray/parsedmarc:latest`
- **Deployment Script**: `deploy-dmarc-integration.sh`
