# Docling Local

A small, reproducible Docker Compose wrapper for running
[Docling Serve](https://github.com/docling-project/docling-serve) on a local
workstation or an internal company server.

This repository is intentionally infrastructure-only. It does not fork Docling
or build a custom image. It pins the official upstream container, persists the
model cache, exposes the API on localhost by default, and includes a lightweight
client for converting local files.

> This is an unofficial deployment wrapper and is not affiliated with or
> maintained by the Docling project.

## Features

- Reproducible, version-pinned Docling Serve deployment
- Local-only network binding by default
- Persistent model cache across container recreation
- Optional one-command download of all Docling models
- Gradio UI, REST API, and interactive OpenAPI documentation
- Docker health check and bounded container logs
- Dependency-free Python client for local file conversion
- Configurable API key, worker count, device, port, and image repository
- GitHub Actions validation for Compose and included scripts

## Requirements

- Docker Engine or Docker Desktop with Docker Compose v2
- `make`, `curl`, and Python 3.9 or later for the convenience commands
- Sufficient disk space for the container image and model cache

Docling's official images support both `linux/amd64` and `linux/arm64`. Docker
Desktop on Apple Silicon therefore runs the native ARM image, but conversion
inside Docker remains CPU-based unless a supported Linux GPU runtime and image
are configured.

## Quick start

```bash
git clone https://github.com/BlacklineCloud/docling-local.git
cd docling-local
cp .env.example .env
make start
```

`make start` performs three steps:

1. downloads all Docling models into a named Docker volume;
2. starts Docling Serve in the background;
3. waits until the HTTP service is ready.

The initial image pull and model download can be large. Subsequent starts reuse
the persistent cache.

Open the local services:

- UI: <http://127.0.0.1:5001/ui>
- API documentation: <http://127.0.0.1:5001/docs>
- API base URL: <http://127.0.0.1:5001>

For a faster first start that downloads models only when they are first needed:

```bash
make up
make wait
```

## Convert a local document

Convert a PDF, DOCX, PPTX, XLSX, HTML file, image, or another format supported by
Docling to Markdown:

```bash
make convert FILE=/absolute/path/to/document.pdf
```

Select another output format or path:

```bash
make convert \
  FILE=/absolute/path/to/document.pdf \
  FORMAT=html \
  OUTPUT=output/document.html
```

Supported client output formats are `md`, `html`, `text`, `json`, and
`doctags`. The client enables OCR and accurate table extraction by default.
Run it directly for all options:

```bash
./bin/docling-convert --help
./bin/docling-convert document.pdf --format md --no-ocr
```

When no output path is supplied, converted files are written to `./output/`.

## Common operations

```bash
make help         # list commands
make status       # inspect container and health status
make logs         # follow API logs
make smoke        # verify that the HTTP service responds
make stop         # stop without deleting the container
make down         # remove containers and network; keep models
make pull         # pull the configured upstream image
make models       # download or refresh all cached models
make reset-cache  # permanently delete downloaded model data
```

## Configuration

Copy `.env.example` to `.env` and edit it before starting the service. The most
important settings are:

| Variable | Default | Purpose |
| --- | --- | --- |
| `DOCLING_VERSION` | `v1.23.0` | Pinned upstream image tag |
| `DOCLING_BIND_ADDRESS` | `127.0.0.1` | Host address exposed by Docker |
| `DOCLING_PORT` | `5001` | Host port |
| `DOCLING_API_KEY` | empty | Enables `X-Api-Key` authentication |
| `DOCLING_LOCAL_WORKERS` | `2` | Concurrent local-engine conversion workers |
| `DOCLING_SHARE_MODELS` | `true` | Share loaded models between local workers |
| `DOCLING_DEVICE` | `auto` | Docling inference device |
| `DOCLING_NUM_THREADS` | `4` | CPU thread count |

See [Configuration](docs/CONFIGURATION.md) for security, LAN access, API keys,
GPU images, and worker tuning.

## API example

Convert an uploaded file with the stable v1 endpoint:

```bash
curl -X POST "http://127.0.0.1:5001/v1/convert/file" \
  -H "Content-Type: multipart/form-data" \
  -F "files=@document.pdf;type=application/pdf" \
  -F "to_formats=md" \
  -F "do_ocr=true" \
  -F "image_export_mode=embedded" \
  -F "table_mode=accurate"
```

When an API key is configured, add:

```bash
-H "X-Api-Key: ${DOCLING_API_KEY}"
```

The live server schema at `/docs` is authoritative for all conversion options.

## Security scope

The default configuration binds only to `127.0.0.1`. Do not set
`DOCLING_BIND_ADDRESS=0.0.0.0` on an untrusted network without an API key and a
proper reverse proxy or VPN. The included Gradio UI is intended for internal
demonstration and interactive conversion; it is not durable document storage.

See [Operations](docs/OPERATIONS.md) for deployment and backup guidance, and
[Security Policy](SECURITY.md) for reporting issues in this wrapper.

## Updating Docling Serve

1. Read the upstream Docling Serve release notes and migration guidance.
2. Change `DOCLING_VERSION` in `.env` and `.env.example`.
3. Run `make pull` and `make up`.
4. Run `make smoke` and test representative documents.
5. Commit the version change and update `CHANGELOG.md`.

The model cache is preserved during normal upgrades. If upstream model formats
change incompatibly, run `make reset-cache` and then `make models`.

## Project status

This repository targets a single-host local or internal deployment using
Docling Serve's local engine. It deliberately does not include Redis/RQ,
Kubernetes, public TLS termination, or horizontal scaling. Use the official
Docling Serve deployment documentation for those architectures.

## License

This deployment wrapper is licensed under the [MIT License](LICENSE). Docling
and Docling Serve are separate upstream projects distributed under their own
licenses.
