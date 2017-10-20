# docker-tor

[![](https://images.microbadger.com/badges/version/svengo/tor.svg)](https://microbadger.com/images/svengo/tor "Get your own version badge on microbadger.com") [![](https://images.microbadger.com/badges/image/svengo/tor.svg)](https://microbadger.com/images/svengo/tor "Get your own image badge on microbadger.com") [![Anchore Image Policy](https://anchore.io/service/badges/policy/e2f5cbb0326c9487c529e84c2efc00210cd5b04be71d339e4268d188319bca7c?registry=dockerhub&repository=svengo/teamspeak&tag=3.0.13.8)](https://anchore.io)

Simple docker container for running a tor node.


## How to use this image

### Start a simple tor node

The command starts a tor node and open ports 9001 and 9030:

``docker run -d -p 9001:9001 -p 9030:9030 --name tor svengo/tor``

### Data storage

Data is stored in an anonymous volume that is mounted on ``/data`` (see docker inspect for more information). You can use a host volume to store the data in a specific directory on the host. The directory could exist, the permissions are handled by the container.

Start container:

``docker run -d -p 9001:9001 -p 9030:9030 --name tor -v /data/tor:/data svengo/tor``

### Basic config

Use environment variables for basic configuration:

``docker run -d -p 9001:9001 -p 9030:9030 --name tor -v /data/tor:/data -e "NICKNAME=MyDockerTorNode" -e "CONTACTINFO=foo@example.com" svengo/tor``


### Environment Variables

svengo/tor uses several environment variables to generate the ``torrc-defaults``-file, the variables are set to reasonable defaults (see below). You can edit ``/data/torrc`` to your needs after the first run.

#### ORPORT

**ORPORT=[address:]PORT|auto [flags]**

Advertise this port to listen for connections from Tor clients and servers. This option is required to be a Tor server. Set it to "auto" to have Tor pick a port for you. Set it to 0 to not run an ORPORT at all. 

(Default: ``9001``)

#### DIRPORT

**DIRPORT=[address:]PORT|auto [flags]**

If this option is nonzero, advertise the directory service on this port. Set it to "auto" to have Tor pick a port for you. 

(Default: ``9030``)

#### EXITPOLICY

**EXITPOLICY=policy,policy,…**

Set an exit policy for this server. Each policy is of the form "accept[6]|reject[6] ADDR[/MASK][:PORT]". If /MASK is omitted then this policy just applies to the host given. Instead of giving a host or network you can also use "*" to denote the universe (0.0.0.0/0 and ::/128), or *4 to denote all IPv4 addresses, and *6 to denote all IPv6 addresses. PORT can be a single port number, an interval of ports "FROM_PORT-TO_PORT", or "*". If PORT is omitted, that means "*".

(Default: ``reject *:* # no exits allowed``)

#### HASHEDCONTROLPASSWORD

**HASHEDCONTROLPASSWORD=hashed_password**

Allow connections on the control port if they present the password whose one-way hash is hashed_password. You can compute the hash of a password by running ``docker run svengo/tor tor --hash-password password``

(Default: ``16:872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C``)

#### NICKNAME

**NICKNAME=name**

Set the server’s nickname to 'name'. Nicknames must be between 1 and 19 characters inclusive, and must contain only the characters ``[a-zA-Z0-9]``.

(Default: ``ididnteditheconfig``)

#### CONTACTINFO

**CONTACTINFO=email_address**

Administrative contact information for this relay or bridge. This line can be used to contact you if your relay or bridge is misconfigured or something else goes wrong. Note that we archive and publish all descriptors containing these lines and that Google indexes them, so spammers might also collect them. You may want to obscure the fact that it’s an email address and/or generate a new address for this purpose.

(Default: ``Random Person <nobody AT example dot com>``)

#### MYFAMILY

**MYFAMILY=node,node,...**

Declare that this Tor server is controlled or administered by a group or organization identical or similar to that of the other servers, defined by their identity fingerprints. When two servers both declare that they are in the same 'family', Tor clients will not use them in the same circuit. (Each server only needs to list the other servers in its family; it doesn’t need to list itself, but it won’t hurt.) Do not list any bridge relay as it would compromise its concealment.

When listing a node, it’s better to list it by fingerprint than by nickname: fingerprints are more reliable.

(Default: *empty*)
