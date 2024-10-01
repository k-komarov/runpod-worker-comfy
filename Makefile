DOCKERHUB_REPO=kirillkomarov/runpod-worker-comfy
PLATFORM?=linux/amd64
TAG?=latest
login:
	docker login

build:
	docker build --platform ${PLATFORM} -t ${DOCKERHUB_REPO}:${TAG} .

build-local:
	docker build -t ${DOCKERHUB_REPO}:local .

run-local:
	docker run ${DOCKERHUB_REPO}:local

push: login build
	docker push ${DOCKERHUB_REPO}:${TAG}
