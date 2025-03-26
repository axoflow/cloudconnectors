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
## Kind
####

KIND_BIN := $(BIN_DIR)/kind
KIND_VERSION := 0.27.0

bin/kind: bin/kind-$(KIND_VERSION)
	@ln -sf $(notdir $<) $@

bin/kind-$(KIND_VERSION): | $(BIN_DIR)
	@curl -sSfL -o $@ 'https://kind.sigs.k8s.io/dl/v$(KIND_VERSION)/kind-$(OSTYPE)-$(ARCHTYPE)'
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
