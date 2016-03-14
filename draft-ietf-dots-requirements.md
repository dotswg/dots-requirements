---
title: Distributed Denial of Service (DDoS) Open Threat Signaling Requirements
abbrev: DOTS Requirements
docname: draft-ietf-dots-requirements-01
date: 2016-03-18

area: Security
wg: DOTS
kw: Internet-Draft
cat: info

coding: us-ascii
pi:
  toc: yes
  sortrefs: no
  symrefs: yes

author:
      -
        ins: A. Mortensen
        name: Andrew Mortensen
        org: Arbor Networks, Inc.
        street: 2727 S. State St
        city: Ann Arbor, MI
        code: 48104
        country: United States
        email: amortensen@arbor.net
      -
        ins: R. Moskowitz
        name: Robert Moskowitz
        org: HTT Consulting
        street:
        -
        city: Oak Park, MI
        code: 42837
        country: United States
        email: rgm@htt-consult.com
      -
        ins: T. Reddy
        name: Tirumaleswar Reddy
        org: Cisco Systems, Inc.
        street:
        - Cessna Business Park, Varthur Hobli
        - Sarjapur Marathalli Outer Ring Road
        city: Bangalore, Karnataka
        code: 560103
        country: India
        email: tireddy@cisco.com

normative:
  RFC0768:
  RFC0793:
  RFC2119:

informative:
  I-D.ietf-dots-use-cases:
  RFC1518:
  RFC1519:
  RFC2373:
  RFC3261:
  RFC4271:

--- abstract

This document defines the requirements for the Distributed Denial of Service
(DDoS) Open Threat Signaling (DOTS) protocols coordinating attack response
against DDoS attacks.

--- middle

