# Operations

## Deployment model

This stack is designed for one trusted host and the Docling Serve local engine.
The API process and conversion workers share the same container and local task
state. It is suitable for developer workstations, internal utilities, and
moderate single-host workloads.

It is not a horizontally scalable or high-availability deployment. For Redis/RQ,
Kubernetes, or public production infrastructure, use the upstream Docling Serve
deployment examples.

## First installation

```bash
cp .env.example .env
make validate
make start
make smoke
```

Model download failures normally indicate network, proxy, disk-space, or Hugging
Face access problems. Re-run `make models` after correcting the cause; downloads
are cached and resumable where supported upstream.

## Routine start and stop

```bash
make up
make wait
make stop
```

Use `make down` when the container and Compose network should be recreated. The
named model cache remains intact.

## Health and diagnostics

```bash
make status
make logs
make smoke
```

The Docker health check requests `/docs` from inside the container. A healthy
container indicates that the HTTP server responds; it does not prove that every
model is downloaded or that every document type will convert successfully.

When troubleshooting, capture:

- configured image and version from `.env`;
- `docker compose ps` output;
- recent `make logs` output;
- host CPU architecture, RAM, and available disk space;
- input type, page count, and whether OCR or table extraction was enabled.

Do not attach confidential documents to public bug reports.

## Updating

```bash
# Edit DOCLING_VERSION in .env first.
make pull
make models
make up
make wait
make smoke
```

Running `make models` after pulling a new image populates checkpoints newly
required by that Docling release while preserving the existing named cache.
Test several representative internal documents and the Gradio UI before
considering the upgrade complete. Pin the previous version again to roll back
the container. Reset the cache only when it is corrupted or upstream explicitly
requires a clean model set.

## Backup and retention

The model cache is reproducible and normally does not require backup. It can be
recreated with `make models`.

Converted documents are returned to the caller. The included CLI writes them to
`./output/`, which is ignored by Git. Back up or move business outputs according
to company retention policy. The Gradio UI cache is temporary and should never
be the only copy of a converted document.

## Resource planning

The official image and prefetched runtime model set require substantial disk
space. Conversion memory depends on page count, resolution, OCR, table
extraction, selected pipeline, and concurrency.

Start with two local conversion workers and one Uvicorn worker. Reduce
`DOCLING_LOCAL_WORKERS` to `1` when memory pressure or out-of-memory restarts
occur. Increase it only after measuring throughput and peak memory.

## LAN or server deployment checklist

Before changing the bind address to `0.0.0.0`:

- set a strong `DOCLING_API_KEY`;
- restrict the host firewall to trusted networks;
- prefer VPN-only access;
- add TLS at a reverse proxy when traffic leaves the host;
- disable the UI when it is not required;
- define file-size and page-count limits through supported upstream settings;
- monitor disk, memory, container restarts, and conversion latency.

## Removing all local data

```bash
make reset-cache
rm -rf output
```

`make reset-cache` deletes the named Docker volume and all downloaded model data.
The next full setup will download the models again.
