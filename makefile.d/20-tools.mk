####
## ActionLint CLI
####

ACTIONLINT_BIN := $(BIN_DIR)/actionlint
ACTIONLINT_VERSION := 1.7.7

bin/actionlint: bin/actionlint-$(ACTIONLINT_VERSION)
	@ln -sf actionlint-$(ACTIONLINT_VERSION) bin/actionlint

bin/actionlint-$(ACTIONLINT_VERSION): | $(BIN_DIR)
	curl -sSfL https://raw.githubusercontent.com/rhysd/actionlint/main/scripts/download-actionlint.bash \
	| bash -s -- "$(ACTIONLINT_VERSION)" "$(BIN_DIR)"
	@mv bin/actionlint $@

####
## MiniKube
####

MINIKUBE_BIN := $(BIN_DIR)/minikube
MINIKUBE_VERSION := 1.35.0

bin/minikube: bin/minikube-$(MINIKUBE_VERSION)
	@ln -sf $(notdir $<) $@

bin/minikube-$(MINIKUBE_VERSION): | $(BIN_DIR)
	@curl -sSfL 'https://github.com/kubernetes/minikube/releases/download/v$(MINIKUBE_VERSION)/minikube-$(OSTYPE)-$(ARCHTYPE)' --output $@
	@chmod +x $@

####
## Helm
####

HELM_BIN := $(BIN_DIR)/helm
HELM_VERSION := 3.17.1

bin/helm: bin/helm-$(HELM_VERSION)
	@ln -sf $(notdir $<) $@

bin/helm-$(HELM_VERSION): | $(BIN_DIR)
	@curl -sSfL 'https://get.helm.sh/helm-v$(HELM_VERSION)-$(OSTYPE)-$(ARCHTYPE).tar.gz' --output - \
	| tar xzvOf - '$(OSTYPE)-$(ARCHTYPE)/helm' > $@
	@chmod +x $@
