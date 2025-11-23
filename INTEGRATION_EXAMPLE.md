# Integration Example: Passing Configuration from Project A

This guide shows how Project A can pass its configuration to stack-orchestra without modifying stack-orchestra's files.

## Scenario

**Project A** needs:
- PostgreSQL: user=`abcd`, password=`abcd`, database=`lalala`
- Redis: default configuration

**Stack Orchestra** is cloned separately from Project A (recommended approach). You can clone it anywhere and reference it from Project A via path.

See [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) for detailed explanation of different integration approaches.

## Solution: Wrapper Makefile (Recommended)

The best approach is to create a wrapper Makefile in Project A that sets your configuration and calls stack-orchestra commands.

### Step 1: Create Makefile in Project A

Create a `Makefile` in your Project A root directory:

```makefile
# Makefile in Project A
SHELL := /bin/bash

# Point to where you cloned stack-orchestra
# Option 1: If stack-orchestra is sibling directory
STACK_ORCHESTRA_DIR := ../stack-orchestra

# Option 2: Absolute path
# STACK_ORCHESTRA_DIR := ~/projects/stack-orchestra

# Option 3: Use environment variable (most flexible)
# STACK_ORCHESTRA_DIR ?= ../stack-orchestra

# Your project configuration
POSTGRES_USER := abcd
POSTGRES_PASSWORD := abcd
POSTGRES_DB := lalala
COMPOSE_PROJECT_NAME := project-a

.PHONY: dev-up dev-down dev-logs dev-ps help

help:
	@echo "Project A Development Commands"
	@echo ""
	@echo "  make dev-up     - Start postgres and redis with Project A config"
	@echo "  make dev-down   - Stop postgres and redis"
	@echo "  make dev-logs   - View logs"
	@echo "  make dev-ps     - Show running containers"

dev-up:
	@echo "🚀 Starting development environment for Project A..."
	@echo "   PostgreSQL: user=$(POSTGRES_USER), db=$(POSTGRES_DB)"
	@cd $(STACK_ORCHESTRA_DIR) && \
		POSTGRES_USER=$(POSTGRES_USER) \
		POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		POSTGRES_DB=$(POSTGRES_DB) \
		COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		make postgres-up redis-up

dev-down:
	@echo "🛑 Stopping development environment..."
	@cd $(STACK_ORCHESTRA_DIR) && make postgres-down redis-down

dev-logs:
	@cd $(STACK_ORCHESTRA_DIR) && SERVICES="postgres redis" make logs

dev-ps:
	@cd $(STACK_ORCHESTRA_DIR) && make ps

# Individual service commands (optional)
postgres-up:
	@cd $(STACK_ORCHESTRA_DIR) && \
		POSTGRES_USER=$(POSTGRES_USER) \
		POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		POSTGRES_DB=$(POSTGRES_DB) \
		COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		make postgres-up

redis-up:
	@cd $(STACK_ORCHESTRA_DIR) && \
		COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		make redis-up
```

### Step 2: Project Structure

Clone stack-orchestra separately from Project A:

```bash
# Clone stack-orchestra separately (anywhere you want)
cd ~/projects
git clone https://github.com/tjandrayana/stack-orchestra.git

# Your Project A is separate
cd ~/projects
git clone <your-project-a-repo> project-a
```

Your directory structure:

```
~/projects/
├── stack-orchestra/              # Separate repository
│   ├── .git/
│   ├── docker-compose.yml
│   ├── compose/
│   └── Makefile
│
└── project-a/                    # Your project (separate)
    ├── .git/
    ├── Makefile                  # Your wrapper Makefile
    ├── .gitignore
    └── src/                      # Your application code
```

**Important**: Update the `STACK_ORCHESTRA_DIR` path in your Makefile to point to where you cloned stack-orchestra:

```makefile
# If stack-orchestra is sibling directory
STACK_ORCHESTRA_DIR := ../stack-orchestra

# Or if it's in a different location
STACK_ORCHESTRA_DIR := ~/projects/stack-orchestra

# Or use environment variable for flexibility
STACK_ORCHESTRA_DIR ?= ../stack-orchestra
```

### Step 3: Usage

From Project A root directory:

```bash
# Start services with your configuration
make dev-up

# Stop services
make dev-down

# View logs
make dev-logs

# Check status
make dev-ps

# Get help
make help
```

## How It Works

1. **Environment variables are passed**: When you set `POSTGRES_USER=abcd` before calling `make`, that variable is available to Docker Compose.

2. **Docker Compose reads env vars**: The compose files use `${POSTGRES_USER:-default}`, so if `POSTGRES_USER` is set, it uses that value instead of the default.

3. **No modification needed**: Stack-orchestra remains completely unchanged. You just pass variables when calling it.

## Testing

Verify your configuration is being used:

```bash
# Start with your config
make dev-up

# Verify PostgreSQL connection
docker exec -it project-a-postgres psql -U abcd -d lalala
# Should connect successfully with your credentials!

# Check environment
docker exec -it project-a-postgres env | grep POSTGRES
# Should show: POSTGRES_USER=abcd, POSTGRES_DB=lalala
```

## Overriding Configuration

You can override values when calling make:

```bash
# Use different password for this run
POSTGRES_PASSWORD=my_other_password make dev-up

# Use different database name
POSTGRES_DB=test_db make postgres-up
```

