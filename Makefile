.PHONY: kind toolbox

kind:
	./kind/start.sh

toolbox:
	docker build --build-arg USER=${USER} -t toolbox toolbox

toolbox-lvim:
	docker build --build-arg USER=${USER} -t toolbox toolbox

toolbox-dotfiles:
	docker build --build-arg USER=${USER} -t toolbox toolbox

shell:
	toolbox/start.sh

registry:
	docker-compose up -d

cluster: kind registry

clean:
	kind delete cluster
	docker-compose down -v
