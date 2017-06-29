---
title: Distributed Denial of Service (DDoS) Open Threat Signaling Requirements
abbrev: DOTS Requirements
docname: draft-ietf-dots-requirements-05
date: @DATE@

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
        org: Arbor Networks
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
        org: McAfee, Inc.
        street:
        - Embassy Golf Link Business Park
        city: Bangalore, Karnataka
        code: 560071
        country: India
        email: TirumaleswarReddy_Konda@McAfee.com

normative:
  RFC0768:
  RFC0791:
  RFC0793:
  RFC1035:
  RFC1122:
  RFC1191:
  RFC2119:
  RFC3986:
  RFC4291:
  RFC4632:
  RFC4821:
  RFC5405:
  RFC5952:

informative:
  I-D.ietf-dots-architecture:
  I-D.ietf-dots-use-cases:
  RFC3261:
  RFC4732:

--- abstract

This document defines the requirements for the Distributed Denial of Service
(DDoS) Open Threat Signaling (DOTS) protocols coordinating attack response
against DDoS attacks.

--- middle

Introduction            {#problems}
============

Context and Motivation
----------------------
Distributed Denial of Service (DDoS) attacks continue to plague network
operators around the globe, from Tier-1 service providers on down to enterprises
and small businesses. Attack scale and frequency similarly have continued to
increase, in part as a result of software vulnerabilities leading to reflection
and amplification attacks. Once-staggering attack traffic volume is now the
norm, and the impact of larger-scale attacks attract the attention of
international press agencies.

The greater impact of contemporary DDoS attacks has led to increased focus on
coordinated attack response. Many institutions and enterprises lack the
resources or expertise to operate on-premises attack mitigation solutions
themselves, or simply find themselves constrained by local bandwidth
limitations. To address such gaps, security service providers have begun to
offer on-demand traffic scrubbing services, which aim to separate the DDoS
traffic from legitimate traffic and forward only the latter. Today each such
service offers its own interface for subscribers to request attack mitigation,
tying subscribers to proprietary signaling implementations while also limiting
the subset of network elements capable of participating in the attack response.
As a result of signaling interface incompatibility, attack responses may be
fragmentary or otherwise incomplete, leaving key players in the attack path
unable to assist in the defense.

The lack of a common method to coordinate a real-time response among involved
actors and network domains inhibits the speed and effectiveness of DDoS attack
mitigation. This document describes the required characteristics of a protocol
enabling requests for DDoS attack mitigation, reducing attack impact and leading
to more efficient defensive strategies.

DOTS communicates the need for defensive action in anticipation of or in
response to an attack, but does not dictate the form any defensive action
takes. DOTS supplements calls for help with pertinent details about the detected
attack, allowing entities participating in DOTS to form ad hoc, adaptive
alliances against DDoS attacks as described in the DOTS use cases
[I-D.ietf-dots-use-cases]. The requirements in this document are derived from
those use cases and [I-D.ietf-dots-architecture].


Terminology     {#terminology}
-----------

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.

This document adopts the following terms:

DDoS:
: A distributed denial-of-service attack, in which traffic originating from
  multiple sources are directed at a target on a network. DDoS attacks are
  intended to cause a negative impact on the availability of servers, services,
  applications, and/or other functionality of an attack target.
  Denial-of-service considerations are discussed in detail in [RFC4732].

DDoS attack target:
: A network connected entity with a finite set of resources, such as network
  bandwidth,  memory or CPU, that is the focus of a DDoS attack. Potential
  targets include network elements, network links, servers, and services.

DDoS attack telemetry:
: Collected measurements and behavioral characteristics defining the nature of a
  DDoS attack.

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
  clients. The DOTS server SHOULD enable mitigation on behalf of the DOTS
  client, if requested, by communicating the DOTS client's request to the
  mitigator and returning selected mitigator feedback to the requesting DOTS
  client. A DOTS server MAY also be a mitigator.

DOTS agent:
: Any DOTS-aware software module capable of participating in a DOTS signal
  or data channel.

DOTS gateway:
: A logical DOTS agent resulting from the logical concatenation of a DOTS server
  and a DOTS client, analogous to a SIP Back-to-Back User Agent (B2BUA)
  [RFC3261]. DOTS gateways are discussed in detail in
  [I-D.ietf-dots-architecture].

Signal channel:
: A bidirectional, mutually authenticated communication channel between DOTS
  agents characterized by resilience even in conditions leading to severe
  packet loss, such as a volumetric DDoS attack causing network congestion.

DOTS signal:
: A concise authenticated status/control message transmitted between DOTS
  agents, used to indicate client's need for mitigation, as well as to convey
  the status of any requested mitigation.

Heartbeat:
: A message transmitted between DOTS agents over the signal channel, used as a
  keep-alive and to measure peer health.

Client signal:
: A message sent from a DOTS client to a DOTS server over the signal channel,
  indicating the DOTS client's need for mitigation, as well as the scope of any
  requested mitigation, optionally including additional attack details to
  supplement server-initiated mitigation.

Server signal:
: A message sent from a DOTS server to a DOTS client over the signal channel.
  Note that a server signal is not a response to client signal, but a DOTS
  server-initiated status message sent to DOTS clients with which the server has
  established signal channels.

Data channel:
: A secure communication layer between DOTS clients and DOTS servers used for
  infrequent bulk exchange of data not easily or appropriately communicated
  through the signal channel under attack conditions.

Filter:
: A policy matching a network traffic flow or set of flows and rate-limiting or
  discarding matching traffic.

Blacklist:
: A filter list of addresses, prefixes and/or other identifiers indicating
  sources from which traffic should be blocked, regardless of traffic content.

Whitelist:
: A list of addresses, prefixes and/or other identifiers from indicating sources
  from which traffic should always be allowed, regardless of contradictory data
  gleaned in a detected attack.

Multi-homed DOTS client:
: A DOTS client exchanging messages with multiple DOTS servers, each in a
  separate administrative domain.


Requirements            {#requirements}
============

This section describes the required features and characteristics of the DOTS
protocol.

DOTS is an advisory protocol. An active DDoS attack against the entity
controlling the DOTS client need not be present before establishing a
communication channel between DOTS agents. Indeed, establishing a relationship
with peer DOTS agents during normal network conditions provides the foundation
for more rapid attack response against future attacks, as all interactions
setting up DOTS, including any business or service level agreements, are already
complete.

The DOTS protocol must at a minimum make it possible for a DOTS client to
request a mitigator's aid mounting a defense, coordinated by a DOTS server,
against a suspected attack, signaling within or between domains as requested by
local operators. DOTS clients should similarly be able to withdraw aid requests.
DOTS requires no justification from DOTS clients for requests for help, nor do
DOTS clients need to justify withdrawing help requests: the decision is local to
the DOTS clients' domain.

Regular feedback between DOTS clients and DOTS server supplement the defensive
alliance by maintaining a common understanding of DOTS agent health and
activity. Bidirectional communication between DOTS clients and DOTS servers is
therefore critical.

DOTS protocol implementations face competing operational goals when maintaining
this bidirectional communication stream.  On the one hand, the protocol must be
resilient under extremely hostile network conditions, providing continued
contact between DOTS agents even as attack traffic saturates the link. Such
resiliency may be developed several ways, but characteristics such as small
message size, asynchronous, redundant message delivery and minimal connection
overhead (when possible given local network policy) will tend to contribute to
the robustness demanded by a viable DOTS protocol. Operators of peer
DOTS-enabled domains may enable quality- or class-of-service traffic tagging to
increase the probability of successful DOTS signal delivery, but DOTS requires
no such policies be in place. The DOTS solution indeed must be viable especially
in their absence.

On the other hand, DOTS must include protections ensuring message
confidentiality, integrity and authenticity to keep the protocol from becoming
another vector for the very attacks it's meant to help fight off. DOTS clients
must be able to authenticate DOTS servers, and vice versa, to avoid exposing new
attack surfaces when deploying DOTS; specifically, to prevent DDoS mitigation in
response to DOTS signaling from becoming a new form of attack. In order to
provide this level of proteection, DOTS agents must have a way to negotiate and
agree upon the terms of protocol security. Attacks against the transport
protocol should not offer a means of attack against the message confidentiality,
integrity and authenticity.

The DOTS server and client must also have some common method of defining the
scope of any mitigation performed by the mitigator, as well as making
adjustments to other commonly configurable features, such as listen ports,
exchanging black- and white-lists, and so on.

Finally, DOTS should be sufficiently extensible to meet future needs in
coordinated attack defense, although this consideration is necessarily
superseded by the other operational requirements.


General Requirements            {#general-requirements}
--------------------

GEN-001
: Extensibility: Protocols and data models developed as part of DOTS MUST be
  extensible in order to keep DOTS adaptable to operational and proprietary
  DDoS defenses. Future extensions MUST be backward compatible. DOTS protocols
  MUST use a version number system to distinguish protocol revisions.
  Implementations of older protocol versions SHOULD ignore information added
  to DOTS messages as part of newer protocol versions.

GEN-002
: Resilience and Robustness: The signaling protocol MUST be designed to maximize
  the probability of signal delivery even under the severely constrained network
  conditions imposed by particular attack traffic. The protocol MUST be
  resilient, that is, continue operating despite message loss and out-of-order
  or redundant message delivery. In support signaling protocol robustness,
  DOTS signals SHOULD be conveyed over a transport not susceptible to
  Head of Line Blocking.

GEN-003
: Bidirectionality: To support peer health detection, to maintain an open
  signal channel, and to increase the probability of signal delivery during
  attack, the signal channel MUST be bidirectional, with client and server
  transmitting signals to each other at regular intervals, regardless of any
  client request for mitigation. Unidirectional messages MUST be supported
  within the bidirectional signal channel to allow for unsolicited message
  delivery, enabling asynchronous notifications between agents.

GEN-004
: Bulk Data Exchange: Infrequent bulk data exchange between DOTS agents can also
  significantly augment attack response coordination, permitting such tasks as
  population of black- or white-listed source addresses; address or prefix group
  aliasing; exchange of incident reports; and other hinting or configuration
  supplementing attack response.

: As the resilience requirements for the DOTS signal channel mandate small
  signal message size, a separate, secure data channel utilizing a reliable
  transport protocol MUST be used for bulk data exchange.


Signal Channel Requirements        {#signal-channel-requirements}
---------------------------

SIG-001
: Use of Common Transport Protocols: DOTS MUST operate over common widely
  deployed and standardized transport protocols. While connectionless transport
  such as the User Datagram Protocol (UDP) {{RFC0768}} SHOULD be used for the
  signal channel, the Transmission Control Protocol (TCP) [RFC0793] MAY be used
  if necessary due to network policy or middlebox capabilities or
  configurations.

SIG-002
: Sub-MTU Message Size: To avoid message fragmentation and the consequently
  decreased probability of message delivery over a congested link, signaling
  protocol message size MUST be kept under signaling Path Maximum Transmission
  Unit (PMTU), including the byte overhead of any encapsulation, transport
  headers, and transport- or message-level security.

: DOTS agents SHOULD attempt to learn the PMTU through mechanisms such as Path
  MTU Discovery [RFC1191] or Packetization Layer Path MTU Discovery [RFC4821].
  If the PMTU cannot be discovered, DOTS agents SHOULD assume a PMTU of 1280
  bytes.  If IPv4 support on legacy or otherwise unusual networks is a
  consideration and PMTU is unknown, DOTS implementations MAY rely on a PMTU of
  576 bytes, as discussed in [RFC0791] and [RFC1122].

SIG-003
: Channel Health Monitoring: Peer DOTS agents MUST regularly send heartbeats to
  each other after mutual authentication in order to keep the DOTS signal
  channel active. A signal channel MUST be considered active until a DOTS agent
  explicitly ends the session, or either DOTS agent fails to receive heartbeats
  from the other after a mutually agreed upon timeout period has elapsed.

SIG-004
: Channel Redirection: In order to increase DOTS operational flexibility and
  scalability, DOTS servers SHOULD be able to redirect DOTS clients to another
  DOTS server at any time. DOTS clients MUST NOT assume the redirection target
  DOTS server shares security state with the redirecting DOTS server. DOTS
  clients MAY attempt abbreviated security negotiation methods supported by the
  protocol, such as DTLS session resumption, but MUST be prepared to negotiate
  new security state with the redirection target DOTS server.

: Due to the increased likelihood of packet loss caused by link congestion
  during an attack, DOTS servers SHOULD NOT redirect while mitigation is enabled
  during an active attack against a target in the DOTS client's domain.

SIG-005
: Mitigation Requests and Status:
  Authorized DOTS clients MUST be able to request scoped mitigation from DOTS
  servers. DOTS servers MUST send mitigation request status in response to
  DOTS clients requests for mitigation, and SHOULD accept scoped mitigation
  requests from authorized DOTS clients. DOTS servers MAY reject authorized
  requests for mitigation, but MUST include a reason for the rejection in the
  status message sent to the client.

: Due to the higher likelihood of packet loss during a DDoS attack, DOTS
  servers SHOULD regularly send mitigation status to authorized DOTS clients
  which have requested and been granted mitigation, regardless of client
  requests for mitigation status.

: When DOTS client-requested mitigation is active, DOTS server status messages
  SHOULD include the following mitigation metrics:

  * Total number of packets blocked by the mitigation

  * Current number of packets per second blocked

  * Total number of bytes blocked

  * Current number of bytes per second blocked

: DOTS clients SHOULD take these metrics into account when determining whether
  to ask the DOTS server to cease mitigation.

: Once a DOTS client requests mitigation, the client MAY withdraw that request
  at any time, regardless of whether mitigation is currently active. The DOTS
  server MUST immediately acknowledge a DOTS client's request to stop
  mitigation.

: To protect against route or DNS flapping caused by a client rapidly toggling
  mitigation, and to dampen the effect of oscillating attacks, DOTS servers MAY
  allow mitigation to continue for a limited period after acknowledging a DOTS
  client's withdrawal of a mitigation request. During this period, DOTS server
  status messages SHOULD indicate that mitigation is active but terminating.

: The active-but-terminating period is initially 30 seconds. If the client
  requests mitigation again before that 30 second window elapses, the DOTS
  server MAY exponentially increase the active-but-terminating period up to a
  maximum of 240 seconds (4 minutes). After the active-but-terminating period
  elapses, the DOTS server MUST treat the mitigation as terminated, as the DOTS
  client is no longer responsible for the mitigation. For example, if there is
  a financial relationship between the DOTS client and server domains, the DOTS
  client ceases incurring cost at this point.

SIG-006
: Mitigation Lifetime: DOTS servers MUST support mitigation lifetimes, and
  MUST terminate a mitigation when the lifetime elapses. DOTS servers also MUST
  support renewal of mitigation lifetimes in mitigation requests from DOTS
  clients, allowing clients to extend mitigation as necessary for the duration
  of an attack.

: DOTS servers MUST treat a mitigation terminated due to lifetime expiration
  exactly as if the DOTS client originating the mitigation had asked to end the
  mitigation, including the active-but-terminating period, as described above
  in SIG-005.

: DOTS clients MUST include a mitigation lifetime in all mitigation requests.
  If a DOTS client does not include a mitigation lifetime in requests for help
  sent to the DOTS server, the DOTS server will use a reasonable default as
  defined by the protocol.

: DOTS servers SHOULD support indefinite mitigation lifetimes, enabling
  architectures in which the mitigator is always in the traffic path to the
  resources for which the DOTS client is requesting protection. DOTS servers MAY
  refuse mitigations with indefinite lifetimes, for policy reasons. The reasons
  themselves are out of scope for this document, but MUST be included in the
  mitigation rejection message from the server, per SIG-005.

SIG-007
: Mitigation Scope: DOTS clients MUST indicate desired mitigation scope. The
  scope type will vary depending on the resources requiring mitigation. All DOTS
  agent implementations MUST support the following required scope types:

  * IPv4 addresses in dotted quad format

  * IPv4 address prefixes in CIDR notation [RFC4632]

  * IPv6 addresses [RFC4291]{{RFC5952}}

  * IPv6 address prefixes [RFC4291]{{RFC5952}}

  * Domain names [RFC1035]

: The following mitigation scope types are OPTIONAL:

  * Uniform Resource Identifiers [RFC3986]

: DOTS agents MUST support mitigation scope aliases, allowing DOTS client and
  server to refer to collections of protected resources by an opaque identifier
  created through the data channel, direct configuration, or other means. Domain
  name and URI mitigation scopes may be thought of as a form of scope alias, in
  which the addresses to which the domain name or URI resolve represent the full
  scope of the mitigation.

: If there is additional information available narrowing the scope of any
  requested attack response, such as targeted port range, protocol, or service,
  DOTS clients SHOULD include that information in client signals. DOTS clients
  MAY also include additional attack details. Such supplemental information is
  OPTIONAL, and DOTS servers MAY ignore it when enabling countermeasures on the
  mitigator.

: As an active attack evolves, clients MUST be able to adjust as necessary the
  scope of requested mitigation by refining the scope of resources requiring
  mitigation.

SIG-008
: Mitigation Efficacy: When a mitigation request by a DOTS client is active,
  DOTS clients SHOULD transmit a metric of perceived mitigation efficacy to the
  DOTS server, per "Automatic or Operator-Assisted CPE or PE Mitigators Request
  Upstream DDoS Mitigation Services" in [I-D.ietf-dots-use-cases]. DOTS servers
  MAY use the efficacy metric to adjust countermeasures activated on a mitigator
  on behalf of a DOTS client.

SIG-009
: Conflict Detection and Notification: Multiple DOTS clients controlled by a
  single administrative entity may send conflicting mitigation requests for pool
  of protected resources , as a result of misconfiguration, operator error, or
  compromised DOTS clients. DOTS servers attempting to honor conflicting
  requests may flap network route or DNS information, degrading the networks
  attempting to participate in attack response with the DOTS clients. DOTS
  servers SHALL detect such conflicting requests, and SHALL notify the DOTS
  clients in conflict. The notification SHOULD indicate the nature and scope of
  the conflict, for example, the overlapping prefix range in a conflicting
  mitigation request.

SIG-010:
: Network Address Translator Traversal: The DOTS protocol MUST operate over
  networks in which Network Address Translation (NAT) is deployed. If UDP is
  used as the transport for the DOTS signal channel, all considerations in
  "Middlebox Traversal Guidelines" in [RFC5405] apply to DOTS.  Regardless of
  transport, DOTS protocols MUST follow established best common practices (BCPs)
  for NAT traversal.


Data Channel Requirements       {#data-channel-requirements}
-------------------------

The data channel is intended to be used for bulk data exchanges between DOTS
agents. Unlike the signal channel, which must operate nominally even when
confronted with signal degradation due to packet loss, the data channel is not
expected to be constructed to deal with attack conditions.  As the primary
function of the data channel is data exchange, a reliable transport is required
in order for DOTS agents to detect data delivery success or failure.

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
: Reliable transport: Messages sent over the data channel MUST be delivered
  reliably, in order sent.

DATA-002
: Data privacy and integrity: Transmissions over the data channel are likely to
  contain operationally or privacy-sensitive information or instructions from
  the remote DOTS agent. Theft or modification of data channel transmissions
  could lead to information leaks or malicious transactions on behalf of the
  sending agent (see {{security-considerations}} below). Consequently data sent
  over the data channel MUST be encrypted and authenticated using current
  industry best practices.  DOTS servers MUST enable means to prevent leaking
  operationally or privacy-sensitive data. Although administrative entities
  participating in DOTS may detail what data may be revealed to third-party DOTS
  agents, such considerations are not in scope for this document.

DATA-003
: Resource Configuration: To help meet the general and signal channel
  requirements in this document, DOTS server implementations MUST provide an
  interface to configure resource identifiers, as described in SIG-007.

  DOTS server implementations MAY expose additional configurability. Additional
  configurability is implementation-specific.

DATA-004
: Black- and whitelist management: DOTS servers SHOULD provide methods for
  DOTS clients to manage black- and white-lists of traffic destined for
  resources belonging to a client.

: For example, a DOTS client should be able to create a black- or whitelist
  entry; retrieve a list of current entries from either list; update the content
  of either list; and delete entries as necessary.

: How the DOTS server determines client ownership of address space is not in
  scope.


Security requirements           {#security-requirements}
---------------------

DOTS must operate within a particularly strict security context, as an
insufficiently protected signal or data channel may be subject to abuse,
enabling or supplementing the very attacks DOTS purports to mitigate.

SEC-001
: Peer Mutual Authentication: DOTS agents MUST authenticate each other before a
  DOTS signal or data channel is considered valid. The method of authentication
  is not specified, but should follow current industry best practices with
  respect to any cryptographic mechanisms to authenticate the remote peer.

SEC-002
: Message Confidentiality, Integrity and Authenticity: DOTS protocols MUST take
  steps to protect the confidentiality, integrity and authenticity of messages
  sent between client and server. While specific transport- and message-level
  security options are not specified, the protocols MUST follow current industry
  best practices for encryption and message authentication.

: In order for DOTS protocols to remain secure despite advancements in
  cryptanalysis and traffic analysis, DOTS agents MUST be able to negotiate the
  terms and mechanisms of protocol security, subject to the interoperability and
  signal message size requirements above.

: While the interfaces between downstream DOTS server and upstream DOTS client
  within a DOTS gateway are implementation-specific, those interfaces
  nevertheless MUST provide security equivalent to that of the signal channels
  bridged by gateways in the signaling path. For example, when a DOTS gateway
  consisting of a DOTS server and DOTS client is running on the same logical
  device, they must be within the same process security boundary.

SEC-003
: Message Replay Protection: In order to prevent a passive attacker from
  capturing and replaying old messages, DOTS protocols MUST provide a method
  for replay detection.


Data Model Requirements                 {#data-model-requirements}
-----------------------

The value of DOTS is in standardizing a mechanism to permit elements, networks
or domains under or under threat of DDoS attack to request aid mitigating the
effects of any such attack. A well-structured DOTS data model is therefore
critical to the development of a successful DOTS protocol.

DM-001:
: Structure: The data model structure for the DOTS protocol may be described by
  a single module, or be divided into related collections of hierarchical
  modules and sub-modules. If the data model structure is split across modules,
  those distinct modules MUST allow references to describe the overall data
  model's structural dependencies.

DM-002:
: Versioning: To ensure interoperability between DOTS protocol implementations,
  data models MUST be versioned. The version number of the initial data model
  SHALL be 1. Each published change to the initial published DOTS data model
  SHALL increment the data model version by 1.

: How the protocol represents data model versions is not defined in this
  document.

DM-003:
: Mitigation Status Representation: The data model MUST provide the ability to
  represent a request for mitigation and the withdrawal of such a request. The
  data model MUST also support a representation of currently requested
  mitigation status, including failures and their causes.

DM-004:
: Mitigation Scope Representation: The data model MUST support representation of
  a requested mitigation's scope. As mitigation scope may be represented in
  several different ways, per SIG-007 above, the data model MUST be capable of
  flexible representation of mitigation scope.

DM-005:
: Mitigation Lifetime Representation: The data model MUST support representation
  of a mitigation request's lifetime, including mitigations with no specified
  end time.

DM-006:
: Mitigation Efficacy Representation: The data model MUST support representation
  of a DOTS client's understanding of the efficacy of a mitigation enabled
  through a mitigation request.

DM-007:
: Acceptable Signal Loss Representation: The data model MUST be able to
  represent the DOTS agent's preference for acceptable signal loss when
  establishing a signal channel, as described in GEN-002.

DM-008:
: Heartbeat Interval Representation: The data model MUST be able to represent
  the DOTS agent's preferred heartbeat interval, which the client may include
  when establishing the signal channel, as described in SIG-003.

DM-009:
: Relationship to Transport: The DOTS data model MUST NOT depend on the
  specifics of any transport to represent fields in the model.


Congestion Control Considerations       {#congestion-control-considerations}
=================================

Signal Channel
--------------

As part of a protocol expected to operate over links affected by DDoS attack
traffic, the DOTS signal channel MUST NOT contribute significantly to link
congestion. To meet the signal channel requirements above, DOTS signal channel
implementations SHOULD support connectionless transports. However, some
connectionless transports when deployed naively can be a source of network
congestion, as discussed in [RFC5405]. Signal channel implementations using such
connectionless transports, such as UDP, therefore MUST include a congestion
control mechanism.

Signal channel implementations using TCP may rely on built-in TCP congestion
control support.


Data Channel
------------
As specified in DATA-001, the data channel requires reliable, in-order message
delivery. Data channel implementations using TCP may rely on the TCP
implementation's built-in congestion control mechanisms.


Security Considerations         {#security-considerations}
=======================

DOTS is at risk from three primary attacks:

* DOTS agent impersonation

* Traffic injection

* Signaling blocking

The DOTS protocol MUST be designed for minimal data transfer to address the
blocking risk. Impersonation and traffic injection mitigation can be managed
through current secure communications best practices. See
{{security-requirements}} above for a detailed discussion.


Contributors
============

Mohamed Boucadair
: Orange
: mohamed.boucadair@orange.com
{: vspace="0"}

Flemming Andreasen
: Cisco Systems, Inc.
: fandreas@cisco.com
{: vspace="0"}

Dave Dolson
: Sandvine
: ddolson@sandvine.com
{: vspace="0"}


Acknowledgments
===============

Thanks to Roman Danyliw and Matt Richardson for careful reading and feedback.


Change Log
==========

04 revision
-----------

2017-03-13

* Establish required and optional mitigation scope types

* Specify message size for DOTS signal channel

* Recast mitigation lifetime as a DOTS server requirement

* Clarify DOTS server's responsibilities after client request to end mitigation

* Specify security state handling on redirection

* Signal channel should use transport not susceptible to HOL blocking

* Expanded list of DDoS types to include network links

03 revision
-----------

2016-10-30

* Extended SEC-003 to require secure interfaces within DOTS gateways.

* Changed DATA-003 to Resource Configuration, delegating control of acceptable
  signal loss, heartbeat intervals, and mitigation lifetime to DOTS client.

* Added data model requirements reflecting client control over the above.


02 revision
-----------

01 revision
-----------

2016-03-21

* Reconciled terminology with -00 revision of [I-D.ietf-dots-use-cases].

* Terminology clarification based on working group feedback.

* Moved security-related requirements to separate section.

* Made resilience/robustness primary general requirement to align with charter.

* Clarified support for unidirectional communication within the bidirectional
  signal channel.

* Added proposed operational requirement to support session redirection.

* Added proposed operational requirement to support conflict notification.

* Added proposed operational requirement to support mitigation lifetime in
  mitigation requests.

* Added proposed operational requirement to support mitigation efficacy
  reporting from DOTS clients.

* Added proposed operational requirement to cache lookups of all kinds.

* Added proposed operational requirement regarding NAT traversal.

* Removed redundant mutual authentication requirement from data channel
  requirements.

00 revision
-----------

2015-10-15


Initial revision
----------------

2015-09-24      Andrew Mortensen

--- back
