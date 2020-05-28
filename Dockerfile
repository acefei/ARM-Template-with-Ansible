FROM mcr.microsoft.com/azure-cli AS base

# install kubectl
COPY --from=lachlanevenson/k8s-kubectl /usr/local/bin/kubectl /usr/local/bin/kubectl

RUN apk add make jq grep bash bash-completion git \
    # install ansible
    && python3 -m pip install virtualenv \
    && virtualenv ansible \
    && source ansible/bin/activate \
    && pip install ansible[azure] \
    # install bash completion
    && echo "source /usr/share/bash-completion/bash_completion" >> ~/.bashrc \
    && echo "source <(kubectl completion bash)" >> ~/.bashrc

ARG SP_NAME
ARG AZURE_SECRET
ARG AZURE_TENANT
RUN az login --service-principal -u http://$SP_NAME -p $AZURE_SECRET --tenant $AZURE_TENANT
