# Stack Orchestra Usage Guide

## 🚀 Quick Start

### View Available Commands

```bash
make help
```

### Start a Single Service

```bash
make elasticsearch-up
make postgres-up
make redis-up
make openresty-up
make qdrant-up
make milvus-up
```

### Start Multiple Services

```bash
# Sequential (one by one)
SERVICES="postgres redis mongodb" make up

# Parallel (all at once)
SERVICES="postgres redis mongodb" make up-parallel
```

### Start All Services

```bash
# Sequential
make up

# Parallel (faster)
make up-parallel
```

### Stop Services

```bash
# Stop a single service
make elasticsearch-down

# Stop multiple services
SERVICES="postgres redis" make stop

# Stop all services
make down
```

### View Logs

```bash
# Single service
SERVICES="elasticsearch" make logs

# Multiple services
SERVICES="postgres redis" make logs
```

### Check Status

```bash
make ps
# or
make status
```

### Clean Everything

```bash
# Remove containers and volumes (⚠️ deletes all data)
make clean
```

## 📖 Usage Examples

### Example 1: Start Elasticsearch Stack

```bash
# This automatically starts Elasticsearch first, then Kibana
make kibana-up

# Verify both are running
make ps

# Access Kibana at http://localhost:5601
# Access Elasticsearch at http://localhost:9200
```

### Example 2: Start Database Stack

```bash
# Start PostgreSQL and MySQL in parallel
SERVICES="postgres mysql" PARALLELISM=2 make up-parallel

# Connect to PostgreSQL
psql -h localhost -U orchestra -d stack_orchestra
# Password: orchestra

# Connect to MySQL
mysql -h localhost -u orchestra -p stack_orchestra
# Password: orchestra
```

### Example 3: Start Graph Databases

```bash
# Start Neo4j and ArangoDB
SERVICES="neo4j arangodb" make up

# Access Neo4j Browser at http://localhost:7474
# Username: neo4j
# Password: stackorchestra

# Access ArangoDB at http://localhost:8529
# Username: root
# Password: stackorchestra
```

### Example 4: Development Stack

```bash
# Start a typical development stack
SERVICES="postgres redis mongodb nginx" make up-parallel

# All services will be available on their respective ports
```

### Example 5: OpenResty with Lua

```bash
# Start OpenResty (Nginx + Lua)
make openresty-up

# Test the endpoints
curl http://localhost:8081                    # Inline Lua example
curl http://localhost:8081/lua                # External Lua script
curl http://localhost:8081/api/info           # JSON API endpoint
curl http://localhost:8081/health              # Health check

# OpenResty runs on port 8081 (nginx uses 8080)
# Add your own Lua scripts in ops/openresty/lua/
```

### Example 6: Monitoring Stack (Prometheus + Grafana)

```bash
# Start Prometheus only
make prometheus-up

# Access Prometheus at http://localhost:9090
# View metrics, targets, and alerts

# Or start Grafana (automatically starts Prometheus)
make grafana-up

# Access Grafana at http://localhost:3000
# Default credentials: admin / admin
# Prometheus is automatically configured as a data source
# Start creating dashboards immediately!
```

### Example 7: ScyllaDB (Cassandra-Compatible NoSQL)

```bash
# Start ScyllaDB
make scylla-up

# Access ScyllaDB CQL at localhost:9042
# Access REST API at http://localhost:10000

# Connect using cqlsh (if installed)
cqlsh localhost 9042

# Or use any Cassandra-compatible client
# ScyllaDB is fully compatible with Apache Cassandra drivers
```

### Example 8: Qdrant (Vector Database)

```bash
# Start Qdrant
make qdrant-up

# Access REST API at http://localhost:6333
# Access gRPC at localhost:6334

# Test the API
curl http://localhost:6333/health

# Use with Go client
# go get github.com/qdrant/go-client
# Perfect for RAG, semantic search, and similarity search applications
```

### Example 9: Milvus (Vector Database for AI/ML)

```bash
# Start Milvus (automatically starts etcd and MinIO)
make milvus-up

# Access gRPC at localhost:19530
# Access metrics at http://localhost:9091

# Test health
curl http://localhost:9091/healthz

# Use with Go SDK
# go get github.com/milvus-io/milvus-sdk-go
# Ideal for large-scale vector similarity search and AI applications
# Note: Milvus includes etcd (metadata) and MinIO (object storage) as dependencies
```

## 🔧 Configuration

### Environment Variables

All configuration values can be customized using environment variables. The repository includes default values that work out of the box, but you can override them by creating a `.env` file.

#### Quick Start with Custom Configuration

1. **Copy the example environment file**:
   ```bash
   cp .env.example .env
   ```

2. **Edit `.env`** with your custom values:
   ```bash
   # Example: Change PostgreSQL password
   POSTGRES_PASSWORD=my_secure_password
   
   # Example: Change port mappings
   POSTGRES_PORT=5433
   REDIS_PORT=6380
   ```

3. **Use as normal** - Docker Compose automatically loads `.env`:
   ```bash
   make postgres-up
   ```

#### Available Configuration Variables

All services support customization through environment variables. See `.env.example` for the complete list of available variables, including:

