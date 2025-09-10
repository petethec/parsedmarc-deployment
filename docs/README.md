# DMARC Integration Service Documentation

This repository contains the complete DMARC integration service that processes DMARC reports from AWS S3 and sends them to a Supabase backend for dashboard visualization.

## 📁 Documentation Structure

- **[DMARC-Integration-Overview.md](./DMARC-Integration-Overview.md)** - High-level system architecture and overview
- **[API-Integration-Guide.md](./API-Integration-Guide.md)** - Detailed API documentation and database schema
- **[Configuration-Management.md](./Configuration-Management.md)** - Environment variables, configuration files, and AWS resources
- **[Troubleshooting-Guide.md](./Troubleshooting-Guide.md)** - Common issues, solutions, and monitoring procedures
- **[Deployment-Guide.md](./Deployment-Guide.md)** - Step-by-step deployment and maintenance procedures

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured with appropriate permissions
- Docker installed and running
- Access to Supabase project

### Deploy the Service
```bash
# 1. Build and push Docker image
docker build -f Dockerfile.s3 -t parsedmarc-s3 .
docker tag parsedmarc-s3:latest 167290361699.dkr.ecr.us-west-1.amazonaws.com/ray/parsedmarc:latest
aws ecr get-login-password --region us-west-1 | docker login --username AWS --password-stdin 167290361699.dkr.ecr.us-west-1.amazonaws.com
docker push 167290361699.dkr.ecr.us-west-1.amazonaws.com/ray/parsedmarc:latest

# 2. Deploy using automated script
chmod +x deploy-dmarc-integration.sh
./deploy-dmarc-integration.sh

# 3. Test the integration
./test-dmarc-integration.sh
```

## 🏗️ System Architecture

```
SES → S3 (Raw) → parsedmarc → Supabase → Dashboard
```

### Components
- **AWS S3**: Stores raw and processed DMARC reports
- **AWS ECS Fargate**: Runs parsedmarc container continuously
- **Supabase**: Backend database and Edge Functions
- **Loveable Frontend**: Dashboard for DMARC data visualization

## 🔧 Key Features

- **Automated Processing**: Continuous monitoring of S3 for new reports
- **Format Compatibility**: Transforms parsedmarc native format to dashboard schema
- **Secure Authentication**: Bearer token authentication for all API calls
- **Scalable Architecture**: Serverless containers with auto-scaling
- **Real-time Updates**: Webhook-based data delivery to Supabase

## 📊 Current Status

- **Service Status**: ✅ Active and Running
- **ECS Service**: `ray-parsedmarc-svc`
- **Task Definition**: `ray-parsedmarc:10`
- **Cluster**: `ray-core`
- **Region**: `us-west-1`

## 🔍 Monitoring

### CloudWatch Logs
```bash
aws logs tail /ecs/ray-parsedmarc --follow
```

### ECS Service Status
```bash
aws ecs describe-services --cluster ray-core --services ray-parsedmarc-svc
```

### Supabase Monitoring
- Edge Function logs in Supabase dashboard
- Database performance metrics
- Authentication logs

## 🛠️ Configuration

### Environment Variables
- **S3_BUCKET**: `ray-dmarc-processed-167290361699`
- **S3_RAW_BUCKET**: `ray-dmarc-raw-167290361699`
- **AWS_DEFAULT_REGION**: `us-west-1`
- **DMARC_INGEST_TOKEN**: Authentication token for Supabase

### Supabase Endpoints
- **Internal Ingest**: `https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc`
- **Parsedmarc Webhook**: `https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/parsedmarc-webhook`

## 🚨 Troubleshooting

### Common Issues
1. **Service Not Starting**: Check IMAP environment variables are set to "disabled"
2. **Authentication Failures**: Verify `DMARC_INGEST_TOKEN` is correct
3. **S3 Access Issues**: Check IAM permissions and bucket policies
4. **Database Connection**: Ensure domain exists in Supabase domains table

### Quick Fixes
```bash
# Restart service
aws ecs update-service --cluster ray-core --service ray-parsedmarc-svc --force-new-deployment

# Check logs
aws logs tail /ecs/ray-parsedmarc --follow

# Test webhook
curl -X POST "https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc" \
  -H "Authorization: Bearer A1b2c3d4e5f6789012345678901234567890abcdef1234567890abcdef123456" \
  -H "Content-Type: application/json" \
  -d '{"test": "data"}'
```

## 📝 Maintenance

### Regular Tasks
- Monitor service health and logs
- Update Docker images for security patches
- Rotate authentication tokens
- Review and update configuration

### Backup Procedures
- Task definition versioning
- S3 data backup and versioning
- Database backup (handled by Supabase)

## 🔐 Security

### Authentication
- Bearer token authentication for all API calls
- IAM roles with minimal required permissions
- HTTPS only for all communications

### Data Protection
- S3 server-side encryption
- Secure webhook communications
- Regular token rotation

## 📞 Support

- **AWS Support**: AWS Console → Support
- **Supabase Support**: Supabase Dashboard → Support
- **Logs**: CloudWatch Logs → `/ecs/ray-parsedmarc`
- **ECS Console**: AWS ECS → Clusters → ray-core → Services → ray-parsedmarc-svc

## 📚 Additional Resources

- [parsedmarc Documentation](https://github.com/domainaware/parsedmarc)
- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Supabase Documentation](https://supabase.com/docs)
- [DMARC Specification](https://tools.ietf.org/html/rfc7489)

---

**Last Updated**: September 2025  
**Version**: 1.0.0  
**Status**: Production Ready ✅
