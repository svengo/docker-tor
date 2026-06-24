# Security Policy

## Supported versions

Only the current release, the `latest` tag, and the current stable Tor version (e.g., `0.4.8.11`) are supported. See [README.md](https://github.com/svengo/docker-tor/blob/main/README.md#supported-tor-versions-and-dockerfile) for a list of currently supported tags.  All other tags will not receive updates.

## Report a vulnerability

### Reporting Tor vulnerabilities

If you have found a vulnerability in Tor, please email <security@torproject.org>. See [Tor’s bug-reporting guidelines](https://support.torproject.org/misc/bug-or-feedback/) for details.

### Docker image vulnerability

If you discover a potential vulnerability in this Docker image, please submit it privately via the [security report form](https://github.com/svengo/docker-tor/security/advisories/new).  
See the [GitHub documentation](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability#privately-reporting-a-security-vulnerability) for details.

### Other

Report vulnerabilities in third-party modules to the person or team maintaining the module.

## Disclosure Policy

The issue will be published as a [security advisory](https://github.com/svengo/docker-tor/security/advisories).

## Update Policy

Security is a priority.  I will update the supported tags as soon as a new Tor or Alpine release is available. Please give me three days to perform and test the update. I will also periodically rebuild the image to include updated Alpine packages with important security fixes.

## Tools

To keep the docker image secure, several automated systems are in place:

- **Dependabot:** Configured to automatically update dependencies ([dependabot.yml](.github/dependabot.yml)).
- **GitHub Actions:** A suite of workflows monitors for updates and performs checks:
  - [Anchore Grype Scanning](.github/workflows/anchore-grype-scan.yml) for vulnerability detection.
  - [Rebuild on APK Updates](.github/workflows/rebuild-on-apk-update.yml) to automatically rebuild Docker images when APK security updates are available.
  - [Update Tor Version](.github/workflows/update-tor.yml) to automatically check for and update to the latest Tor release.
  - [Codacy Integration](.github/workflows/codacy.yml) for code quality analysis.
  - [CodeQL](.github/workflows/codeql.yml) to identify vulnerabilities and errors in GitHub Actions workflows.
