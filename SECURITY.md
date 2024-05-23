# Security Policy

## Supported versions

Only the current release, the `latest` tag, and the current stable Tor version (e.g., `0.4.8.11`) are supported. See [README.md](https://github.com/svengo/docker-tor?tab=readme-ov-file#supported-tags-and-corresponding-dockerfile-links) for a list of currently supported tags.  All other tags will not receive updates.

## Report a vulnerability

### Reporting Tor vulnerabilities

If you've found a vulnerability in Tor, please email to `security at torproject.org`. See [How to report a bug or give feedback](https://support.torproject.org/misc/bug-or-feedback/) for details.

### Docker image vulnerability

If you've found a vulnerability in this docker image, please mail `svengo at svengo.de`.

### Other

Report vulnerabilities in third-party modules to the person or team maintaining the module.

## Disclosure policy

The issue will be published as a [security advisory](https://github.com/svengo/docker-tor/security/advisories).

## Update policy

I will update the supported tags as soon as a new Tor or Alpine release is available. Please give me three days to perform and test the update. I will also periodically rebuild the image to include updated Alpine packages with important security fixes.
