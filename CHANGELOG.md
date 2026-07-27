# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-07-27

### Added

- Version-pinned Docling Serve Compose deployment.
- Persistent model cache and optional all-model download service.
- Localhost-only default binding, API key configuration, health check, and log
  rotation.
- Makefile for setup, operations, validation, and conversion.
- Dependency-free Python client for local file conversion.
- English README, configuration, operations, contribution, and security docs.
- GitHub Actions validation and issue templates.

### Changed

- Replaced the original race-prone `depends_on` startup with an explicit,
  repeatable model-download operation.
