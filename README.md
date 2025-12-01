# Stack Orchestra

A flexible Docker Compose orchestration tool for managing multiple technology stacks independently. Stack Orchestra allows you to selectively run, stop, and manage various database and service technologies through simple Makefile commands.

## 🎯 Purpose

Stack Orchestra provides a clean, modular approach to running development stacks. Instead of managing monolithic docker-compose files, each technology stack is isolated in its own compose file, allowing you to:

- **Run only what you need**: Start individual services or combinations without launching the entire stack
- **Manage dependencies intelligently**: Services automatically include their dependencies (e.g., Kibana includes Elasticsearch)
- **Scale efficiently**: Run services sequentially or in parallel based on your needs
- **Keep configurations tidy**: Each service has its own compose file for easy maintenance

## ✨ Features

- 🎼 **Modular Architecture**: Each service in its own compose file
- 🔄 **Smart Dependencies**: Automatic dependency resolution (e.g., `kibana-up` starts Elasticsearch)
- ⚡ **Flexible Execution**: Run services sequentially or in parallel
- 🎛️ **Selective Control**: Start/stop individual services or groups
- 📦 **Persistent Storage**: Data volumes for all databases
- 🏥 **Health Checks**: Built-in health monitoring for all services
- 🌐 **Isolated Network**: All services run on a dedicated Docker network

## 📋 Prerequisites

- **Docker** (version 20.10+)
- **Docker Compose** (version 2.0+)
- **Make** (for using the Makefile commands)
- **curl** (for health checks, usually pre-installed)

## 🏗️ Project Structure

```
stack-orchestra/
├── docker-compose.yml          # Base configuration (networks, volumes)
├── Makefile                     # Service orchestration commands
├── compose/                     # Individual service definitions
│   ├── elasticsearch.yml
│   ├── kibana.yml
│   ├── neo4j.yml
│   ├── postgres.yml
│   ├── mysql.yml
│   ├── arangodb.yml
│   ├── redis.yml
│   ├── mongodb.yml
│   ├── nginx.yml
│   ├── openresty.yml
│   ├── prometheus.yml
│   ├── grafana.yml
│   ├── scylla.yml
│   ├── qdrant.yml
│   ├── milvus.yml
│   ├── dynamodb.yml
│   ├── rabbitmq.yml
│   └── consul.yml
└── ops/                         # Service configurations
    ├── nginx/
    │   └── default.conf
    ├── openresty/
    │   ├── default.conf
    │   └── lua/
    │       └── hello.lua
    ├── prometheus/
    │   └── prometheus.yml
    └── grafana/
        └── provisioning/
            └── datasources/
                └── prometheus.yml
```

## 🎼 Available Services

| Service | Version | Port | Description |
|---------|---------|------|-------------|
| **Elasticsearch** | 7.17.22 | 9200, 9300 | Distributed search and analytics engine |
| **Kibana** | 7.17.22 | 5601 | Elasticsearch visualization and management |
| **Neo4j** | 5.23 | 7474, 7687 | Graph database |
| **PostgreSQL** | 16 | 5432 | Relational database |
| **MySQL** | 8.4 | 3306 | Relational database |
| **ArangoDB** | 3.12 | 8529 | Multi-model database |
| **Redis** | 7.4 | 6379 | In-memory data structure store |
| **MongoDB** | 7.0 | 27017 | NoSQL document database |
| **Nginx** | 1.27 | 8080 | Web server and reverse proxy |
| **OpenResty** | 1.25.3.1 | 8081 | Nginx with LuaJIT and Lua libraries |
| **Prometheus** | latest | 9090 | Metrics collection and monitoring |
| **Grafana** | latest | 3000 | Visualization and dashboards |
| **ScyllaDB** | latest | 9042, 10000 | High-performance NoSQL database (Cassandra-compatible) |
| **Qdrant** | 1.7.4 | 6333, 6334 | Vector database for similarity search and embeddings |
| **Milvus** | 2.3.4 | 19530, 9091 | Vector database for AI/ML applications (includes etcd & MinIO) |
| **DynamoDB Local** | latest | 8000 | Local DynamoDB for development and testing |
| **RabbitMQ** | 3-management | 5672, 15672 | Message broker with management UI |
| **Consul** | latest | 8500, 8600 | Service discovery and configuration management |

### Service Dependencies

- **Kibana** → Requires Elasticsearch (automatically started when running `make kibana-up`)
- **Grafana** → Requires Prometheus (automatically started when running `make grafana-up`)
- **Milvus** → Requires etcd and MinIO (automatically started when running `make milvus-up`)

## 📚 Documentation

For detailed usage instructions, examples, configuration, troubleshooting, and advanced topics, see [USAGE.md](USAGE.md).

The usage guide includes:
- Quick start guide
- Usage examples for all services
- Configuration options
- Troubleshooting
- Advanced usage and adding new services

### 📖 Blog Post

Read the story behind Stack Orchestra: [A beginner's journey from setup hell to building a Docker Compose orchestration tool](https://dev.to/tj1609/a-beginners-journey-from-setup-hell-to-building-a-docker-compose-orchestration-tool-that-runs-any-4fd6)

Learn about the motivation, challenges, and journey of building this tool from scratch.

## 📝 Notes

- Services are configured for **development use** with relaxed security settings
- All services expose ports on `localhost` for easy access
- Health checks are configured for all services to ensure proper startup
- The `version` field has been removed from docker-compose.yml (obsolete in newer Docker Compose versions)

## 🤝 Contributing

To add a new service:

1. Create `compose/<service>.yml` with the service definition
2. Add the service to `SERVICE_LIST` in `Makefile`
3. Add any dependencies to `SERVICE_DEPS_<service>` if needed
4. Update this README with service details

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy Orchestrating! 🎼**

