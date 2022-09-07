check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: config
config: ## config, Init configuration
	@git clone git@github.com:openshift/hypershift.git && mkdir -p  config

.PHONY: update-cli
update-cli: ## update hypershift cli
	@cd hypershift && git checkout . && git pull && make hypershift

#hypershift install
.PHONY: install-operator
install-operator: ## install HyperShift operator
	bash hack/install-operator.sh

.PHONY: uninstall-operator
uninstall-operator: ## uninstall HyperShift operator. check: oc get all -n hypershift
	hypershift install render --format=yaml | oc delete -f -

.PHONY: get-region
get-region: ## get cluster region
	@oc get node -ojsonpath='{.items[].metadata.labels.topology\.kubernetes\.io/region}'


.PHONY: get-platform
get-platform: ## get cluster platform
	@oc get infrastructure cluster -o=jsonpath='{.status.platformStatus.type}'

# need aws cli https://docs.aws.amazon.com/zh_cn/cli/v1/userguide/install-macos.html
.PHONY: create-bucket
create-bucket: ## create aws An S3 bucket with public access to host OIDC discovery documents for your clusters.
	bash hack/create-bucket.sh

.PHONY: create-cluster
create-cluster: ## create hosted cluster (aws or azure)
	bash hack/create-cluster.sh

.PHONY: create-cluster-manual
create-cluster-manual: ## create hosted cluster (AWS) manual
	bash hack/create-cluster-manual.sh

.PHONY: destroy-cluster
destroy-cluster: ## destroy hosted cluster (AWS) 有待修改
	bash hack/destroy-cluster.sh

.PHONY: create-kubeconfig
create-kubeconfig: ## create hosted cluster kubeconfig > hostedcluster.kubeconfig 有待修改
	@hypershift create kubeconfig > hostedcluster.kubeconfig