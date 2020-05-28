.PHONY: help azure-cli ansible dev-env deploy
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

# eval "$(ssh-agent)" && ssh-add
SSH_AGENT_ARGS := -v $(SSH_AUTH_SOCK):/tmp/ssh_auth.sock -e SSH_AUTH_SOCK=/tmp/ssh_auth.sock
DIND_ARGS := -v /var/run/docker.sock:/var/run/docker.sock -v $(shell which docker):/bin/docker
RUN_ARGS := $(SSH_AGENT_ARGS) $(DIND_ARGS)
DOCKER_BUILD = DOCKER_BUILDKIT=1 docker build $(BUILD-EXTRA-ARGS) -t $@ --target $@ .
DOCKER_RUN = docker run -it $(RUN_ARGS) -v $(PWD):/workdir -w /workdir $<

base: BUILD-EXTRA-ARGS := --build-arg AZURE_SECRET=$(AZURE_SECRET) --build-arg SP_NAME=$(SP_NAME) --build-arg AZURE_TENANT=$(AZURE_TENANT)
base:
	$(DOCKER_BUILD)

dev-env: base ## Enter dev container, Usage: make dev-env SP_NAME=<> AZURE_SECRET=<> AZURE_TENANT=<>
	$(DOCKER_RUN) bash

define SHELL_SCRIPT
source /ansible/bin/activate
ansible-playbook main.yaml
endef

export SHELL_SCRIPT

deploy: base ## Deploy ARM template with Ansible, Usage: make deploy SP_NAME=<> AZURE_SECRET=<> AZURE_TENANT=<>
	@$(DOCKER_RUN) bash -c "$$SHELL_SCRIPT"
