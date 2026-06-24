# docker-tor

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/512b3288012c4c10b50ea7112eaa3deb)](https://app.codacy.com/gh/svengo/docker-tor/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![Build and publish a Docker image](https://github.com/svengo/docker-tor/actions/workflows/publish-docker.yml/badge.svg)](https://github.com/svengo/docker-tor/actions/workflows/publish-docker.yml)
![GitHub publish (with filter)](https://img.shields.io/github/v/release/svengo/docker-tor)
![GitHub repo stars](https://img.shields.io/github/stars/svengo/docker-tor?label=repo%20stars)
[![GitHub licence](https://img.shields.io/github/license/svengo/docker-tor.svg)](https://github.com/svengo/docker-tor/blob/master/LICENSE)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/svengo/tor/latest)
[![Docker Stars](https://img.shields.io/docker/stars/svengo/tor)](https://hub.docker.com/r/svengo/tor)
[![Docker Pulls](https://img.shields.io/docker/pulls/svengo/tor)](https://hub.docker.com/r/svengo/tor)

Simple Docker container to run a Tor node.

## Quick reference

- **Maintained by:**
  [Sven Gottwald](https://github.com/svengo/)

- **Where to get help:**
  [svengo/docker-tor issues](https://github.com/svengo/docker-tor/issues)

- **Docker Hub:**
  [svengo/tor](https://hub.docker.com/r/svengo/tor)

- **GitHub Container registry:**
  [svengo/docker-tor](https://github.com/svengo/docker-tor/pkgs/container/tor)

- **Tor project:**
  [Tor Project](https://www.torproject.org/)

## Supported Tor Versions and Dockerfile

The Docker images are tagged with the precise Tor version number. Only the current Tor release (aliased as `latest`) is supported. No other versions are guaranteed to be stable or secure.

- [`latest`, `0.4.9.9`](https://github.com/svengo/docker-tor/blob/main/Dockerfile)
 
## How to use this image

### Start a simple Tor node

This command will start a Tor node and open ports 9001 and 9030:

``` console
docker run -d -p 9001:9001 -p 9030:9030 --name tor svengo/tor
```

### Docker Compose

It is recommended to use `docker compose` for running the container. Use the supplied [docker-compose.yml](https://github.com/svengo/docker-tor/raw/refs/heads/main/docker-compose.yml) and copy [docker-compose.env.dist](https://github.com/svengo/docker-tor/raw/refs/heads/main/docker-compose.env.dist) to `docker-compose.env`. You can edit `docker-compose.env` to your needs.

### Data storage

Data is stored in an anonymous volume that is mounted on ``/data`` (see docker inspect for more information). You can use a host volume to store the data in a specific directory on the host. Make sure you set the permissions correctly, or Tor will not be able to write to the directory (default uid 100 / gid 101).

Start the container:

``` console
docker run -d -p 9001:9001 -p 9030:9030 --name tor -v /data/tor:/data svengo/tor
```

### Basic configuration

Most environment variables are used to populate `/etc/tor/torrc-defaults`, for more advanced configuration you can edit `/data/torrc` directly. Note that `TZ` is not a torrc directive; instead, it configures the container timezone.

``` console
docker run -d -p 9001:9001 -p 9030:9030 --name tor -v /data/tor:/data -e "NICKNAME=MyDockerTorNode" -e "CONTACTINFO=foo@example.com" svengo/tor
```

#### Environment Variables

svengo/tor uses several environment variables to generate the ``torrc-defaults``-file, the variables are set to reasonable defaults (see below). You can edit ``/data/torrc`` to your needs after the first start.

| Variable | Default | Description |
|----------|---------|-------------|
| `ORPORT` | `9001` | Advertise this port to listen for connections from Tor clients and servers. Format: `[address:]PORT [flags]`. This option is required to be a Tor server. |
| `DIRPORT` | `9030` | If this option is nonzero, advertise the directory service on this port. Format: `[address:]PORT [flags]`. |
| `EXITPOLICY` | `reject *:* # no exits allowed` | Set an exit policy for this server. Each policy is of the form `accept[6]\|reject[6] ADDR[/MASK][:PORT]`. If `/MASK` is omitted, then this policy just applies to the host given. Instead of giving a host or network you can also use `*` to denote the universe (`0.0.0.0/0` and `::/128`), or `*4` to denote all IPv4 addresses, and `*6` to denote all IPv6 addresses. `PORT` can be a single port number, an interval of ports `FROM_PORT-TO_PORT`, or `*` . If `PORT` is omitted, that means `*`. |
| `CONTROLPORT` | *(optional)* | If set, Tor will accept connections on this port and allow those connections to control the Tor process using the Tor Control Protocol. Format: `PORT\|unix:path\|auto [flags]`. Note: unless you also specify `HASHEDCONTROLPASSWORD`, setting this option will cause Tor to allow any process on the local host to control it. If you use `docker compose`, you must also uncomment the corresponding port mapping in `docker-compose.yml` to make it reachable from the host. |
| `HASHEDCONTROLPASSWORD` | *(optional)* | Allow connections on the control port if they present the password whose one-way hash is hashed_password. You can compute the hash of a password by running `docker run -it --rm svengo/tor:latest tor --hash-password "your_password"`. |
| `NICKNAME` | `ididnteditheconfig` | Set the server's nickname to 'name'. Nicknames must be between 1 and 19 characters inclusive, and must contain only the characters ``[a-zA-Z0-9]``. |
| `CONTACTINFO` | `Random Person <nobody AT example dot com>` | Administrative contact information for this relay or bridge. This line can be used to contact you if your relay or bridge is misconfigured or something else goes wrong. You can use [Tor ContactInfo Generator](https://torcontactinfogenerator.netlify.app/) to create a contact info following [ContactInfo-Information-Sharing-Specification](https://nusenu.github.io/ContactInfo-Information-Sharing-Specification/). |
| `MYFAMILY` | *(optional)* | Declare that this Tor server is controlled or administered by a group or organization identical or similar to that of the other servers, defined by their identity fingerprints. When two servers both declare that they are in the same family, they are treated as a single server by the bandwidth authorities and entry guards. When listing a node, it's better to list it by fingerprint than by nickname: fingerprints are more reliable. |
| `ADDRESS` | *(optional)* | The IPv4 address of this server, or a fully qualified domain name of this server that resolves to an IPv4 address. You can leave this unset, and Tor will try to guess your IPv4 address. |
| `SOCKS_PORT` | *(optional)* | Port for the SOCKS proxy. If set, Tor will listen on this port for SOCKS connections. If you use `docker compose`, you must also uncomment the corresponding port mapping in `docker-compose.yml` to make it reachable from the host. |
| `SOCKS_POLICY` | *(optional)* | Access-control policy for the SOCKS proxy. If unset, all connections to SocksPort are accepted (potential security risk). Example: `accept *` |
| `TZ` | *(optional)* | Configure the system timezone for the container. If unset, the container uses UTC. Example: `Europe/Berlin` |
| `RELAY_BANDWIDTH_RATE` | *(optional)* | Average bandwidth limit for the relay. This allows the relay to use up to the specified rate, but averages the usage over time. Example: `100 KBytes` |
| `RELAY_BANDWIDTH_BURST` | *(optional)* | Maximum bandwidth burst for the relay. This allows short bursts above the average rate, but still limits the maximum rate. Example: `200 KBytes` |

## Feedback

Please report any problems as issues on [github](https://github.com/svengo/docker-tor/issues).