Introduction            {#problems}
============

Context and Motivation
----------------------
Distributed Denial of Service (DDoS) attacks continue to plague networks
around the globe, from Tier-1 service providers on down to enterprises and
small businesses. Attack scale and frequency similarly have continued to
increase, in part as a result of software vulnerabilities leading to reflection
and amplification attacks. Once staggering attack traffic volume is now the
norm, and the impact of larger-scale attacks attract the attention of
international press agencies.

The greater impact of contemporary DDoS attacks has led to increased focus on
coordinated attack response. Many institutions and enterprises lack the
resources or expertise to operate on-premise attack prevention solutions
themselves, or simply find themselves constrained by local bandwidth
limitations. To address such gaps, security service providers have begun to
offer on-demand traffic scrubbing services. Each service offers its own
interface for subscribers to request attack mitigation, tying subscribers to
proprietary implementations while also limiting the subset of network elements
capable of participating in the attack response. As a result of incompatibility
across services, attack responses may be fragmentary or otherwise incomplete,
leaving key players in the attack path unable to assist in the defense.

The lack of a common method to coordinate a real-time response among involved
actors and network domains inhibits the speed and effectiveness of DDoS attack
mitigation. This document describes the required characteristics of DOTS
protocols that would mitigate contemporary DDoS attack impact and lead to more
efficient defensive strategies.

DOTS is less concerned with the form of defensive action than with communicating
the need for that action. DOTS supplements calls for help with pertinent details
about the detected attack, allowing entities participating in DOTS to form ad
hoc, adaptive alliances against DDoS attacks as described in the DOTS use cases
[I-D.ietf-dots-use-cases]. The requirements in this document are derived from
those use cases.


Terminology     {#terminology}
-----------

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.

This document adopts the following terms:

DDoS:
: A distributed denial-of-service attack, in which high levels of traffic
  originating from widely distributed sources are directed at a target on a
  network. DDoS attacks are intended to diminish or block availability of
  servers, services, applications, and/or other functionality of an attack
  target.

DDoS attack target:
: A networked server, network service or application that is the focus of a DDoS
  attack.

DDoS attack telemetry:
: Collected network traffic characteristics defining the nature of a DDoS
  attack. This document makes no assumptions regarding telemetry collection
  methodology.

Countermeasure:
: An action or set of actions taken to recognize and filter out DDoS attack
  traffic while passing legitimate traffic to the attack target.

Mitigation:
: A set of countermeasures enforced against traffic destined for the target or
  targets of a detected or reported DDoS attack, where countermeasure
  enforcement is managed by an entity in the network path between attack sources
  and the attack target. Mitigation methodology is out of scope for this
  document.

Mitigator:
: An entity, typically a network element, capable of performing mitigation of a
  detected or reported DDoS attack. For the purposes of this document, this
  entity is a black box capable of mitigation, making no assumptions about
  availability or design of countermeasures, nor about the programmable
  interface between this entity and other network elements. The mitigator and
  DOTS server are assumed to belong to the same administrative entity.

DOTS client:
: A DOTS-aware software module responsible for requesting attack response
  coordination with other DOTS-aware elements.

DOTS server:
: A DOTS-aware software module handling and responding to messages from DOTS
  clients. The DOTS server MAY enable mitigation on behalf of the DOTS client,
  if requested, by communicating the DOTS client's request to the mitigator and
  relaying any mitigator feedback to the requesting DOTS client. A DOTS server
  may also be a mitigator.

DOTS relay:
: A DOTS-aware network element positioned between a DOTS server and a DOTS
  client. A DOTS relay receives messages from a DOTS client and relays them
  to a DOTS server, and similarly passes messages from the DOTS server to the
  DOTS client.

DOTS agents:
: A collective term for DOTS clients, servers and relays.

signal channel:
: A bidirectional, mutually authenticated communication layer between DOTS
  agents characterized by resilience even in conditions leading to severe
  packet loss, such as a volumetric DDoS attack causing network congestion.

DOTS signal:
: A concise authenticated status/control message transmitted between DOTS
  agents, used to indicate client's need for mitigation, as well as to convey
  the status of any requested mitigation.

heartbeat:
: A keep-alive message transmitted between DOTS agents over the signal channel,
  used to measure peer health. Heartbeat functionality is not required to be
  distinct from signal.

client signal:
: A message sent from a DOTS client to a DOTS server over the signal channel,
  possibly traversing a DOTS relay, indicating the DOTS client's need for
  mitigation, as well as the scope of any requested mitigation, optionally
  including detected attack telemetry to supplement server-initiated
  mitigation.

server signal:
: A message sent from a DOTS server to a DOTS client over the signal channel.
  Note that a server signal is not a response to client signal, but a DOTS
  server-initiated status message sent to the DOTS client, containing
  information about the status of any requested mitigation and its efficacy.

data channel:
: A secure communication layer between client and server used for infrequent
  bulk exchange of data not easily or appropriately communicated through the
  signal channel under attack conditions.

blacklist:
: a list of source addresses or prefixes from which traffic should be blocked.

whitelist:
: a list of source addresses or prefixes from which traffic should always be
  allowed, regardless of contradictory data gleaned in a detected attack.


Requirements
============

This section describes the required features and characteristics of the DOTS
protocols. The requirements assume architectural concepts and components similar
to those described in [I-D.draft-mortensen-dots-architecture].

DOTS is an advisory protocol. An active DDoS attack against the entity
controlling the DOTS client need not be present before establishing DOTS
communication between DOTS agents. Indeed, establishing a relationship with peer
DOTS agents during nominal network conditions provides the foundation for more
rapid attack response against future attacks, as all interactions setting up
DOTS, including any business or service level agreements, are already complete.

DOTS must at a minimum make it possible for a DOTS client to request a DOTS
server's aid in mounting a coordinated defense against a detected attack,
signaling inter- or intra-domain as requested by local operators. DOTS clients
should similarly be able to withdraw aid requests. DOTS requires no justification
from DOTS clients for requests for help, nor must must DOTS clients justify
withdrawing help requests: the decision is local to the entity owning the DOTS
clients. Regular feedback between DOTS clients and DOTS server supplement the
defensive alliance by maintaining a common understanding of DOTS peer health and
activity. Bidirectional communication between DOTS clients and DOTS servers is
therefore critical.

Yet DOTS must also work with a set of competing operational goals.
On the one hand, the protocol must be resilient under extremely hostile network
conditions, providing continued contact between DOTS agents even as attack
traffic saturates the link. Such resiliency may be developed several ways, but
characteristics such as small message size, asynchronous, redundant message
delivery and minimal connection overhead (when possible given local network
policy) will tend to contribute to the robustness demanded by a viable DOTS
protocol. Operators of peer DOTS-enabled domains may enable quality- or
class-of-service traffic tagging to increase the probability of successful DOTS
signal delivery, but DOTS requires no such policies be in place. The DOTS
solution indeed must be viable especially in their absence.

On the other hand, DOTS must include protections ensuring message
confidentiality, integrity and authenticity to keep the protocol from becoming
another vector for the very attacks it's meant to help fight off. DOTS clients
must be able to authenticate DOTS servers, and vice versa, for DOTS to operate
safely, meaning the DOTS agents must have a way to negotiate and agree upon the
terms of protocol security. Attacks against the transport protocol should not
offer a means of attack against the message confidentiality, integrity and
authenticity.

The DOTS server and client must also have some common method of defining the
scope of any mitigation performed by the mitigator, as well as making
adjustments to other commonly configurable features, such as listen ports,
exchanging black- and white-lists, and so on.

Finally, DOTS should provide sufficient extensibility to meet local, vendor or
future needs in coordinated attack defense, although this consideration is
necessarily superseded by the other operational requirements.


General Requirements
--------------------

GEN-001
: Extensibility: Protocols and data models developed as part of DOTS MUST be
  extensible in order to keep DOTS adaptable to operational and proprietary
  DDoS defenses. Future extensions MUST be backward compatible.

GEN-002
: Resilience and Robustness: The signaling protocol MUST be designed to maximize
  the probability of signal delivery even under the severely constrained network
  conditions imposed by particular attack traffic. The protocol MUST be
  resilient, that is, continue operating despite message loss and out-of-order
  or redundant signal delivery.

GEN-003
: Bidirectionality: To support peer health detection, to maintain an open
  signal channel, and to increase the probability of signal delivery during
  attack, the signal channel MUST be bidirectional, with client and server
  transmitting signals to each other at regular intervals, regardless of any
  client request for mitigation. Unidirectional messages MUST be supported
  within the bidirectional signal channel to allow for unsolicited message
  delivery, enabling asynchronous notifications between agents.

GEN-004
: Sub-MTU Message Size: To avoid message fragmentation and the consequently
  decreased probability of message delivery, signaling protocol message size
  MUST be kept under signaling path Maximum Transmission Unit (MTU), including
  the byte overhead of any encapsulation, transport headers, and transport- or
  message-level security.

GEN-005
: Bulk Data Exchange: Infrequent bulk data exchange between DOTS agents can also
  significantly augment attack response coordination, permitting such tasks as
  population of black- or white-listed source addresses; address or prefix group
  aliasing; exchange of incident reports; and other hinting or configuration
  supplementing attack response.

: As the resilience requirements for DOTS mandate small signal message size, a
  separate, secure data channel utilizing an established reliable transport
  protocol MUST be used for bulk data exchange.


Operational Requirements
------------------------

OP-001
: Use of Common Transport Protocols: DOTS MUST operate over common widely
  deployed and standardized transport protocols. While the use of connectionless
  protocols, in particular the User Datagram Protocol (UDP) {{RFC0768}}, is
  RECOMMENDED for the signal channel, a universally deployed,
  connection-oriented protocol like the Transmission Control Protocol (TCP)
  [RFC0793] MAY be used if necessary due to network policy or middlebox
  capabilities or configurations.

OP-002
: Session Health Monitoring: Peer DOTS agents MUST regularly send heartbeats to
  each other after mutual authentication in order to keep the DOTS session open.
  A session MUST be considered active until a DOTS agent explicitly ends the
  session, or either DOTS agent fails to receive heartbeats from the other after
  a mutually negotiated timeout period has elapsed.

OP-003
: Session Redirection: In order to increase DOTS operational flexibility and
  scalability, DOTS servers SHOULD be able to redirect DOTS clients to another
  DOTS server or relay at any time. Due to the decreased probability of DOTS
  server signal delivery due to link congestion, it is RECOMMENDED DOTS servers
  avoid redirecting while mitigation is enabled during an active attack against
  a target in the DOTS client's domain.

OP-004
: Mitigation Status: DOTS MUST provide a means to report the status of an action
  requested by a DOTS client. In particular, DOTS clients MUST be able to
  request or withdraw a request for mitigation from the DOTS server. The DOTS
  server MUST acknowledge a DOTS client's request to withdraw from coordinated
  attack response in subsequent signals, and MUST cease mitigation activity as
  quickly as possible.  However, a DOTS client rapidly toggling active
  mitigation may result in undesirable side-effects for the network path, such
  as route or DNS flapping.  A DOTS server therefore MAY continue mitigating for
  a mutually negotiated period after receiving the DOTS client's request to
  stop.

: A server MAY refuse to engage in coordinated attack response with a client.
  To make the status of a client's request clear, the server MUST indicate in
  server signals whether client-initiated mitigation is active. When a
  client-initiated mitigation is active, and threat handling details such as
  mitigation scope and statistics are available to the server, the server
  SHOULD include those details in server signals sent to the client. DOTS
  clients SHOULD take mitigation statistics into account when deciding whether
  to request the DOTS server cease mitigation.

OP-005
: Mitigation Lifetime: A DOTS client SHOULD indicate the desired lifetime of any
  mitigation requested from the DOTS server. As DDoS attack duration is
  unpredictable, the DOTS client SHOULD be able to extend mitigation lifetime
  with periodic renewed requests for help. When the mitigation lifetime comes to
  an end, the DOTS server SHOULD delay session termination for a
  protocol-defined grace period to allow for delivery of delayed mitigation
  renewals over the signal channel. After the grace period elapses, the DOTS
  server MAY terminate the session at any time.

: If a DOTS client does not include a mitigation lifetime in requests for help
  sent to the DOTS server, the DOTS server will use a reasonable default as
  defined by the protocol. As above, the DOTS client MAY extend a current
  mitigation request's lifetime trivially with renewed requests for help.

: A DOTS client MAY also request an indefinite mitigation lifetime, enabling
  architectures in which the mitigator is always in the traffic path to the
  resources for which the DOTS client is requesting protection. DOTS servers MAY
  refuse such requests for any reason. The reasons themselves are not in scope.

OP-006
: Mitigation Scope: DOTS clients MUST indicate the desired address or prefix
  space coverage of any mitigation, for example by using Classless Internet
  Domain Routing (CIDR) [RFC1518],[RFC1519] prefixes, [RFC2373] for IPv6
  prefixes, the length/prefix convention established in the Border Gateway
  Protocol (BGP) [RFC4271], SIP URIs {{RFC3261}}, E.164 numbers, DNS names, or
  by a prefix group alias agreed upon with the server through the data channel.

: If there is additional information available narrowing the scope of any
  requested attack response, such as targeted port range, protocol, or service,
  DOTS clients SHOULD include that information in client signals. DOTS clients
  MAY also include additional attack details. Such supplemental information is
  OPTIONAL, and DOTS servers MAY ignore it when enabling countermeasures on the
  mitigator.

: As an active attack evolves, clients MUST be able to adjust as necessary the
  scope of requested mitigation by refining the address space requiring
  intervention.

OP-007
: Conflict Detection and Notification: Multiple DOTS clients controlled by a
  signal administrative entity may send conflicting mitigation requests for pool
  of protected resources, as a result of misconfiguration, operator error, or
  compromised DOTS clients. DOTS servers attempting to honor conflicting
  requests may flap network route or DNS information, degrading the networks
  attempting to participate in attack response with the DOTS clients. DOTS
  servers SHALL detect such conflicting requests, and SHALL notify the DOTS
  clients in conflict. The notification SHOULD indicate the nature and scope of
  the conflict, for example, the overlapping prefix range in a conflicting
  mitigation request.


Data Channel Requirements
-------------------------

The data channel is intended to be used for bulk data exchanges between DOTS
agents. Unlike the signal channel, which must operate nominally even when
confronted with despite signal degradation due to packet loss, the data
channel is not expected to be constructed to deal with attack conditions.
As the primary function of the data channel is data exchange, a reliable
transport is required in order for DOTS agents to detect data delivery success
or failure.

The data channel must be extensible. We anticipate the data channel will be used
for such purposes as configuration or resource discovery.  For example, a DOTS
client may submit to the DOTS server a collection of prefixes it wants to refer
to by alias when requesting mitigation, to which the server would respond with a
success status and the new prefix group alias, or an error status and message in
the event the DOTS client's data channel request failed. The transactional
nature of such data exchanges suggests a separate set of requirements for the
data channel, while the potentially sensitive content sent between DOTS agents
requires extra precautions to ensure data privacy and authenticity.

DATA-001
: Reliable transport: Transmissions over the data channel MUST be transactional,
  requiring reliable, in-order packet delivery.

DATA-002
: Data privacy and integrity: Transmissions over the data channel is likely to
  contain operationally or privacy-sensitive information or instructions from
  the remote DOTS agent. Theft or modification of data channel transmissions
  could lead to information leaks or malicious transactions on behalf of the
  sending agent.  (See Section 4.) Consequently data sent over the data channel
  MUST be encrypted and authenticated using current industry best practices.
  DOTS servers and relays MUST enable means to prevent leaking operationally or
  privacy-sensitive data. Although administrative entities participating in DOTS
  may detail what data may be revealed to third-party DOTS agents, such
  considerations are not in scope for this document.

DATA-003
: Mutual authentication: DOTS agents MUST mutually authenticate each other
  before data may be exchanged over the data channel. DOTS agents MAY take
  additional steps to authorize data exchange, as in the prefix group example
  above, before accepting data over the data channel. The form of
  authentication and authorization is unspecified.

DATA-004
: Black- and whitelist management: DOTS servers SHOULD provide methods for
  DOTS clients to manage black- and white-lists of source addresses of traffic
  destined for addresses belonging to a client.

: For example, a DOTS client
  should be able to create a black- or whitelist entry; retrieve a list of
  current entries from either list; update the content of either list; and
  delete entries as necessary.

: How the DOTS server determines client ownership of address space is not in
  scope.


Security requirements
---------------------

DOTS must operate within a particularly strict security context, as an
insufficiently protected signal or data channel may be subject to abuse,
enabling or supplementing the very attacks DOTS purports to mitigate.

SEC-001
: Peer Mutual Authentication: DOTS clients and DOTS servers MUST authenticate
  each other before a DOTS session is considered valid. The method of
  authentication is not specified, but should follow current industry best
  practices with respect to any cryptographic mechanisms to authenticate the
  remote peer.

SEC-002
: Message Confidentiality, Integrity and Authenticity: DOTS protocols MUST take
  steps to protect the confidentiality, integrity and authenticity of messages
  sent between client and server. While specific transport- and message-level
  security options are not specified, the protocols MUST follow current industry
  best practices for encryption and message authentication.

: In order for DOTS protocols to remain secure despite advancements in
  cryptanalysis, DOTS agents MUST be able to negotiate the terms and mechanisms
  of protocol security, subject to the interoperability and signal message size
  requirements above.

SEC-003
: Message Replay Protection: In order to prevent a passive attacker from
  capturing and replaying old messages, DOTS protocols MUST provide a method
  for replay detection, such as including a timestamp or sequence number in
  every heartbeat and signal sent between DOTS agents.


Data model requirements
-----------------------

TODO


Congestion Control Considerations
=================================

The DOTS signal channel will not contribute measurably to link congestion, as
the protocol's transmission rate will be negligible regardless of network
conditions. Bulk data transfers are performed over the data channel, which
should use a reliable transport with built-in congestion control mechanisms,
such as TCP.

Security Considerations         {#security-considerations}
=======================

DOTS is at risk from three primary attacks: DOTS agent impersonation, traffic
injection, and signaling blocking. The DOTS protocol MUST be designed for
minimal data transfer to address the blocking risk. Impersonation and traffic
injection mitigation can be managed through current secure communications best
practices. DOTS is not subject to anything new in this area. One consideration
could be to minimize the security technologies in use at any one time. The more
needed, the greater the risk of failures coming from assumptions on one
technology providing protection that it does not in the presence of another
technology.

Acknowledgements
================

The editors wish to thank Med Boucadair for his careful reading of and suggested
revisions to this document.


Change Log
==========

00 revision
-----------

2015-10-15

Initial revision
----------------

2015-09-24      Andrew Mortensen

--- back
