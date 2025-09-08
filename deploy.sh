#!/bin/bash

# parsedmarc Deployment Script
# This script helps deploy parsedmarc in various configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists docker; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! command_exists docker-compose; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "All prerequisites are met!"
}

# Function to create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    mkdir -p config
    mkdir -p data/output
    mkdir -p logs
    mkdir -p grafana/provisioning/datasources
    mkdir -p grafana/provisioning/dashboards
    mkdir -p grafana/dashboards
    
    print_success "Directories created successfully!"
}

# Function to create Grafana datasource configuration
create_grafana_config() {
    print_status "Creating Grafana configuration..."
    
    cat > grafana/provisioning/datasources/elasticsearch.yml << EOF
apiVersion: 1

datasources:
  - name: Elasticsearch
    type: elasticsearch
    access: proxy
    url: http://elasticsearch:9200
    database: "dmarc_*"
    isDefault: true
    editable: true
EOF

    cat > grafana/provisioning/datasources/opensearch.yml << EOF
apiVersion: 1

datasources:
  - name: OpenSearch
    type: opensearch
    access: proxy
    url: http://opensearch:9200
    database: "dmarc_*"
    isDefault: false
    editable: true
EOF

    print_success "Grafana configuration created!"
}

# Function to create environment file
create_env_file() {
    print_status "Creating environment file..."
    
    cat > .env << EOF
# parsedmarc Environment Configuration

# Elasticsearch
ELASTICSEARCH_HOSTS=elasticsearch:9200
ELASTICSEARCH_SSL=false

# OpenSearch
OPENSEARCH_HOSTS=opensearch:9200
OPENSEARCH_SSL=false
OPENSEARCH_INITIAL_ADMIN_PASSWORD=admin123

# Grafana
GRAFANA_ADMIN_PASSWORD=admin

# Redis
REDIS_PASSWORD=

# parsedmarc
PARSEDMARC_CONFIG_FILE=/app/config/parsedmarc.ini
PARSEDMARC_LOG_LEVEL=INFO
EOF

    print_success "Environment file created!"
}

# Function to deploy with Docker Compose
deploy_docker() {
    local compose_file=${1:-"docker-compose.full.yml"}
    
    print_status "Deploying with Docker Compose using $compose_file..."
    
    # Stop existing containers
    docker-compose -f $compose_file down 2>/dev/null || true
    
    # Build and start services
    docker-compose -f $compose_file up -d --build
    
    print_success "Deployment completed!"
    print_status "Services are starting up. This may take a few minutes..."
    
    # Wait for services to be ready
    print_status "Waiting for services to be ready..."
    sleep 30
    
    # Check service health
    check_service_health
}

# Function to check service health
check_service_health() {
    print_status "Checking service health..."
    
    # Check Elasticsearch
    if curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; then
        print_success "Elasticsearch is running on http://localhost:9200"
    else
        print_warning "Elasticsearch is not yet ready"
    fi
    
    # Check Kibana
    if curl -s http://localhost:5601/api/status > /dev/null 2>&1; then
        print_success "Kibana is running on http://localhost:5601"
    else
        print_warning "Kibana is not yet ready"
    fi
    
    # Check OpenSearch
    if curl -s http://localhost:9201/_cluster/health > /dev/null 2>&1; then
        print_success "OpenSearch is running on http://localhost:9201"
    else
        print_warning "OpenSearch is not yet ready"
    fi
    
    # Check Grafana
    if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
        print_success "Grafana is running on http://localhost:3000"
    else
        print_warning "Grafana is not yet ready"
    fi
}

# Function to show usage information
show_usage() {
    echo "parsedmarc Deployment Script"
    echo ""
    echo "Usage: $0 [OPTION]"
    echo ""
    echo "Options:"
    echo "  docker-full     Deploy with full stack (Elasticsearch, Kibana, OpenSearch, Grafana)"
    echo "  docker-basic    Deploy with basic stack (Elasticsearch, Kibana only)"
    echo "  docker-opensearch Deploy with OpenSearch stack only"
    echo "  local          Deploy locally with Python"
    echo "  stop           Stop all services"
    echo "  logs           Show logs"
    echo "  status         Show service status"
    echo "  clean          Clean up containers and volumes"
    echo "  help           Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 docker-full"
    echo "  $0 docker-basic"
    echo "  $0 local"
    echo "  $0 stop"
}

