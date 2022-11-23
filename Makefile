.PHONY: kind registry app toolbox demo

kind:
	./kind/start.sh

toolbox:
	docker build --build-arg USER=${USER} -t toolbox --target base toolbox

toolbox-lvim:
	docker build --build-arg USER=${USER} -t toolbox --target lvim toolbox

toolbox-dotfiles:
	docker build --build-arg USER=${USER} -t toolbox --target dotfiles toolbox

shell:
	@toolbox/start.sh

registry:
	docker-compose -f registry/docker-compose.yaml up -d

cluster: kind registry

demo:
	./demo

clean-cluster:
	kind delete cluster
	docker-compose -f registry/docker-compose.yaml down -v
	docker rm -f kind-registry

build:
	pushd app; docker-compose build; popd

push:
	pushd app; docker-compose push; popd

app:
	pushd app; docker-compose up; popd

deploy1:
	kubectl apply -f app/manifests.1

deploy2:
	kubectl apply -f app/manifests.2

clean:
	kubectl delete pod,deploy,svc,ingress,configmap,secrets,job,cronjob,networkpolicy --all
