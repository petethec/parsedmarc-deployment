#!/bin/bash

# DMARC Integration Deployment Script
# This script completes the integration between parsedmarc and Supabase

set -e

echo "🚀 Starting DMARC Integration Deployment..."

# 1. Register the updated task definition
echo "📝 Registering updated task definition..."
aws ecs register-task-definition --cli-input-json file://task-definition-s3-complete.json

# 2. Get the latest task definition revision
TASK_DEFINITION_ARN=$(aws ecs describe-task-definition --task-definition ray-parsedmarc --query 'taskDefinition.taskDefinitionArn' --output text)
echo "✅ Task definition registered: $TASK_DEFINITION_ARN"

# 3. Update the ECS service
echo "🔄 Updating ECS service..."
aws ecs update-service --cluster ray-core --service ray-parsedmarc-svc --task-definition ray-parsedmarc

# 4. Wait for deployment to complete
echo "⏳ Waiting for deployment to complete..."
aws ecs wait services-stable --cluster ray-core --services ray-parsedmarc-svc

# 5. Check service status
echo "📊 Checking service status..."
aws ecs describe-services --cluster ray-core --services ray-parsedmarc-svc --query 'services[0].{DesiredCount:desiredCount,RunningCount:runningCount,Status:status}' --output table

# 6. Get the latest task ID
TASK_ARN=$(aws ecs list-tasks --cluster ray-core --service-name ray-parsedmarc-svc --query 'taskArns[0]' --output text)
if [ "$TASK_ARN" != "None" ] && [ "$TASK_ARN" != "" ]; then
    TASK_ID=$(basename $TASK_ARN)
    echo "🔍 Latest task ID: $TASK_ID"
    
    # 7. Check logs
    echo "📋 Checking recent logs..."
    aws logs get-log-events --log-group-name "/ecs/ray-parsedmarc" --log-stream-name "ecs/parsedmarc/$TASK_ID" --start-time $(($(date +%s) - 300))000 --output text | tail -10
fi

echo "✅ DMARC Integration Deployment Complete!"
echo ""
echo "🔗 Integration Summary:"
echo "  • parsedmarc processes DMARC reports from S3"
echo "  • Reports are sent to Supabase via webhook"
echo "  • Your existing dashboard will show new data"
echo "  • Webhook URL: https://buctxwcqzitrqruoomkz.supabase.co/functions/v1/internal-ingest-dmarc"
echo ""
echo "📝 Next Steps:"
echo "  1. Set your DMARC_INGEST_TOKEN in the ECS task definition"
echo "  2. Monitor the logs to ensure reports are being processed"
echo "  3. Check your Supabase dashboard for incoming data"
echo ""
echo "🔍 To monitor:"
echo "  aws logs tail /ecs/ray-parsedmarc --follow"