# Function to deploy locally
deploy_local() {
    print_status "Deploying locally with Python..."
    
    # Check if Python is available
    if ! command_exists python3; then
        print_error "Python 3 is not installed. Please install Python 3 first."
        exit 1
    fi
    
    # Create virtual environment
    if [ ! -d "venv" ]; then
        print_status "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    print_status "Activating virtual environment..."
    source venv/bin/activate
    
    # Install dependencies
    print_status "Installing dependencies..."
    pip install -e .
    
    # Create configuration
    if [ ! -f "config/parsedmarc.ini" ]; then
        print_status "Creating configuration file..."
        create_directories
    fi
    
    print_success "Local deployment completed!"
    print_status "To run parsedmarc locally:"
    echo "  source venv/bin/activate"
    echo "  parsedmarc -c config/parsedmarc.ini"
}

# Function to stop services
stop_services() {
    print_status "Stopping all services..."
    docker-compose -f docker-compose.full.yml down 2>/dev/null || true
    docker-compose -f docker-compose.yml down 2>/dev/null || true
    print_success "All services stopped!"
}

# Function to show logs
show_logs() {
    local service=${1:-""}
    if [ -n "$service" ]; then
        docker-compose -f docker-compose.full.yml logs -f "$service"
    else
        docker-compose -f docker-compose.full.yml logs -f
    fi
}

# Function to show status
show_status() {
    print_status "Service Status:"
    docker-compose -f docker-compose.full.yml ps
}

# Function to clean up
clean_up() {
    print_status "Cleaning up containers and volumes..."
    docker-compose -f docker-compose.full.yml down -v
    docker-compose -f docker-compose.yml down -v
    docker system prune -f
    print_success "Cleanup completed!"
}

# Main script logic
main() {
    case "${1:-help}" in
        "docker-full")
            check_prerequisites
            create_directories
            create_grafana_config
            create_env_file
            deploy_docker "docker-compose.full.yml"
            ;;
        "docker-basic")
            check_prerequisites
            create_directories
            create_env_file
            deploy_docker "docker-compose.yml"
            ;;
        "docker-opensearch")
            check_prerequisites
            create_directories
            create_grafana_config
            create_env_file
            # Create OpenSearch-only compose file
            cat > docker-compose.opensearch.yml << EOF
version: '3.8'
services:
  opensearch:
    image: opensearchproject/opensearch:2.18.0
    environment:
      - discovery.type=single-node
      - cluster.name=parsedmarc-cluster
      - bootstrap.memory_lock=true
      - "OPENSEARCH_JAVA_OPTS=-Xms512m -Xmx512m"
      - OPENSEARCH_INITIAL_ADMIN_PASSWORD=admin123
    ports:
      - "9200:9200"
    ulimits:
      memlock:
        soft: -1
        hard: -1
    volumes:
      - opensearch_data:/usr/share/opensearch/data

  opensearch-dashboards:
    image: opensearchproject/opensearch-dashboards:2.18.0
    environment:
      - OPENSEARCH_HOSTS=http://opensearch:9200
      - OPENSEARCH_USERNAME=admin
      - OPENSEARCH_PASSWORD=admin123
    ports:
      - "5601:5601"
    depends_on:
      - opensearch

  parsedmarc:
    build: .
    volumes:
      - ./config:/app/config
      - ./data:/app/data
      - ./logs:/app/logs
    depends_on:
      - opensearch
    restart: unless-stopped
    command: ["parsedmarc", "-c", "/app/config/parsedmarc.ini"]

volumes:
  opensearch_data:
EOF
            deploy_docker "docker-compose.opensearch.yml"
            ;;
        "local")
            deploy_local
            ;;
        "stop")
            stop_services
            ;;
        "logs")
            show_logs "$2"
            ;;
        "status")
            show_status
            ;;
        "clean")
            clean_up
            ;;
        "help"|*)
            show_usage
            ;;
    esac
}

# Run main function with all arguments
main "$@"

