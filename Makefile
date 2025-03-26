####
## Make settings
####

SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec
.DEFAULT_GOAL := help

####
## Runtime variables
####

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BIN_DIR := $(ROOT_DIR)/bin

####
## Load additional makefiles
####

include makefile.d/*.mk

$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

##@ General

# Self-documenting Makefile
.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Testing

.PHONY: lint-actions
lint-actions: bin/actionlint ## Lint Github Actions
	@$(ACTIONLINT_BIN) -color

.PHONY: lint-helm
lint-helm: bin/helm ## Lint Helm charts
	@$(HELM_BIN) lint ./charts/cloudconnectors/

##@ Deploy

DOCKER := docker
DOCKER_IMAGE_REF := cloudconnectors:dev
AXOFLOW_CONFIG_DIR := /etc/axoflow-otel-collector

.PHONY: docker-build
docker-build: ## Build cloudconnectors Docker image
	@echo "Building Docker image..."
	@$(DOCKER) build . -t $(DOCKER_IMAGE_REF)
	@echo "✅ Docker image built"

.PHONY: kind-cluster
kind-cluster: bin/kind ## Create a local Kubernetes cluster with KinD
	@echo "Creating KinD cluster..."
	@$(KIND_BIN) create cluster --name cloudconnectors
	@echo "✅ KinD cluster created"

.PHONY: kind-load-image
kind-load-image: bin/kind ## Load Docker image into KinD cluster
	@echo "Loading Docker image into KinD cluster..."
	@$(KIND_BIN) load docker-image $(DOCKER_IMAGE_REF) --name cloudconnectors
	@echo "✅ Docker image loaded"

.PHONY: install
install: lint-helm docker-build kind-load-image ## Install cloudconnectors Helm chart
	@echo "Installing Helm chart..."
	@$(HELM_BIN) upgrade --install --wait --create-namespace --namespace cloudconnectors cloudconnectors ./charts/cloudconnectors
	@echo "✅ Helm chart installed" 

.PHONY: uninstall
uninstall: ## Uninstall cloudconnectors Helm chart
	@echo "Uninstalling Helm chart..."
	@$(HELM_BIN) uninstall cloudconnectors --namespace cloudconnectors
	@echo "✅ Helm chart uninstalled"
