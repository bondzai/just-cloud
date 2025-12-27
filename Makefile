# ===============================
# Generic config (cloud-neutral)
# ===============================
APP_NAME      ?= just-cloud
IMAGE_TAG     ?= latest

LOCAL_IMAGE   := $(APP_NAME):$(IMAGE_TAG)
REMOTE_IMAGE  ?=  # e.g. ghcr.io/you/just-cloud:latest

PORT          ?= 8080
SERVICE_NAME  ?= $(APP_NAME)

# ===============================
# Cloud Run (GCP) optional config
# ===============================
GCP_PROJECT_ID ?=
GCP_REGION     ?= asia-southeast1
GCP_SERVICE    ?= $(APP_NAME)
GCP_REPO       ?= $(APP_NAME)

# Example:
# asia-southeast1-docker.pkg.dev/<PROJECT_ID>/<GCP_REPO>/just-cloud:latest
GCP_IMAGE := $(GCP_REGION)-docker.pkg.dev/$(GCP_PROJECT_ID)/$(GCP_REPO)/$(APP_NAME):$(IMAGE_TAG)

# ===============================
# Phony targets
# ===============================
.PHONY: help \
        build-local run-local clean \
        docker-build docker-run docker-tag docker-push \
        cloudrun-build deploy-cloudrun cloudrun-url cloudrun-logs cloudrun-desc

help:
	@echo "Generic (cloud-neutral) targets:"
	@echo "  make build-local                       # go build binary"
	@echo "  make run-local                         # run app without Docker"
	@echo "  make docker-build                      # build local Docker image"
	@echo "  make docker-run                        # run Docker image locally"
	@echo "  make docker-push REMOTE_IMAGE=...      # push image to any registry"
	@echo ""
	@echo "Cloud Run (GCP) adapter targets:"
	@echo "  make deploy-cloudrun GCP_PROJECT_ID=my-project"
	@echo "  make cloudrun-url    GCP_PROJECT_ID=my-project"
	@echo "  make cloudrun-logs   GCP_PROJECT_ID=my-project"
	@echo "  make cloudrun-desc   GCP_PROJECT_ID=my-project"
	@echo ""
	@echo "Override vars, for example:"
	@echo "  make docker-build IMAGE_TAG=v1"
	@echo "  make docker-push REMOTE_IMAGE=ghcr.io/you/just-cloud:v1"

# ===============================
# Local (no containers)
# ===============================

build-local:
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 \
		go build -o just-cloud ./cmd/api

run-local:
	@echo "Running just-cloud on :$(PORT)"
	PORT=$(PORT) SERVICE_NAME=$(SERVICE_NAME) \
		go run ./cmd/api

clean:
	rm -f just-cloud || true

# ===============================
# Docker (generic, no cloud ties)
# ===============================

docker-build:
	docker build -t $(LOCAL_IMAGE) .

docker-run:
	@echo "Running $(LOCAL_IMAGE) on :$(PORT)"
	docker run --rm -p $(PORT):$(PORT) \
		-e PORT=$(PORT) \
		-e SERVICE_NAME=$(SERVICE_NAME) \
		$(LOCAL_IMAGE)

docker-tag:
	@if [ -z "$(REMOTE_IMAGE)" ]; then \
		echo "REMOTE_IMAGE is empty. Example:"; \
		echo "  make docker-tag REMOTE_IMAGE=ghcr.io/you/$(APP_NAME):$(IMAGE_TAG)"; \
		exit 1; \
	fi
	docker tag $(LOCAL_IMAGE) $(REMOTE_IMAGE)

docker-push: docker-tag
	docker push $(REMOTE_IMAGE)

# ===============================
# Cloud Run adapter (optional)
# ===============================

cloudrun-build:
	@if [ -z "$(GCP_PROJECT_ID)" ]; then \
		echo "Set GCP_PROJECT_ID, e.g. make cloudrun-build GCP_PROJECT_ID=my-project"; \
		exit 1; \
	fi
	gcloud builds submit \
	  --project=$(GCP_PROJECT_ID) \
	  --tag $(GCP_IMAGE)

deploy-cloudrun: cloudrun-build
	gcloud run deploy $(GCP_SERVICE) \
	  --project=$(GCP_PROJECT_ID) \
	  --image=$(GCP_IMAGE) \
	  --region=$(GCP_REGION) \
	  --platform=managed \
	  --allow-unauthenticated \
	  --memory=256Mi \
	  --min-instances=0 \
	  --max-instances=3 \
	  --set-env-vars=SERVICE_NAME=$(SERVICE_NAME)

cloudrun-url:
	@if [ -z "$(GCP_PROJECT_ID)" ]; then \
		echo "Set GCP_PROJECT_ID, e.g. make cloudrun-url GCP_PROJECT_ID=my-project"; \
		exit 1; \
	fi
	gcloud run services describe $(GCP_SERVICE) \
	  --project=$(GCP_PROJECT_ID) \
	  --region=$(GCP_REGION) \
	  --platform=managed \
	  --format='value(status.url)'

cloudrun-logs:
	@if [ -z "$(GCP_PROJECT_ID)" ]; then \
		echo "Set GCP_PROJECT_ID, e.g. make cloudrun-logs GCP_PROJECT_ID=my-project"; \
		exit 1; \
	fi
	gcloud logging read \
	  'resource.type="cloud_run_revision" AND resource.labels.service_name="$(GCP_SERVICE)"' \
	  --project=$(GCP_PROJECT_ID) \
	  --limit=50 \
	  --format='value(textPayload)' \
	  --order=desc

cloudrun-desc:
	@if [ -z "$(GCP_PROJECT_ID)" ]; then \
		echo "Set GCP_PROJECT_ID, e.g. make cloudrun-desc GCP_PROJECT_ID=my-project"; \
		exit 1; \
	fi
	gcloud run services describe $(GCP_SERVICE) \
	  --project=$(GCP_PROJECT_ID) \
	  --region=$(GCP_REGION) \
	  --platform=managed