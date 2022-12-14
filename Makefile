.PHONY: kind registry app toolbox demo
SHELL = /bin/bash

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

destroy:
	kind delete cluster
	docker-compose -f registry/docker-compose.yaml down -v

build:
	pushd app; docker-compose build; popd

push:
	pushd app; docker-compose push; popd

app:
	pushd app; docker-compose up; popd

deploy/%:
	kubectl apply -f app/manifests.$*

delete/%:
	kubectl delete -f app/manifests.$*

clean:
	kubectl delete pod,deploy,svc,ingress,configmap,secrets,job,cronjob,networkpolicy,pvc --all