- **Project Settings**: `COMPOSE_PROJECT_NAME`, `CONTAINER_PREFIX`
- **Database Credentials**: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `MYSQL_PASSWORD`, etc.
- **Port Mappings**: `POSTGRES_PORT`, `REDIS_PORT`, `MONGODB_PORT`, etc.
- **Image Versions**: `POSTGRES_IMAGE`, `REDIS_IMAGE`, `MONGODB_IMAGE`, etc.
- **Service-Specific Settings**: Elasticsearch Java options, Grafana admin credentials, etc.

**Note**: The network name (`stack-orchestra`) is defined in `docker-compose.yml` and cannot be changed via environment variables due to Docker Compose limitations. If you need a custom network name, edit `docker-compose.yml` directly.

#### Using Environment Variables Directly

You can also set environment variables directly without a `.env` file:

```bash
# Override specific values
POSTGRES_PASSWORD=my_password make postgres-up

# Or export them
export POSTGRES_PASSWORD=my_password
export POSTGRES_PORT=5433
make postgres-up
```

#### Using from Another Project

If you're using stack-orchestra from another project (e.g., as a git submodule), you can pass configuration without modifying stack-orchestra's files:

```bash
# From your project directory
cd stack-orchestra
POSTGRES_USER=abcd POSTGRES_PASSWORD=abcd POSTGRES_DB=lalala make postgres-up
```

Or create a wrapper Makefile in your project:

```makefile
# Makefile in your project
STACK_ORCHESTRA_DIR := stack-orchestra

dev-up:
	@cd $(STACK_ORCHESTRA_DIR) && \
		POSTGRES_USER=abcd \
		POSTGRES_PASSWORD=abcd \
		POSTGRES_DB=lalala \
		make postgres-up redis-up
```

See [INTEGRATION_EXAMPLE.md](INTEGRATION_EXAMPLE.md) for complete integration examples.

#### Default Behavior

If no `.env` file exists and no environment variables are set, the system uses the default values (same as the original hardcoded configuration). This ensures **100% backward compatibility** - existing setups continue to work without any changes.

### Default Service List

By default, all services are included. You can override this:

```bash
# Only run specific services
SERVICES="postgres redis" make up
```

### Parallel Execution

Control how many services start simultaneously:

```bash
# Start 3 services at a time
PARALLELISM=3 SERVICES="postgres mysql redis mongodb" make up-parallel
```

### Service Credentials

Default credentials for services:

| Service | Username | Password | Database |
|---------|----------|----------|----------|
| PostgreSQL | `orchestra` | `orchestra` | `stack_orchestra` |
| MySQL | `orchestra` | `orchestra` | `stack_orchestra` |
| MySQL (root) | `root` | `mysqlroot` | - |
| Neo4j | `neo4j` | `stackorchestra` | - |
| ArangoDB | `root` | `stackorchestra` | - |
| MongoDB | `orchestra` | `orchestra` | `admin` |
| Grafana | `admin` | `admin` | - |

**Note**: These are default development credentials. Change them for production use.

## 🗂️ Data Persistence

All database services use Docker volumes for data persistence:

- `stack-orchestra_elasticsearch-data`
- `stack-orchestra_neo4j-data`
- `stack-orchestra_postgres-data`
- `stack-orchestra_mysql-data`
- `stack-orchestra_arangodb-data`
- `stack-orchestra_mongodb-data`
- `stack-orchestra_prometheus-data`
- `stack-orchestra_grafana-data`
- `stack-orchestra_scylla-data`
- `stack-orchestra_qdrant-data`
- `stack-orchestra_milvus-data`
- `stack-orchestra_etcd-data`
- `stack-orchestra_minio-data`

Data persists across container restarts. To remove all data:

```bash
make clean
```

## 🔍 Troubleshooting

### Service Won't Start

1. **Check if port is already in use**:
   ```bash
   # Check what's using a port
   lsof -i :9200
   ```

2. **View service logs**:
   ```bash
   SERVICES="elasticsearch" make logs
   ```

3. **Check container status**:
   ```bash
   make ps
   ```

### Elasticsearch Version Conflicts

If you see errors about incompatible Elasticsearch versions, the data volume may have been created with a different version:

```bash
# Remove the volume and start fresh
docker volume rm stack-orchestra_elasticsearch-data
make elasticsearch-up
```

### Service Dependencies Not Starting

If a service depends on another (like Kibana → Elasticsearch), ensure the dependency is defined in the Makefile's `SERVICE_DEPS_*` variables.

### Network Issues

All services run on the `stack-orchestra` network. If you have network conflicts:

```bash
# Remove and recreate
make down
make up
```

## 🛠️ Advanced Usage

### Custom Compose Commands

You can use docker compose directly with the service files:

```bash
# Start Elasticsearch manually
docker compose -f docker-compose.yml -f compose/elasticsearch.yml up -d

# Start multiple services
docker compose -f docker-compose.yml \
  -f compose/postgres.yml \
  -f compose/redis.yml \
  up -d
```

### Adding New Services

1. Create a new compose file in `compose/`:
   ```yaml
   # compose/newservice.yml
   services:
     newservice:
       image: newservice:latest
       container_name: stack-orchestra-newservice
       # ... configuration
   ```

2. Add to `SERVICE_LIST` in `Makefile`:
   ```makefile
   SERVICE_LIST := elasticsearch ... newservice
   ```

3. Add dependency mapping if needed:
   ```makefile
   SERVICE_DEPS_newservice := dependency-service
   ```

