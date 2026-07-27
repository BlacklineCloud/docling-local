SHELL := /usr/bin/env bash
.DEFAULT_GOAL := help

COMPOSE ?= docker compose
PYTHON ?= python3
FILE ?=
FORMAT ?= md
OUTPUT ?=

ifneq (,$(wildcard .env))
include .env
export
endif

.PHONY: help env validate pull models start up wait status logs stop down restart \
        convert smoke clean reset-cache

help: ## Show available commands
	@awk 'BEGIN {FS = ":.*## "; printf "Usage: make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*## / {printf "  %-14s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

env: ## Create .env from .env.example when missing
	@if [[ ! -f .env ]]; then cp .env.example .env; echo "Created .env"; else echo ".env already exists"; fi

validate: env ## Validate Compose and local scripts
	@$(COMPOSE) config --quiet
	@bash -n scripts/wait-for-service.sh scripts/smoke-test.sh
	@$(PYTHON) -m py_compile bin/docling-convert
	@echo "Validation passed."

pull: env ## Pull the configured Docling Serve image
	@$(COMPOSE) pull docling-serve

models: env ## Pre-download all Docling models into the persistent cache
	@$(COMPOSE) --profile tools run --rm docling-models

start: env ## Download models, start the service, and wait until ready
	@$(MAKE) models
	@$(MAKE) up
	@$(MAKE) wait

up: env ## Start Docling Serve in the background
	@$(COMPOSE) up -d docling-serve

wait: ## Wait until the HTTP service is ready
	@./scripts/wait-for-service.sh

status: env ## Show service and health status
	@$(COMPOSE) ps

logs: env ## Follow service logs
	@$(COMPOSE) logs -f --tail=200 docling-serve

stop: env ## Stop the service without removing it
	@$(COMPOSE) stop docling-serve

down: env ## Remove service containers and network, preserving model cache
	@$(COMPOSE) down --remove-orphans

restart: env ## Restart the API service
	@$(COMPOSE) restart docling-serve

convert: ## Convert FILE to FORMAT (md, html, text, json, or doctags)
	@if [[ -z "$(FILE)" ]]; then echo "Usage: make convert FILE=/path/to/document.pdf [FORMAT=md] [OUTPUT=output.md]" >&2; exit 2; fi
	@./bin/docling-convert "$(FILE)" --format "$(FORMAT)" $(if $(OUTPUT),--output "$(OUTPUT)",)

smoke: ## Check that the running service responds
	@./scripts/smoke-test.sh

clean: down ## Remove Python bytecode and generated client responses
	@find . -type d -name __pycache__ -prune -exec rm -rf {} +
	@rm -rf output

reset-cache: env ## Permanently delete downloaded model data
	@$(COMPOSE) down --remove-orphans
	@$(COMPOSE) --profile tools down --volumes --remove-orphans
	@echo "Docling model cache removed."