## Multiple Environments

You can create different targets for different environments:

```makefile
# Development environment
dev-up:
	@cd $(STACK_ORCHESTRA_DIR) && \
		POSTGRES_USER=abcd \
		POSTGRES_PASSWORD=abcd \
		POSTGRES_DB=lalala \
		COMPOSE_PROJECT_NAME=project-a-dev \
		make postgres-up redis-up

# Staging environment
staging-up:
	@cd $(STACK_ORCHESTRA_DIR) && \
		POSTGRES_USER=staging_user \
		POSTGRES_PASSWORD=staging_pass \
		POSTGRES_DB=staging_db \
		COMPOSE_PROJECT_NAME=project-a-staging \
		make postgres-up redis-up

# Production-like local testing
prod-local-up:
	@cd $(STACK_ORCHESTRA_DIR) && \
		POSTGRES_USER=prod_user \
		POSTGRES_PASSWORD=prod_pass \
		POSTGRES_DB=prod_db \
		COMPOSE_PROJECT_NAME=project-a-prod-local \
		make postgres-up redis-up
```

## Complete Example

Here's a complete, production-ready Makefile for Project A:

```makefile
# Makefile in Project A
SHELL := /bin/bash
STACK_ORCHESTRA_DIR := stack-orchestra

# Project A Configuration
POSTGRES_USER := abcd
POSTGRES_PASSWORD := abcd
POSTGRES_DB := lalala
COMPOSE_PROJECT_NAME := project-a

# Allow overrides via environment variables
POSTGRES_USER ?= abcd
POSTGRES_PASSWORD ?= abcd
POSTGRES_DB ?= lalala
COMPOSE_PROJECT_NAME ?= project-a

.PHONY: dev-up dev-down dev-logs dev-ps dev-clean help

help:
	@echo "Project A Development Commands"
	@echo ""
	@echo "Configuration:"
	@echo "  POSTGRES_USER=$(POSTGRES_USER)"
	@echo "  POSTGRES_DB=$(POSTGRES_DB)"
	@echo "  COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME)"
	@echo ""
	@echo "Commands:"
	@echo "  make dev-up     - Start postgres and redis"
	@echo "  make dev-down   - Stop postgres and redis"
	@echo "  make dev-logs   - View logs"
	@echo "  make dev-ps     - Show running containers"
	@echo "  make dev-clean  - Remove containers and volumes"

dev-up:
	@echo "🚀 Starting development environment..."
	@echo "   PostgreSQL: user=$(POSTGRES_USER), db=$(POSTGRES_DB)"
	@cd $(STACK_ORCHESTRA_DIR) && \
		POSTGRES_USER=$(POSTGRES_USER) \
		POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		POSTGRES_DB=$(POSTGRES_DB) \
		COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		make postgres-up redis-up

dev-down:
	@echo "🛑 Stopping development environment..."
	@cd $(STACK_ORCHESTRA_DIR) && make postgres-down redis-down

dev-logs:
	@cd $(STACK_ORCHESTRA_DIR) && SERVICES="postgres redis" make logs

dev-ps:
	@cd $(STACK_ORCHESTRA_DIR) && make ps

dev-clean:
	@echo "🧹 Cleaning up (removing containers and volumes)..."
	@cd $(STACK_ORCHESTRA_DIR) && SERVICES="postgres redis" make clean

# Individual service commands
postgres-up:
	@cd $(STACK_ORCHESTRA_DIR) && \
		POSTGRES_USER=$(POSTGRES_USER) \
		POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		POSTGRES_DB=$(POSTGRES_DB) \
		COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		make postgres-up

postgres-down:
	@cd $(STACK_ORCHESTRA_DIR) && make postgres-down

redis-up:
	@cd $(STACK_ORCHESTRA_DIR) && \
		COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		make redis-up

redis-down:
	@cd $(STACK_ORCHESTRA_DIR) && make redis-down
```

## Alternative: Quick Command (No Makefile)

If you prefer not to create a Makefile, you can call stack-orchestra directly with environment variables:

```bash
# Navigate to where you cloned stack-orchestra
cd ~/projects/stack-orchestra

# Run with your configuration
POSTGRES_USER=abcd POSTGRES_PASSWORD=abcd POSTGRES_DB=lalala make postgres-up redis-up
```

However, the wrapper Makefile approach is recommended as it:
- Keeps your configuration in one place
- Provides consistent commands
- Makes it easy for team members
- Allows easy overrides
- Handles the path to stack-orchestra automatically

## Troubleshooting

### Issue: Variables not being used

Make sure you're setting variables before the `make` command:

```makefile
# ✅ Correct
POSTGRES_USER=$(POSTGRES_USER) make postgres-up

# ❌ Wrong - variable not passed
make postgres-up POSTGRES_USER=abcd
```

### Issue: Wrong project name

Check that `COMPOSE_PROJECT_NAME` matches your expectations:

```bash
# Check running containers
make dev-ps

# Should show: project-a-postgres, project-a-redis
```

### Issue: Port conflicts

If ports are already in use, override them:

```makefile
dev-up:
	@cd $(STACK_ORCHESTRA_DIR) && \
		POSTGRES_USER=$(POSTGRES_USER) \
		POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		POSTGRES_DB=$(POSTGRES_DB) \
		POSTGRES_PORT=5433 \
		COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) \
		make postgres-up
```
