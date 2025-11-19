SHELL := /bin/bash

COMPOSE ?= docker compose
SERVICE_LIST := elasticsearch kibana neo4j postgres mysql arangodb redis mongodb nginx openresty prometheus grafana scylla
SERVICES ?= $(SERVICE_LIST)
PARALLELISM ?= 5
COMPOSE_ALL_FILES := docker-compose.yml $(addprefix compose/,$(addsuffix .yml,$(SERVICE_LIST)))
COMPOSE_ALL := $(COMPOSE) $(foreach file,$(COMPOSE_ALL_FILES),-f $(file))
compose_for = $(COMPOSE) -f docker-compose.yml $(foreach svc,$(1),-f compose/$(svc).yml)

SERVICE_DEPS_elasticsearch :=
SERVICE_DEPS_kibana := elasticsearch
SERVICE_DEPS_neo4j :=
SERVICE_DEPS_postgres :=
SERVICE_DEPS_mysql :=
SERVICE_DEPS_arangodb :=
SERVICE_DEPS_redis :=
SERVICE_DEPS_mongodb :=
SERVICE_DEPS_nginx :=
SERVICE_DEPS_openresty :=
SERVICE_DEPS_prometheus :=
SERVICE_DEPS_grafana := prometheus
SERVICE_DEPS_scylla :=

resolve_services = $(strip $(1) $(foreach svc,$(1),$($(addprefix SERVICE_DEPS_,$(svc)))))
resolve_all = $(strip $(sort $(call resolve_services,$(1))))

.PHONY: help up up-parallel stop down logs ps clean status \
$(addsuffix -up,$(SERVICE_LIST)) \
	$(addsuffix -down,$(SERVICE_LIST))

help:
	@echo "stack-orchestra service controls"
	@echo
	@echo "SERVICES:"
	@printf "• %s\n" $(SERVICE_LIST)
	@echo
	@echo "Variables:"
	@echo "  SERVICES=\"postgres redis\" make up"
	@echo "  PARALLELISM=5 make up-parallel"
	@echo
	@echo "Targets:"
	@echo "  up             start SERVICES sequentially"
	@echo "  up-parallel    start SERVICES concurrently"
	@echo "  stop           stop SERVICES"
	@echo "  down           stop + remove entire stack"
	@echo "  <service>-up   start one service (e.g. make redis-up)"
	@echo "  <service>-down stop+remove one service"
	@echo "  logs           follow logs for SERVICES"
	@echo "  ps             list containers"
	@echo "  clean          remove stack incl. volumes"

up:
	@set -euo pipefail; \
	for service in $(call resolve_all,$(SERVICES)); do \
		echo "▶ Starting $$service"; \
		$(COMPOSE) -f docker-compose.yml -f compose/$$service.yml up -d $$service; \
	done

up-parallel:
	@echo "▶ Starting $(SERVICES) in parallel (P=$(PARALLELISM))"
	@printf '%s\n' $(call resolve_all,$(SERVICES)) | xargs -I{} -P $(PARALLELISM) $(SHELL) -c ' \
		echo "▶ Launching {}"; \
		$(COMPOSE) -f docker-compose.yml -f compose/{}.yml up -d {}; \
	'

stop:
	@set -euo pipefail; \
	for service in $(call resolve_all,$(SERVICES)); do \
		echo "■ Stopping $$service"; \
		$(COMPOSE) -f docker-compose.yml -f compose/$$service.yml stop $$service; \
	done

down:
	@$(COMPOSE_ALL) down --remove-orphans

logs:
	@$(call compose_for,$(call resolve_all,$(SERVICES))) logs -f $(SERVICES)

ps:
	@$(call compose_for,$(call resolve_all,$(SERVICES))) ps

clean:
	@$(COMPOSE_ALL) down --remove-orphans --volumes

status: ps

$(SERVICE_LIST:%=%-up):
	@echo "▶ Starting $(@:-up=)"
	@services="$(call resolve_all,$(@:-up=))"; \
	echo "  with: $$services"; \
	$(call compose_for,$(call resolve_all,$(@:-up=))) up -d $$services

$(SERVICE_LIST:%=%-down):
	@echo "■ Stopping $(@:-down=)"
	@$(call compose_for,$(@:-down=)) stop $(@:-down=) >/dev/null || true
	@$(call compose_for,$(@:-down=)) rm -f $(@:-down=) >/dev/null || true

