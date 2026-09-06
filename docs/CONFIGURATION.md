# Configuration

## Image selection

The default image is pinned through two variables:

```dotenv
DOCLING_IMAGE_REPOSITORY=quay.io/docling-project/docling-serve
DOCLING_VERSION=v1.32.0
```

Pin explicit versions in shared environments. Avoid `latest` because it makes
rollbacks and incident analysis less deterministic.

The upstream project also publishes CPU-specific and CUDA-specific images.
Change the repository and version together, following the upstream image table.
CUDA images require a compatible NVIDIA driver, NVIDIA Container Toolkit, and
Docker runtime configuration on the Linux host.

## Network exposure

The safe default is local-only:

```dotenv
DOCLING_BIND_ADDRESS=127.0.0.1
DOCLING_PORT=5001
```

For access over a private company network:

```dotenv
DOCLING_BIND_ADDRESS=0.0.0.0
DOCLING_API_KEY=<a-long-random-secret>
```

Generate a key with:

```bash
openssl rand -hex 32
```

Clients must then send the key in the `X-Api-Key` header. Prefer a VPN or a
reverse proxy with TLS and additional access control. The Compose stack does not
provide public TLS termination.

## UI

```dotenv
DOCLING_SERVE_ENABLE_UI=1
```

Set this to `0` when only API access is required. The UI is a Gradio
demonstrator. Its generated files are temporary and must not be treated as a
retention or backup mechanism.

## Local engine concurrency

```dotenv
DOCLING_LOCAL_WORKERS=2
DOCLING_SHARE_MODELS=true
UVICORN_WORKERS=1
```

`DOCLING_LOCAL_WORKERS` controls conversion concurrency inside the local engine.
Model sharing can reduce duplicate memory usage. Keep `UVICORN_WORKERS=1` for
this single-host configuration because task state is local to the process and
additional web workers can multiply memory consumption.

Increase conversion workers only after measuring memory usage with realistic
files. OCR, table extraction, and visual models can be memory intensive.

## CPU tuning

```dotenv
DOCLING_DEVICE=auto
DOCLING_NUM_THREADS=4
```

`auto` is appropriate for the default image. On CPU-only hosts, set a thread
count that leaves capacity for Docker, the operating system, and other company
services. More threads do not guarantee higher throughput when multiple
conversions already run concurrently.

## Model cache

The named volume stores the upstream container's default cache directory:

```dotenv
DOCLING_CACHE_VOLUME=docling-local-cache
```

Inspect it with:

```bash
docker volume inspect docling-local-cache
```

Normal `make down` and upgrades preserve this volume. After changing
`DOCLING_VERSION`, run `make models` to add checkpoints required by the newly
pinned image. `make reset-cache` permanently deletes the volume and should be
reserved for corrupted caches or upstream migrations that require a clean
model set.

## Log rotation

```dotenv
DOCLING_LOG_MAX_SIZE=10m
DOCLING_LOG_MAX_FILES=3
```

These limits prevent the Docker JSON log from growing without bounds. Central
logging can be added by replacing the Compose logging driver.

## Client settings

The included client reads:

```dotenv
DOCLING_API_URL=http://127.0.0.1:5001
DOCLING_API_KEY=
```

`.env` is used by Docker Compose but is not automatically loaded into your shell.
For direct client calls, export the values explicitly when needed:

```bash
export DOCLING_API_URL=http://docling.internal.example:5001
export DOCLING_API_KEY='...'
./bin/docling-convert document.pdf
```
