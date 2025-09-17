IMAS Access-Layer URI Scheme Documentation
==========================================

- Version: 0.4
- Date: 4 April 2024


Introduction
------------

An IMAS URI is used to identify without ambiguity a given IMAS `data-entry <./dataentry_and_occurrence.html#data-entry>`_, or part of its data (see the Fragment_ section). 
The URI scheme follows a specific syntax, but is encoded into a single string in order to allow a very simple API in associated data-access
software. It also allows to further extend the capabilities by refining the scheme syntax without any impact on the API.
The following section describes the chosen URI scheme in details. A reminder of historical `data-entry <./dataentry_and_occurrence.html#data-entry>`_ identification can be found in the 
`Legacy identifiers`_ section, with explanation of the associated limitations that this URI scheme addresses.


IMAS URI structure
------------------

The IMAS `data-entry <./dataentry_and_occurrence.html#data-entry>`_ URI follows the general idea from URI standard definition from `RFC-3986 <https://www.rfc-editor.org/rfc/rfc3986.html>`_,
but does not aim at being publicly registered. For reference, the general URI structure is the following: ``scheme:[//authority]path[?query][#fragment]``.

For the sake of clarity and coherence, it was decided to define a single unified ``scheme`` for IMAS data resources (named ``imas``)
instead of defining different scheme for each backend. This implies that the backend needs to be specified in another manner.
We opt for using the ``path`` part of the URI to specify the backend.

As a result, the structure of the IMAS URI is the following, with elements between square brackets being optional:

**imas:[//host/]backend?query[#fragment]**

Some valid syntax examples:

- ``imas:mdsplus?pulse=123;run=2;user=public;database=ITER;version=3``
- ``imas:hdf5?path=/home/username/runfolder``
- ``imas:ascii?path=./debug``

Each part of the URI are described in more details in the following subsections.


Scheme
~~~~~~

For consistency, the scheme is simply named ``imas`` and followed by ``:`` that separates the scheme from the next parts 
(either the ``host`` or the ``backend``).


Host
~~~~

The host (which takes place of the authority in general URI syntax) allows to specify the address 
of the server on which the data is located (or accessed through). The ``host`` starts with a double slash ``//`` (similarily 
to the standard authority it is contextually replacing) and ends with a single slash ``/`` (which is a difference with 
the authority syntax, as it is missing otherwise a delimiter with the next contextual element since ``backend`` replaces ``path``).

The structure of the ``host`` is **//[user@]server[:port]/**, where:

- **user** is the username which will be recognized on the server to authenticate the submitter to this request. 
  This information is optional, for instance for if the authentication is done by other means (e.g. using PKI certificates in the 
  case of UDA) or if the data server does not require authentication;
- **server** is the address of the server (typically the fully qualified domain name or the IP of the server);
- **port** is optional and can be used to specify a port number onto which sending the requests to the server.

When the data is stored locally, the ``host`` (localhost) is omitted. 

Example: A ``host`` would typically be the address of a UDA server with which the UDA backend of the Access-Layer
will send requests for data over the netwrok. A URI would then look like: ``imas://uda.iter.org/uda?...``.


Backend
~~~~~~~

The ``backend`` is the name of the Access-Layer backend used to retrieve the stored data, this name is given in lower case and is mandatory.
Current possibilities are: ``mdsplus``, ``hdf5``, ``ascii``, ``memory`` and ``uda``. Be aware that some backends may not be available in a given install of the Access-Layer.


Query
~~~~~

A ``query`` is mandatory. It starts with ``?`` and is composed of a list of semi-colon ``;`` (or ampersand ``&``) separated ``key=value`` pairs. The following keys are standard and recognized by all backends:

- ``path``: absolute path on the localhost where the data is stored (e.g. ``path=/project/run`` or ``path=./localrun``);
- ``pulse``, ``run``, ``user``, ``database``, ``version``: allowed for compatibility with historical `data-entry <./dataentry_and_occurrence.html#data-entry>`_ identifiers (e.g. ``pulse=123;run=2;user=me;database=test;version=3``).

.. note:: If `Legacy identifiers`_ are provided, they are always transformed into a standard ``path`` before the query is passed to the backend.

Other keys may exist, both optional and mandatory for a given backend. Please refer to the latest documentation of the Access-Layer for more information on backend-specific keys.


Fragment
~~~~~~~~

In order to identify a subset from a given `data-entry <./dataentry_and_occurrence.html#data-entry>`_, a ``fragment`` can be added to the URI. 
Such a ``fragment``, which starts with a hash ``#``, is optional and allows to identify a specific IDS, or a part of an IDS.

The structure of the fragment is **#idsname[:occurrence][/idspath]**, where:

- **idsname** is the type name of the IDS, given in lower case, is mandatory in fragments and comes directly after the ``#`` delimiter;
- **occurrence** is the `occurrence <./dataentry_and_occurrence.html#occurrence>`_ of the IDS (refer to the `Access-Layer User Guide <https://user.iter.org/?uid=YSQENW&action=get_document>`_ for more information), is optional and comes after a colon ``:`` delimiter that links the occurrence to the IDS specified before the delimiter;
- **idspath** is the path from IDS root to the IDS subset that needs to be identified, and is optional (in such case the fragment identifies the entire IDS structure). Refer to the `IDS path syntax <IDS-path-syntax.html>`_ document for more information.


Legacy identifiers
------------------

Historically, identification of IMAS data-entries (also referred to as *data source* or simply *resource* in this document) 
with the Access-Layer is defined by 5 arguments:

- **shot** (int)
- **run** (int)
- **user** (string)
- **database** (string)
- **version** (string)

When more storage backends have been implemented in the Access-Layer v4, the **backendID** (int) was added to the list.
This fixed list imposed some limitations (ranges of ``shot`` and ``run``) and required implicit rules to convert them into 
a standardized path on the system. It also lacked the flexibility asked for by developers (e.g capability to store data 
in non-standard paths had to be added by *hacking* the interpretation of the ``user`` argument with additional rules to
cover cases where an absolute path was given). In addition, ``pulse`` was introduced since Access-Layer v5 as an optional 
replacement for ``shot``.

To address some of these limitations and improve the flexibility and generality of the identification of IMAS data resources, 
a proposal (initially discussed in `IMAS-1281 <https://jira.iter.org/browse/IMAS-1281>`_) was made to introduce a new API taking 
a URI as argument, which led to the syntax described in this document.
