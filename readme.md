# just-cloud

A minimal, cloud-neutral HTTP service designed for hands-on practice with
container deployments across multiple cloud platforms.

Built to stay portable, lightweight, and vendor-agnostic—ideal for exploring
Cloud Run, DigitalOcean, Render, Fly.io, AWS App Runner, and beyond.

## Features

- Simple JSON HTTP API using the standard library (`net/http`)
- Dockerized, no cloud SDK dependencies
- Generic Makefile for:
  - local build/run
  - Docker build & push
  - optional Google Cloud Run deployment as a thin adapter

## Endpoints

- `GET /health`  
  Returns `"OK"` for basic health checks.

- `POST /echo`  
  Request:

  ```json
  {
    "message": "hello cloud"
  }