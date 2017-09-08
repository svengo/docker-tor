# docker-tor

[![](https://images.microbadger.com/badges/version/svengo/tor.svg)](https://microbadger.com/images/svengo/tor "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/svengo/tor.svg)](https://microbadger.com/images/svengo/tor "Get your own image badge on microbadger.com")

Simple docker container for a tor node.

The container uses the tor package from the community repository of [alpine:edge](https://pkgs.alpinelinux.org/packages?name=tor&branch=edge&repo=&arch=&maintainer=).

## How to use this image

### Start a simple tor node

``docker run -p 9001:9001 -p 9030:9030 svengo/tor``

### Data storage

Data is stored in an anonymous volume that is mounted on ``/data`` (see docker inspect for more information). You can use a host volume to store the data in a specific directory on the host. The directory could exist, the permissions are handled by the container.

Start container:

``docker run -p 9001:9001 -p 9030:9030  -v /data/tor:/data  --name tor svengo/tor``

### Environment Variables

The tor image uses several environment variables to generate the ``torrc``-file on the first run, the variables are set to reasonable defaults. The image uses only a small selection of configuration options - feel free to file an [issue](https://github.com/svengo/docker-tor/issues) if you are missing something! If you need to change ``torrc`` after the first run, you can  edit ``/data/torrc`` manually.

#### ORPORT

**ORPORT=[address:]PORT|auto [flags]**

Advertise this port to listen for connections from Tor clients and servers. This option is required to be a Tor server. Set it to "auto" to have Tor pick a port for you. Set it to 0 to not run an ORPORT at all. 

(Default: 9001)

#### DIRPORT

**DIRPORT=[address:]PORT|auto [flags]**

If this option is nonzero, advertise the directory service on this port. Set it to "auto" to have Tor pick a port for you. 

(Default: 9030)

#### EXITPOLICY

**EXITPOLICY=policy,policy,…**

Set an exit policy for this server. Each policy is of the form "accept[6]|reject[6] ADDR[/MASK][:PORT]". If /MASK is omitted then this policy just applies to the host given. Instead of giving a host or network you can also use "*" to denote the universe (0.0.0.0/0 and ::/128), or *4 to denote all IPv4 addresses, and *6 to denote all IPv6 addresses. PORT can be a single port number, an interval of ports "FROM_PORT-TO_PORT", or "*". If PORT is omitted, that means "*".

(Default: reject *:* # no exits allowed)

#### CONTROLPORT

**CONTROLPORT=PORT|unix:path|auto [flags]**

If set, Tor will accept connections on this port and allow those connections to control the Tor process using the Tor Control Protocol (described in control-spec.txt in torspec). Note: unless you also specify HASHEDCONTROLPASSWORD, setting this option will cause Tor to allow any process on the local host to control it.

(Default: 9051)

#### HASHEDCONTROLPASSWORD

**HASHEDCONTROLPASSWORD=hashed_password**

Allow connections on the control port if they present the password whose one-way hash is hashed_password. You can compute the hash of a password by running ``docker run svengo/tor tor --hash-password password``

(Default: *empty*)

#### NICKNAME

**NICKNAME=name**

Set the server’s nickname to 'name'. Nicknames must be between 1 and 19 characters inclusive, and must contain only the characters ``[a-zA-Z0-9]``.

(Default: ididnteditheconfig)

#### CONTACTINFO

**CONTACTINFO=email_address**

Administrative contact information for this relay or bridge. This line can be used to contact you if your relay or bridge is misconfigured or something else goes wrong. Note that we archive and publish all descriptors containing these lines and that Google indexes them, so spammers might also collect them. You may want to obscure the fact that it’s an email address and/or generate a new address for this purpose.

(Default: ``Random Person <nobody AT example dot com>``)

#### MYFAMILY
**MYFAMILY=node,node,…**
Declare that this Tor server is controlled or administered by a group or organization identical or similar to that of the other servers, defined by their identity fingerprints. When two servers both declare that they are in the same 'family', Tor clients will not use them in the same circuit. (Each server only needs to list the other servers in its family; it doesn’t need to list itself, but it won’t hurt.) Do not list any bridge relay as it would compromise its concealment.

When listing a node, it’s better to list it by fingerprint than by nickname: fingerprints are more reliable.

(Default: *empty*)
