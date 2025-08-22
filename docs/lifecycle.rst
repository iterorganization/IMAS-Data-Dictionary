=========================
Data Dictionary lifecycle
=========================

**Source**: this document is a shorter and updated version of the
initial report proposing the Data Dictionary Lifecycle rules, ITER IDM
reference QQYMUK v1.0, authors Olivier Sauter (CRPP), Basil Duval
(CRPP), Frédéric Imbeaux (CEA), Jo Lister (CRPP), dated 22/01/2014. This
shorter version has been provided by F. Imbeaux, July 2025.

Introduction and essential lifecycle principles
===============================================

The data dictionary (DD) will be at the core of most of the code
development related to the ITER Integrated Modelling Programme. Since ITER will span a
long time period, it needs to be able to evolve on a timescale
"consistent" with users' expectations in order to keep users' software
contributions active. At the same time, ITER involves many different
contributors and users, therefore data dictionary and software
infrastructure need to be stable. Flexibility and stability need to be
integrated into the lifecycle treatment of the data dictionary.

Various parts of the data dictionary need different weighting of the
flexibility and stability requirements: rapid developments of new parts
of the DD shared among a small number of persons should have high
flexibility and low stability requirements. Well established, widely
used parts of the DD should have high stability while still have the
possibility to evolve, with a strict procedure and a high level of
governance. Two different evolution procedures regulate these two
cases. The application domain of each procedure is defined unambiguously
as a function of a lifecycle_status property defined at the node level.

An even faster possibility for users needing to transfer or store a new
quantity is to use a generic container IDS, the “temporary” IDS, that has
been included in the DD since v2.0. It contains fixed fields for
various data types. It is immediately available to users, although its
fields do not have a fixed definition, so their usage has to be
agreed between restricted sets of users on a case-by-case basis.
Different users may of course use that IDS for different purposes / with
different definitions.

An important guiding rule which prevails is as follows: *do not loose
any information*.

Rules for Data Dictionary (DD) evolutions
=========================================

Evolutions of the DD are traced via 3 levels of revisions named
M_N.iiii.

- The M levels represent the major revisions for which backward
  compatibility is not guaranteed for some part of the “active” data
  model

- The N levels represent the minor revisions, those most relevant for
  the standard development of the “active” parts of the data model, for
  which a full backward compatibility is guaranteed within a given Major
  version (M level)

- The iiii levels should be fully transparent, only technical or related
  to nodes of the DD with alpha lifecycle_status (i.e., under
  development and not yet “active”) and are called micro-revisions.

Versioning is handled at the level of the full DD, for the sake of
simplicity, although a given revision may affect only a tiny part of the
DD.

Definition of a major revision (M 🡪 M+1)
----------------------------------------

**A major revision is defined as a removal, a restructuring, and/or a
redefinition of active/obsolescent nodes of the DD.**

A major release would be used to perform a cleansing of the data
dictionary or a major revision of structuring, and shall be exceptions
(a few over the ITER lifetime), since it breaks backward compatibility.

Definition of a minor revision (N 🡪 N+1)
----------------------------------------

**A minor revision is defined as the addition of new active nodes (with
new names) or active nodes becoming obsolescent.**

Minor revisions hence allow adding new nodes to the DD without removing,
restructuring or redifining any existing active/obsolescent node, which
guarantees the backward compatibility of the evolution. A node that is
"not useful anymore" and is likely to be removed in a future major
revision simply becomes “obsolescent”. A new node introduced in a minor
revision must have a new name (even obsolescent node names cannot be
reused) otherwise it becomes a redefinition of an existing
active/obsolescent node, i.e. a major revision.

To be more explicit, here is the full list of the modifications allowed
within a minor revision:

- you may add a new active node with a new name

- you may declare an active node obsolescent

- you may not remove an active or obsolescent node

- you may not redefine an active or obsolescent node

Breaking any of these leads to a major revision (M->M+1)

Lifecycle status
================

The data dictionary (DD) contains a lifecycle_status and a
lifecycle_version metadata for each node, indicating since which version
the node status has been last modified (received its present
lifecycle_status).

The lifecycle_status is defined as follows

- Active: the node is active and can be used.

- Obsolescent: the node might have relevant data, but this is not
  guaranteed, therefore one should not use it. Obsolescent also means
  "to become obsolete", that is it could be removed in a subsequent
  major revision. If there is a replacement for this node, i.e. a new
  node that can be obtained from a simple expression using the
  obsolescent node (and vice-versa), the replacement expression has to
  be documented as a metadata in the data dictionary (as an appinfo on
  the obsolescent node AND on the replacement node).

- Alpha: the nodes are under development. These nodes are, like the
  others, opened to all users but this lifecycle status indicates that
  they could still undergo rapid and non-backward compatible changes.
  The microrevision number will be used to version the alpha nodes
  modifications.

Obsolete nodes, i.e. non-existent anymore, can only appear in the
documentation of a major revision.

To ease the development of the data dictionary, in view of avoiding
coding the lifecycle_status and \_version information for each node, we
introduce the following rules concerning the inheritance of the
lifecycle_status and lifecycle_version from the parents:

- All descendents of a node with “alpha”, or “obsolescent” status
  inherit from the status of that node

- A child of a node with “active” status inherits from the status of its
  parent, unless explicitly marked otherwise

These inheritance rules are useful in particular for the generic
substructures defined in “utilities”, which may have instances with
different lifecycle_status in various parts of the data dictionary.

The table below summarizes the full lifecycle of DD elements, starting
with an alpha lifecycle status and which may evolve between the various
statuses from leftmost to rightmost, with transition conditions.

+----------------------+------------------+------------------+------------------+
| **Lifecycle_status** | alpha            | Active           | obsolescent      |
+======================+==================+==================+==================+
| **Modifications      | Any.             | Follow Minor or  | Deletion         |
| allowed**            | Modifications    | Major revision   | (documented as a |
|                      | increment the    | rules/procedures | major revision)  |
|                      | micro-revision   | and increment    |                  |
|                      | index.           | the appriopriate |                  |
|                      |                  | version index.   |                  |
|                      |                  | Technical        |                  |
|                      |                  | micro-revisions  |                  |
|                      |                  | are also         |                  |
|                      |                  | allowed.         |                  |
+----------------------+------------------+------------------+------------------+
| **Transition to next | When the         | When the         | When the         |
| lifecycle status**   | designers of the | governance       | governance       |
|                      | DD modification  | decides that     | decides that     |
|                      | think it is      | this part of the | this part of the |
|                      | mature enough to | DD is not useful | DD has become    |
|                      | enter rigorously | or adequate      | fully useless    |
|                      | the minor/major  | anymore          | and will never   |
|                      | revision         |                  | be used anymore. |
|                      | lifecycle.       | Transition to    |                  |
|                      |                  | “obsolescent”    | Deletion         |
|                      | The transition   | status           | increments the   |
|                      | to the active    | increments the   | major revision   |
|                      | status           | minor revision   | index.           |
|                      | increments the   | index.           |                  |
|                      | minor revision   |                  |                  |
|                      | index (addition  |                  |                  |
|                      | of new active    |                  |                  |
|                      | nodes)           |                  |                  |
+----------------------+------------------+------------------+------------------+
