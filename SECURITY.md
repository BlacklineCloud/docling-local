# Security Policy

## Supported versions

Security fixes are applied to the latest version of this deployment wrapper.
The pinned Docling Serve image has its own upstream support and release policy.

## Reporting a vulnerability

Do not open a public issue for a vulnerability involving this wrapper, leaked
credentials, or confidential documents. Contact the repository maintainers
through the private security reporting channel configured for the GitHub
repository.

Include the wrapper version or commit, configured upstream image tag, affected
configuration, reproduction steps using non-sensitive sample data, and the
expected impact.

Upstream Docling or Docling Serve vulnerabilities should also be reported to
the upstream project according to its security policy.

## Deployment responsibility

The default service binds to localhost. Operators who expose it to a network are
responsible for API authentication, firewall policy, VPN or reverse-proxy access,
TLS, request limits, logging, and document-retention controls.
