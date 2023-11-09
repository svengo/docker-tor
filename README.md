# docker-tor

[![CI](https://github.com/svengo/docker-tor/actions/workflows/docker-image.yml/badge.svg?branch=main)](https://github.com/svengo/docker-tor/actions/workflows/docker-image.yml)
![GitHub release (with filter)](https://img.shields.io/github/v/release/svengo/docker-tor)
![GitHub Workflow Status (Release)](https://img.shields.io/github/actions/workflow/status/svengo/docker-tor/docker-image.yml?event=release&label=release)
![GitHub Repo stars](https://img.shields.io/github/stars/svengo/docker-tor?label=repo%20stars)
[![GitHub License](https://img.shields.io/github/license/svengo/docker-tor.svg)](https://github.com/svengo/docker-tor/blob/master/LICENSE)
![Docker Image Size (tag)](https://img.shields.io/docker/image-size/svengo/tor/latest)
[![Docker Stars](https://img.shields.io/docker/stars/svengo/tor)](https://hub.docker.com/r/svengo/tor)
[![Docker Pulls](https://img.shields.io/docker/pulls/svengo/tor)](https://hub.docker.com/r/svengo/tor)

Simple docker container for running a tor node.

# Quick reference

- **Maintained by**:  
  [Sven Gottwald](https://github.com/svengo/)

- **Where to get help**:  
  [svengo/docker-tor Issues](https://github.com/svengo/docker-tor/issues)

- **Docker Hub**:  
  [svengo/tor](https://hub.docker.com/r/svengo/tor)


# Supported tags and respective `Dockerfile` links
* [`latest`](https://github.com/svengo/docker-tor/blob/9c183a207895d3639165fdfb95ba40adb9a57ae1/Dockerfile)

Currently only the `latest` tag is supported. I will be rebuilding the image on a regular basis to include updated alpine packages with important security fixes.

# How to use this image

## Start a simple tor node

The command starts a tor node and open ports 9001 and 9030:

``` console
docker run -d -p 9001:9001 -p 9030:9030 --name tor svengo/tor
```

## Data storage

Data is stored in an anonymous volume that is mounted on ``/data`` (see docker inspect for more information). You can use a host volume to store the data in a specific directory on the host. The directory could exist, the permissions are handled by the container.

Start container:

``` console
docker run -d -p 9001:9001 -p 9030:9030 --name tor -v /data/tor:/data svengo/tor
```

## Basic config

Use environment variables for basic configuration. The content of the environment variables are used to build `/etc/tor/torrc-defaults`. For a more advanced configuration you can edit the configuration file `/data/torrc` directly.

``` console
docker run -d -p 9001:9001 -p 9030:9030 --name tor -v /data/tor:/data -e "NICKNAME=MyDockerTorNode" -e "CONTACTINFO=foo@example.com" svengo/tor``
```

### Docker Compose

You can use [docker-compose.yml](https://github.com/svengo/docker-tor/blob/main/docker-compose.yml). Don't forget to edit the file to suit your needs.

### Environment Variables

svengo/tor uses several environment variables to generate the ``torrc-defaults``-file, the variables are set to reasonable defaults (see below). You can edit ``/data/torrc`` to your needs after the first run.

#### ORPORT

`ORPORT=[address:]PORT|auto [flags]`

Advertise this port to listen for connections from Tor clients and servers. This option is required to be a Tor server. Set it to "auto" to have Tor pick a port for you. Set it to 0 to not run an ORPORT at all. 

(Default: ``9001``)

#### DIRPORT

`DIRPORT=[address:]PORT|auto [flags]`

If this option is nonzero, advertise the directory service on this port. Set it to "auto" to have Tor pick a port for you. 

(Default: ``9030``)

#### EXITPOLICY

`EXITPOLICY=policy,policy,…`

Set an exit policy for this server. Each policy is of the form "accept[6]|reject[6] ADDR[/MASK][:PORT]". If /MASK is omitted then this policy just applies to the host given. Instead of giving a host or network you can also use "*" to denote the universe (0.0.0.0/0 and ::/128), or *4 to denote all IPv4 addresses, and *6 to denote all IPv6 addresses. PORT can be a single port number, an interval of ports "FROM_PORT-TO_PORT", or "*". If PORT is omitted, that means "*".

(Default: ``reject *:* # no exits allowed``)

#### CONTROLPORT

`CONTROLPORT=PORT|unix:path|auto [flags]`

If set, Tor will accept connections on this port and allow those connections to control the Tor process using the Tor Control Prot
ocol (described in control-spec.txt in torspec). Note: unless you also specify HASHEDCONTROLPASSWORD, setting this option will cau
se Tor to allow any process on the local host to control it.

(Default: ``9051``)

#### HASHEDCONTROLPASSWORD

`HASHEDCONTROLPASSWORD=hashed_password`

Allow connections on the control port if they present the password whose one-way hash is hashed_password. You can compute the hash of a password by running ``docker run svengo/tor tor --hash-password password``

(Default: ``16:872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C``)

#### NICKNAME

`NICKNAME=name`

Set the server’s nickname to 'name'. Nicknames must be between 1 and 19 characters inclusive, and must contain only the characters ``[a-zA-Z0-9]``.

(Default: ``ididnteditheconfig``)

#### CONTACTINFO

`CONTACTINFO=email_address`

Administrative contact information for this relay or bridge. This line can be used to contact you if your relay or bridge is misconfigured or something else goes wrong. Note that we archive and publish all descriptors containing these lines and that Google indexes them, so spammers might also collect them. You may want to obscure the fact that it’s an email address and/or generate a new address for this purpose.

You can use [Tor ContactInfo Generator](https://torcontactinfogenerator.netlify.app/) to create a contact info following [ContactInfo-Information-Sharing-Specification](https://nusenu.github.io/ContactInfo-Information-Sharing-Specification/).

(Default: ``Random Person <nobody AT example dot com>``)

#### MYFAMILY

`MYFAMILY=node,node,...`

Declare that this Tor server is controlled or administered by a group or organization identical or similar to that of the other servers, defined by their identity fingerprints. When two servers both declare that they are in the same 'family', Tor clients will not use them in the same circuit. (Each server only needs to list the other servers in its family; it doesn’t need to list itself, but it won’t hurt.) Do not list any bridge relay as it would compromise its concealment.

When listing a node, it’s better to list it by fingerprint than by nickname: fingerprints are more reliable.

(Default: *empty*)

#### ADDRESS

`ADDRESS=tor-node01.example.com`

The IPv4 address of this server, or a fully qualified domain name of this server that resolves to an IPv4 address.  You can leave this unset, and Tor will try to guess your IPv4 address.  This IPv4 address is the one used to tell clients and other servers where to find your Tor server; it doesn't affect the address that your server binds to.  It also seems to work with an IPv6 address.

# Feedback
Please report any problems as issue on github: https://github.com/svengo/docker-tor/issues

# Thanks
Thanks to [Natanael Copa](https://github.com/ncopa) for [su-exec](https://github.com/ncopa/su-exec) and the [Tor Project](https://www.torproject.org/).
