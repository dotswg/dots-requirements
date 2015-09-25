---
title: DDoS Open Threat Signaling Requirements
docname: draft-ietf-dots-requirements-00
date: 2015-09-17

area: Security
wg: DOTS Working Group
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
        street: n/a
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
  RFC1518:
  RFC1519:
  RFC4271:

--- abstract

This document defines the requirements for the DDoS Open Threat Signaling
(DOTS) protocols coordinating attack response against Distributed Denial of
Service (DDoS) attacks.

--- middle

Introduction            {#problems}
============

Overview
--------
Distributed Denial of Service (DDoS) attacks continue to plague networks
around the globe, from Tier-1 service providers on down to enterprises and
small businesses. Attack scale and frequency similarly have continued to
increase, thanks to software vulnerabilities leading to reflection and
amplification attacks. Once staggering attack traffic volume is now the norm,
and the impact of larger-scale attacks attract the attention of international
press agencies.

The higher profile and greater impact of contemporary DDoS attacks has led to
increased focus on coordinated attack response. Many institutions and
enterprises lack the resources or expertise to operate on-premise attack
prevention solutions themselves. To address that gap, security service
providers have begun to offer on-demand traffic scrubbing services. Each
service offers its own interface for subscribers to request attack mitigation,
tying subcribers to proprietary implementations while also limiting the subset
of network elements capable of participating in the attack response. As a
result of incompatibility across services, attack response may be fragmentary
or otherwise incomplete, leaving key players in the attack path unable to
assist in the defense.

There are many ways to respond to an ongoing DDoS attack, some of them better
than others, but the lack of a common method to coordinate a real-time response
across layers and network domains inhibits the speed and effectiveness of DDoS
attack mitigation.

DOTS was formed to address this lack. The DOTS protocols are therefore not
concerned with the form of response, but rather with communicating the need for
a response, supplementing the call for help with pertinent details about the
detected attack. To achieve this aim, the protocol must permit the DOTS client
to request or withdraw a request for coordinated mitigation; to set the scope
of mitigation, restricted to the client's network space; and to supply
summarized attack information and additional hints the DOTS server elements can
use to increase the accuracy and speed of the attack response.

As the DOTS charter makes clear, the protocol must also continue to operate
even in extreme network conditions. It must be resilient enough to ensure a
high probability of signal delivery in spite of high packet loss rates. As
such, elements should be in regular, bidirectional contact to measure peer
health, provide mitigation-related feedback, and allow for active mitigation
adjustments.

Lastly, the protocol must take care to ensure the confidentiality, integrity
and authenticity of messages passed between peers to prevent the protocol from
being repurposed to contribute to the very attacks it's meant to deflect.

Drawing on the DOTS use cases [I-D.ietf-dots-use-cases] for reference, this
document details the requirements for protocols achieving the DOTS goal of
standards-based open threat signaling.


Terminology     {#terminology}
-----------

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in {{RFC2119}}.

The following terms are used to define relationships between elements,
the data they exchange, and methods of communication among them:

attack telemetry:
: collected network traffic characteristics defining the nature of a DDoS
  attack.

mitigation:
: A defensive response against a detected and classified DDoS attack, performed
  by an entity in the network path between attack sources and the attack
  target, either through inline deployment or some form of traffic diversion.
  The form mitigation takes is out of scope for this document, but is often
  deployed in such a way that attack traffic is "scrubbed" from the data stream
  while allowing other traffic through. The term "attack response coordination"
  synonymous in this document.

mitigator:
: A network element or set of network element capable of performing mitigation
  of a detected and classified DDoS attack.

client:
: A DOTS-aware network element requesting attack response coordination with
  another DOTS-aware element, with the expectation that the remote endpoint is
  capable of helping fend off the attack against the client.

server:
: A DOTS-aware network element handling and responding to messages from a client.
  The server MAY enable mitigation on behalf of the client, if requested, by
  communicating the client's request to the mitigator and relaying any
  mitigator feedback to the client. A server MAY also be a mitigator.

signal channel:
: A bidirectional, mutually authenticated communication layer between client
  and server characterized by resilience even in conditions leading to severe
  packet loss, such as a volumetric DDoS attack causing network congestion.

beacon:
: A minimized, authenticated and combined status/control message between two
  DOTS-aware endpoints transmitted over the signal channel, crafted to
  contribute to the resilience of the signal channel.

client beacon:
: A beacon sent from a client to a server over the signal channel, indicating
  the client's need for mitigation, and the scope of any requested mitigation,
  optionally including detected attack telemetry to supplement server-initiated
  mitigation.

server beacon:
: A message sent from a server to a client over the signal channel. Note that
  a server beacon is not a response to client beacon, but a server-initiated
  status message sent to the client.

signal relay:
: A DOTS-aware network element acting as server and client. A signal relay
  receives client beacons and relays them to another server, and passes server
  beacons back to the client.

data channel:
: A secure communication layer between client and server used for infrequent
  bulk exchange of data not easily or appropriately communicated through the
  signal channel under attack conditions.


Requirements
============

This section describes the required features and characteristics of the DOTS
protocols. The requirements are aligned with, although not directly derived
from, the use cases described in [I-D.ietf-dots-use-cases].

DOTS must at a minimum make it possible for a client to request a server's aid
in mounting a coordinated defense against a detected attack, and client should
similarly be able to withdraw that request arbitrarily.  Regular feedback
between client and server supplement the defensive alliance by maintaining a
common understanding of DOTS peer health and activity. Bidirectional
communication between endpoints is critical

Yet the DOTS protocol must also work with a set of competing operational goals.
On the one hand, the protocol must be resilient under extremely hostile
network conditions, providing continued contact between endpoints even as
attack attack traffic saturates the link. Such resiliency may be developed
several ways, but characteristics such as small message size, asynchronous,
redundant message delivery and minimal connection state (when possible given
local network policy) with a given network will tend to contribute to
robustness called for in the DOTS charter.

On the other hand, DOTS must have adequate message confidentiality, integrity
and authenticity to keep the protocol from becoming another vector for the
very attacks it's meant to help fight off. The client must be authenticated to
the server, and vice versa, for DOTS to operate safely, meaning the endpoints
must have a way to negotiate and agree upon the terms of protocol security.

The server and client must also have some common method of defining the scope
of any mitigation performed by the mitigator, as well as making adjustments to
other commonly configurable features, such as listen ports.

Finally, DOTS should provide sufficient extensibility to meet local, vendor or
future needs in coordinated attack defense, although this consideration is
necessarily superseded by the other operational requirements.


General Requirements
--------------------

G-001
: Interoperability: DOTS's objective is to develop a standard mechanism for
  signaling detected ongoing DDoS attacks. That objective is unattainable
  without well-defined specifications for any protocols or data models emerging
  from DOTS. All protocols, data models and interfaces MUST be detailed enough
  to ensure interoperable implementations.

G-002
: Extensibility: Any protocols or data models developed as part of DOTS MUST be
  designed to support future extensions. Provided they do not undermine the
  interoperability and backward compatibility requirements, extensions are a
  critical part of keeping DOTS adaptable to changing operational and
  proprietary needs to keep pace with evolving DDoS attack methods.

G-003
: Resilience: The signaling protocol MUST be designed to maximize the
  probability of signal delivery even under the severely constrained network
  conditions imposed by the attack traffic. The protocol SHOULD be resilient---
  that is, continue operating despite message loss and out-of-order or
  redundant delivery, and without depending on transport retransmission---as
  opposed to reliable, as the additional round-trips incurred by reliable
  transmission will decrease beacon delivery likelihood over congested links.

G-004
: Bidirectionality: To support peer health detection, to maintain an open
  signal channel, and to increase the probability of beacon delivery during
  attack, the signal channel MUST be bidirectional, with client and server
  transmitting beacons to each other at regular intervals, regardless of any
  client request for mitigation.

G-004
: Limited Message Size: To avoid message fragmentation and the consequently
  decreased probability of message delivery, signaling protocol message size
  MUST be kept under signaling path Maximum Transmission Unit (MTU), including
  the byte overhead of any encapsulation, transport headers, and transport- or
  message-level security.

G-005
: Message Integrity: DOTS protocols MUST take steps to protect the
  confidentiality, integrity and authenticity of messages sent between client
  and server. While specific transport- and message-level security options are
  not specified, the protocols MUST follow current industry best practices for
  encryption and message authentication.

: In order for DOTS protocols to remain secure despite advancements in
  cryptanalysis, DOTS peers MUST be able to negotiate the terms and mechanisms
  of protocol security, subject to the interoperability and signal message size
  requirements above.

G-006
: Bulk Data Exchange: While the resilience requirement above demands a small
  message size, there are scenarios in which infrequent bulk data exchange
  between a DOTS client and server are valuable, for example
  \[Move to use cases? -AM]:

  * Population of black- or white-listed source addresses on the mitigator by
    the client, or similar configuration or hinting that will supplement attack
    response by the mitigator.

  * Client discovery of available server signaling endpoints, allowing the
    client to establish signal sessions with multiple servers for redundancy.

  * Address group aliasing, allowing the client and server to refer to
    arbitrarily-sized collections of client-controlled prefixes in beacons
    transmitted between the two.

  * Pre-shared keys for transport- or message-level security.

  * Exchange of managed incident or similarly organized reports. \[Too much
    overlap with MILE/RID? -AM]

: As the resilience requirements above mandate small signal message size, a
  separate, secure data channel SHOULD be used for bulk data exchange. The
  mechanism for bulk data exchange is not yet specified.

Operational requirements
------------------------

OP-001
: Use of Common Transports: DOTS MUST operate over common standardized
  transport protocols. While the protocol resilience requirement [G-NNN]
  strongly RECOMMENDS the use of connectionless protocols, in particular the
  User Datagram Protocol (UDP) {{RFC0768}}, use of a standardized,
  connection-oriented protocol like the Transmission Control Protocol (TCP)
  [RFC0793] MAY be necessary due to network policy or middleware limitations.

OP-002
: Peer Mutual Authentication: The client and server MUST authenticate each
  other before a DOTS session is considered active. The method of
  authentication is not specified, but should follow current industry best
  practices with respect to any cryptographic mechanisms to authenticate the
  remote peer.

OP-003
: Session Health Monitoring: The client and server MUST regularly send beacons
  to each other after mutual authentication in order to keep the DOTS session
  open. A session MUST be considered active until a client or server explicity
  end the session, or either endpoint fails to receive beacons from the other
  after a mutually negotiated timeout period has elapsed.

OP-004
: Mitigation Capability Opacity: DOTS is a threat signaling protocol. The
  server and mitigator MUST NOT make any assumption about the attack detection,
  classfication, or mitigation capabilities of the client. While the server and
  mitigator MAY take hints from any attack telemetry included in client
  beacons, the server and mitigator cannot depend on the client for
  authoritative attack classification. Similarly, the mitigator cannot assume
  the client can or will mitigate attack traffic on its own.

: The client likewise MUST NOT make any assumptions about the capabilities of
  the server or mitigator with respect to detection, classification, and
  mitigation of DDoS attacks. The form of any attack response undertaken by the
  mitigator is not in scope.

OP-005
: Mitigation Status: DOTS clients MUST be able to request or withdraw
  a request for mitigation from the server. The server MUST honor a client
  request to withdraw from coordinated attack response.

: A server MAY refuse to engage in coordinated attack response with a client.
  To make the status of a client's request clear, the server MUST indicate in
  server beacons whether client-initiated mitigation is active. When a
  client-initiated mitigation is active, and threat handling details such as
  mitigation scope and statistics are available to the server, the server
  SHOULD include those details in server beacons sent to the client.

OP-006
: Mitigation Scope: DOTS clients MUST also indicate the the desired address
  space coverage of any mitigation, for example by using Classless Internet
  Domain Routing (CIDR) [RFC1518],[RFC1519] prefixes, the length/prefix
  convention established in the Border Gateway Protocol (BGP) [RFC4271], or by
  a prefix group alias agreed upon with the server through the data channel. If
  additional information narrowing the scope of any requested attack response,
  such as targeted port range, protocol, or service, clients SHOULD include
  that information in client beacons.

: As an active attack evolves, clients MUST be able to adjust as necessary the
  scope of requested mitigation by refining the address space requiring
  intervention.


Data model requirements
-----------------------

TODO

Congestion Control Considerations
=================================

TODO

Security Considerations
=======================

TODO

Change Log
==========

Initial revision
----------------

2015-09-24

--- back
