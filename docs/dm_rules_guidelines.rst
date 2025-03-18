.. highlight:: xml

.. _`dm_rules_guidelines`:

====================================================
Rules and Guidelines for the ITER Physics Data Model
====================================================

Documentation maintained by F. Imbeaux (CEA)


Preamble
========

In order to interpret this page without reference to other IMAS Data
Model documents, a number of notions and definitions are required, which
we reproduce here. These form part of the Rules and Guidelines.

a. The organisation of ITER physics data model comprises two principal
   components:

   1. The Data Dictionary, defining the structuring and naming of data which are
      being moved between analysis components or being stored or recovered
   2. The mapping of the Data Dictionary onto storage of the data;

   This page only discusses the structuring of data in the Data Dictionary.

b. The Data Dictionary Rules and Guidelines have been designed in order
   to fulfill the following aims:

   1. Satisfy two very different Use Cases: Integrated Modelling workflows and
      hands-on data browsing by the physicist
   2. Have identical data structures for experimental and simulated data

c. The ITER physics data are structured as trees to allow re-use of
   names, reference to sub-trees at any level of nesting, and targeted
   data recovery.

d. Within the context of a tree structure, we define the following:

   -  A `node` is any element of a tree
   -  A `leaf` is a node which is an end-point of a tree
   -  A `parent` is one level above a particular node
   -  A `sibling` is a node at the same level as a given node
   -  A `child` is one level below a particular node

e. We assume that a powerful feature of the Data Dictionary will be the
   automated definition of the data structures for all supported
   languages

f. We have avoided, where reasonable, notions which stem from a
   particular technology; however this choice might lead to tortuous
   implementation once a technology is selected; the strongest case of
   this is the avoidance of "properties" of which the implementation
   varies considerably between XML, HDF5, MDSplus and so on

g. We have avoided choices which have been found to create problems in
   particular languages; certain names have to be avoided

h. An Interface Data Structure (IDS) is an entry point of the Data
   Dictionary that can be used as a single entity to be used by a user;
   examples are the full description of a tokamak subsystem (diagnostic,
   heating system, ...) or an abstract physical concept (equilibrium, set
   of core plasma profiles, wave propagation, ...); this concept allows
   tracing of data provenance and allows simple transfer of large
   numbers of variables between loosely or tightly coupled applications;
   the IDS thereby define standardized interface points between IMAS
   physics components.

   An IDS is a part of the Data Dictionary, like an entry point into it, thus
   the IMAS components are interfaced with the same structures as those
   constituting the Data Dictionary. An IDS is marked by having a child
   ``ids_properties`` node, containing traceability and self-description
   information. Nested IDS can be foreseen but should have a clear usefulness
   for interfacing components in a workflow.

i. We make a distinction between categories of data according to their
   time-variation; ``constant`` data are data which are not varying within
   the context of the data being referred to (e.g. pulse, simulation,
   calculation); ``static`` data are likely to be constant over a wider
   range (e.g. nominal coil positions during operation); ``dynamic`` data
   are those which vary in time within the context of the data.

j. An IDS may contain quantities with different timebases, essentially
   to have the ability to describe experimental data as it is acquired
   in the experiment. However, an IDS can also be filled in a
   synchronous way (i.e. all time-dependent quantities are stored on a
   unique timebase) and declared so, since this will likely be a
   frequent usage in IMAS workflows.

k. The quantities describing the N coordinates of an N-dimensional array
   are called the coordinates of the array.


Rules and guidelines
====================

This section presents the current Rules and Guidelines. They have been
revisited according to the evolution of the thinking on the ITER Physics
Data Model. These Rules and Guidelines are structured by topics (Naming
Conventions, Reserved node names, Structuring Conventions, Documentation
Conventations, Self-Description Conventions, Technical Constraints). The
first four topics are of interest to both the Data Model designer and
the XML developer who will implement them. The last two topics are of
interest only for the XML developer of the Data Model, since they do not
impact the Data Model design.


Naming Conventions
------------------

.. list-table::
   :header-rows: 1

   *  -  ID
      -  Rule
      -  Motivation
      -  Date of last modification

   *  -  R1.1
      -  Node names shall be composed of ``a-z``, ``0-9`` and underscore
         (``_``); Consecutive underscores are not allowed.
      -  Avoidance of characters which might generate language or parsing
         difficulties; Readability.
      -  28 May 2013

   *  -  R1.2
      -  Node names shall only begin with ``a-z``.
      -  Avoidance of conflict in some languages; assistance to the interpreter
         to separate variables from numbers.
      -  29 March 2012

   *  -  R1.3
      -  Names shall be semantically meaningful and not depend on familiarity
         with a specific implementation; the use of acronyms, abbreviations,
         prefixes and suffixes shall be restricted to a uniform and recognized
         set defined in this document, sections :ref:`Recognized Acronyms` and
         :ref:`Recognized Abbreviations, prefixes and suffixes`.
      -  This is mandatory given the international nature of ITER; Acronyms and
         abbreviations vary considerably between institutions.
      -  10 May 2013

   *  -  R1.4
      -  Forbidden names defined in this document (section :ref:`Forbidden
         names`) shall not be used for Data Dictionary nodes.
      -  Reserved names create problems when generating code or declarative
         statements in some programming languages.
      -  29 March 2012

   *  -  R1.5
      -  Naming of the Data Dictionary shall be lower case, with underscores
         used for semantic separation for human reading clarity. The only
         exception being the namings of the units (Wb, eV, A, ...).
      -  Avoidance of confusion and allows straightforward usage in
         case-sensitive languages. We recommend the names of
         routines/modules/tools related to the datamodel to be lower case as
         well, to ease maintenance and usage (``get_ids``, ``put_ids``,
         ``get_equilibrium``, ``plot_pf_coils``, etc).
      -  10 May 2013

   *  -  R1.6
      -  Node names shall not repeat the context of their parent identities
         where this would be redundant, unless it allows avoiding a conflict
         with a forbidden name (see R1.4).
      -  Provides clarity and brevity
      -  29 March 2012

   *  -  R1.7
      -  Qualifiers should be suffixes, not prefixes (e.g. ``energy_min``, not
         ``min_energy``).
      -  Qualified names will appear grouped when sorted. This rule must be
         applied in a way that facilitates finding a quantity in the data
         dictionary.
      -  29 March 2012

   *  -  R1.8
      -  If a node is an array of structures, its name shall be singular.
      -  This aids clarity. Plurals should only be used if node is a leaf or a
         structure describing multiple instances.
      -  5 June 2013

   *  -  R1.9
      -  Nodes storing the same data but in different IDSs shall have the same
         name.
      -  Homogeneity of the data dictionary.
      -  2 October 2016


.. list-table::
   :header-rows: 1

   *  -  ID
      -  Guideline
      -  Motivation
      -  Date of last modification

   *  -  G1.1
      -  Long clear names are strongly preferred to short ambiguous or unclear
         names.
      -  The cost of confusion is far higher than the cost of a few characters.
      -  29 March 2012

   *  -  G1.2
      -  Time-dependent additive corrections to static data must be named with a
         ``delta_*`` prefix, the star denoting the name of the static quantity
         to which the correction must be added.
      -  For some applications, a higher precision for static data is needed
         which requires applying corrections. This applies to all geometrical
         data. ITER changes size slightly during the burn and more during baking
         etc.
      -  19 August 2017


Reserved node names
-------------------

The following node names are reserved for a specific usage as defined
below.

.. list-table::
   :header-rows: 1

   *  -  ID
      -  Rule
      -  Motivation
      -  Date of last modification

   *  -  R2.1
      -  ``time`` is reserved for any node name corresponding to a time or a
         timebase.

         As a consequence, different timebases cannot be placed at the same
         level in the tree structure.

         A timebase is dynamic and has a coordinate "1...N".
      -  User needs to find unambiguously the time vector relevant to a
         time-dependent quantity.
      -  29 August 2013

   *  -  R2.2
      -  ``ids_properties`` is reserved for any node name corresponding to the
         presence of an interface data structure.
      -  Self-description of an instance of an IDS.
      -  10 May 2013

   *  -  R2.3
      -  ``code`` is the reserved node name for the sub-structure describing the
         code and its code-specific parameters that has produced and IDS.
      -  Traceability of the code and its parameters that has produced an IDS
      -  3 July 2013

   *  -  R2.4
      -  ``plasma_composition`` is the reserved node name for the sub-structure
         describing the plasma composition for a simulation.
      -  Homogeneity of the data dictionary.
      -  3 July 2013


Structuring Conventions
-----------------------

.. list-table::
   :header-rows: 1

   *  -  ID
      -  Rule
      -  Motivation
      -  Date of last modification

   *  -  R3.1
      -  Each IDS node must have an ``ids_properties`` node and a ``code`` node.

         Each IDS node must have a ``time`` node, unless it contains no
         ``dynamic`` signals.
      -  ``ids_properties`` is a standard structure allowing self-description of
         the IDS.

         ``code`` is a standard structure for describing the code that has
         produced the IDS and its parameters.

         ``time`` is a reserved node name, see R2.1.
      -  29 August 2013

   *  -  R3.2
      -  Nodes have either children or data, not both.
      -  To have data-free nodes and data only in leaves. No need to have more
         complex options.
      -  29 March 2012

   *  -  R3.3
      -  Arrays of structures shall be used to group quantities that describe
         the same object/concept but possibly of different sizes.
      -  Arrays of structures allow the Data Dictionary to be flexible enough
         and avoid the creation of large sparse arrays.
      -  28 May 2013

   *  -  R3.4
      -  The coordinates of a quantity must exist in the same IDS as this
         quantity.
      -  Guarantee a consistent link between a quantity and its coordinates
         which is available when an IDS is used on its own.

         In case of nested IDS, the coordinates must be at least in the lowest
         level IDS.
      -  30 May 2013

   *  -  R3.5
      -  A child node cannot have the same name as its parent.
      -  A child node with the same name as its parent is confusing, moreover it
         is not possible to declare such a structure in Java.
      -  29 March 2012

   *  -  R3.6
      -  For time-dependent quantities, the time index shall be the last index
         of the array.
      -  Contributes to homogeneity in the data model. NB: the CODAC convention
         on this has not been decided.
      -  Guideline moved as a Rule. 4 June 2013

   *  -  R3.7
      -  There should not be explicit nodes for indicating the size of a data
         item.

         However, in the expectedly rare case of an oversized array, an explicit
         node is required to document the rank of useful information for a given
         index.
      -  This information is part of the metadata and can be retrieved from e.g.
         a PUAL "shape_of" instruction (or alternatively, a "get" instruction of
         the PUAL automatically allocates the returned variables to the correct
         size).
      -   Guideline moved as a Rule. 4 June 2013

   *  -  R3.8
      -  Use generic sub-structures for data of the same nature when available.
         If not available, they must be created.
      -  Contributes to homogeneity in the data model.
      -  Guideline moved as a Rule. 3 July 2013

   *  -  R3.9
      -  Physical quantities that require only quantities from a single IDS to
         be computed must belong to this IDS.
      -  Aid provenance traceability by grouping consistent quantities in the
         same IDS.

         Example: the plasma current as estimated by the magnetics belongs to
         the ``magnetics`` IDS.
      -  20 September 2013


.. list-table::
   :header-rows: 1

   *  -  ID
      -  Guideline
      -  Motivation
      -  Date of last modification

   *  -  G3.1
      -  Data model structures should be designed from the usage point of view.
      -  It is easy to create an apparently logical structure which becomes
         unwieldy during use.
      -  30 May 2013

   *  -  G3.2
      -  Avoid as much as possible any ITER-specific definitions or features in
         the data model.
      -  Maximise maintainability, generality and durability and allow using
         IMAS for other experiments.
      -  30 May 2013

   *  -  G3.3
      -  Group quantities depending on the same coordinates at the same level.
      -  Clarity.
      -  4 June 2013

   *  -  G3.4
      -  The coordinates of a quantity should be siblings of the highest level
         nodes using these coordinates.

         However, if the coordinate is the index of an array of structures, the
         coordinate should be an immediate child of the array of structures.
      -  Group quantities and their coordinates for clarity.

         An array of structures usually describes an object and it is logical to
         make the coordinate a property of the object.

         Note: the homogeneous timebase of an IDS is placed within
         ``ids_properties`` as it is a direct property of the IDS.
      -  4 June 2013

   *  -  G3.5
      -  When multiple quantities have a common coordinate, define a single node
         for this common coordinate.

         Define multiple coordinate nodes otherwise.
      -  Reduces complexity and enhance access performance.
      -  4 June 2013

   *  -  G3.6
      -  When multiple quantities have a common coordinate, choose on a case by
         case basis the most suitable structuring.

         .. code-block:: text
            :caption: Array of structures

            structure_array(n)/leaf_a
                              /leaf_b(:)
                              /leaf_m(:,:)

         .. code-block:: text
            :caption: Dimensional leaf structure

            structure/leaf_a(n)
                     /leaf_b(:,n) or leaf_b(n,:)
                     /leaf_m(:,:,n) or leaf_m(n,:,:)
      -  Rule 3.3 defines a case where using an array of structures is
         mandatory.

         When the leaves are commonly used separately and *n* is large, the
         latter structure is a better choice for performance, since it allows
         separate access to a given leaf and avoids having to retrieve a large
         size object with all leaves beneath.
      -  4 June 2013

   *  -  G3.7
      -  When there are multiple methods for generating a set of physical
         quantities within an IDS (typically for the processing of
         measurements):

         Use different IDS occurences when most of the IDS quantities depend on
         the generation method.

         Group the generated quantities under a ``method`` array of structure
         when most of the IDS quantities are independent on the generation
         method.
      -  Example: the core_profile IDS contains only data generated by a given
         processing method (e.g. profile fitting): multiple generations of a set
         of core_profiles are stored using multiple IDS occurrences.

         Avoids replicating common quantities in different places.
      -  20 September 2013


Documentation Conventions
-------------------------

.. list-table::
   :header-rows: 1

   *  -  ID
      -  Rule
      -  Motivation
      -  Date of last modification

   *  -  R4.1
      -  The documentation field of the data dictionary shall contain a
         complete, self-contained, English language description of the data item
         content, avoiding jargon and unofficial abbreviations.
      -  Self-description of the Data Dictionary.

         The data model should not be separated from its documentations source.
      -  30 May 2013

   *  -  R4.2
      -  The documentation field of the data dictionary shall not duplicate the
         information contained in some other field of the data dictionary.
      -  Avoid duplication of information and risks of errors.
      -  4 June 2013


.. _`Self-description Conventions`:

Self-description Conventions
-----------------------------

In this section, the XML syntax indications are provided for the persons
in charge of coding the Data Dictionary directly in XML. It has been
shown that this is not a requirement for Data Dictionary contributors,
who can also develop the Data Dictionary in other formats, e.g. an Excel
spreadsheet. Nonetheless the information listed below has to be provided
by the Data Dictionary contributor to be then implemented by the XML
developer.

.. list-table::
   :header-rows: 1

   *  -  ID
      -  Rule
      -  Motivation
      -  Date of last modification

   *  -  R5.1
      -  The data type of an element must be coded by including an XML Group of
         the corresponding type to the element. The syntax is:

         .. code-block:: xml

            <xs:complexType>
               <xs:group ref="flt_1d"/>
            </xs:complexType>

      -  Self-description of the Data Dictionary to allow the creation of the
         structures in declarative languages.

         A list of the existing data types is provided section :ref:`List of
         the existing data types`.
      -  10 May 2013

   *  -  R5.2
      -  The static/constant/dynamic character of a data item must be coded in
         the Data Dictionary under the ``<appinfo>`` metadata, as:

         .. code-block:: xml

            <type>static|dynamic|constant</type>

         -  ``static`` refers to a value which is a property of the device and is
            expected to be constant over many pulses or simulations.
         -  ``constant`` refers to a data item which is constant within a pulse,
            but may be different from pulse/simulation to pulse/simulation.
         -  ``dynamic`` refers to a data item which is considered to be varying
            within a pulse or simulation.

      -  Self-description of the Data Dictionary.
      -  10 May 2013

   *  -  R5.3
      -  Float and Complex data items shall have their units defined. If the
         quantity is dimensionless, the units shall be ``1``. if the quantity has
         mixed units, then the units shall be ``mixed``.

         If the quantity is implemented via a generic structure with its
         definition and units given by its parent node, its units shall be
         ``as_parent``. If the units are given by the grand-parent, its units
         shall be ``as_parent_level_2``, etc.

         The units of a quantity shall be self-described in the Data Dictionary
         under the XML ``<appinfo>`` metadata using the SI system plus ``eV``,
         ``rad`` for angles, UTC for absolute time, days /weeks / months / years
         for durations. Units shall follow the `UDUNITS2
         <https://docs.unidata.ucar.edu/udunits/current/>`__ convention.

         The XML syntax for units is :code:`<units>Wb</units>`.
         
         The units use the standard names with both lower and upper cases for
         clarity.
         
         The "/" operator shall not be used in the units, always use "."
         operator and a negative exponent for units at the denominator.
         Exponents greater than 1 are indicated with the "^" character.
      -  Self-description of the Data Dictionary; conformity with ITER Project
         Requirements.

         Example: the mhd_linear IDS describes a perturbed vector quantity as a
         parent node having the definition and units of the quantity with three
         coordinates as children (e.g. a_perturbed/coordinate1). The coordinates
         have units "as_parent".

         Style convention. Example: ``A.m^-2`` for Ampere per square meter.
      -  2 October 2023

   *  -  R5.4
      -  The coordinate properties of a quantity shall be self-described in the
         Data Dictionary under the ``<appinfo>`` metadata.

         The syntax of the coordinate list is :code:`<coordinateN>Path to the
         element</coordinateN>`.

         The Path to the element shall use UNIX syntax. ``xxx`` is a child seen
         from a node, ``../yyy`` is a sibling seen from a node.
         
         A coordinate which is simply a set of indices is marked as ``1...N``
         with no significance of the value N other than being the number of
         items in this specific dimension of this specific node. If N is the
         same as the one of another nodes, a specific tag specifies it with
         :code:`<coordinateN_same_as>Path to the element</coordinateN_same_as>`.

         If the coordinate can be different elements, it is noted as:
         :code:`<coordinateN>Path to the fist element OR Path to the second
         element OR ...</coordinateN>`.

         In the exceptional case of a quantity with a coordinate residing in
         another IDS the coordinate must be specified as
         ``IDS:{IDS_name}/{path}`` (relative to the top of the other IDS).
      -  Self-description of the Data Dictionary.
      -  22 July 2015


Limitations of the present implementation
=========================================

These limitations on the Data Dictionary structure arise from the
present implementation and do not represent Rules or Guidelines.

.. list-table::
   :header-rows: 1

   *  -  ID
      -  Limitation
      -  Comment

   *  -  L1
      -  Nested IDS are not implemented yet.
      -  The case of nested IDS has not been implemented yet but in principle
         could be implemented with no major difficulty.

   *  -  L2
      -  The timebase of a node must be located within the same array of
         structure as the node, or be reachable from the root of the IDS without
         going through an array of structure.

         This limitation doesn't exist within a dynamic array of structure, in
         which all nodes share the same time base.
      -  The New Low Level (2018) logic is based on "contexts" which start at
         the level of the nearest array of structure ancestor. Note that this
         limitation is much lighter than the one which existed with the previous
         implementation of the Access Layer (forcing the systematic use of
         data/time structures).

   *  -  L3
      -  The "series of bytes" datatypes (see section :ref:`List of the
         existing data types`) are defined in the Data Dictionary but are not
         implemented in the Access Layer.
      -  The Access Layer shall be extended to handle these data types.

Remaining issues
================

.. list-table::
   :header-rows: 1

   *  -  ID
      -  Issue
      -  Motivation

   *  -  I1
      -  Design a mechanism for storing expressions instead of values and an
         expression evaluator.
      -  Very important functionality. Saves storage and bandwidth. Would allow
         changing and facilitating the timebase implementation.

   *  -  I2
      -  Implement a referencing system for the static data.
      -  This avoids copying the static data.

   *  -  I3
      -  Implement an optional "topic" metadata. A new documentation Rule will
         be needed for its usage.
      -  Allow searching for all quantities belonging to a given topic (e.g.
         electron temperature).

   *  -  I4
      -  Implement a way of documenting the method to be used to interpolate a
         quantity. 
      -  Document how to use data.

   *  -  I5
      -  Discuss the precision desired for the data types and how to implement
         them in the various programming languages.
      -  Make assumptions on precision explicit.


.. _`Recognized Acronyms`:

Recognized Acronyms
===================

The project acronym base list will be provided by IO.

The following acronyms have been used outside the basis list of project
acronyms, and are proposed for adoption by IO POP.

.. list-table::
   :header-rows: 1

   *  -  Acronym
      -  Definition and comment

   *  -  API
      -  Application Programming Interface

   *  -  CBS
      -  CODAC Breakdown Structure, the division by CODAC of their equipment,
         using an EPICS conforming non-semantic naming convention

   *  -  DD
      -  Data Dictionary

   *  -  DM
      -  Data Model

   *  -  IDS
      -  Interface Data Structure. Defines the point at which a node and its
         children can be used in a workflow.

   *  -  PAPI
      -  Physics Application Programmer Interface

   *  -  PF
      -  Poloidal Field, as in Poloidal Field system, includes all
         coordinateymmetric components, such as PF Coils, CS coils, VS coils.

   *  -  PUAL
      -  Physics User Access Layer, unique access to the the Physics Data Model


.. _`Recognized Abbreviations, prefixes and suffixes`:

Recognized Abbreviations, prefixes and suffixes
===============================================

Abbrevations
------------

.. list-table::
   :header-rows: 1

   *  -  Abbreviation
      -  Example
      -  Definition and comment

   *  -  ``dy_dx``
      -  ``drho_tor_dt``
      -  Derivative of y with respect to quantity x. In this context only, t
         refers to time. In the definition text of the node, first derative is
         assumed unless explicitly stated.

         If the node is a structure (parent of other nodes), containing as
         children the derivatives of various quantities, y is omitted (e.g.
         ``d_dx/temperature``).

   *  -  ``dy_dx_cz``
      -  ``dpsi_dt_cphi``
      -  Derivative of y with respect to quantity x at constant z. In this
         context only, t refers to time. 

   *  -  ``d2y_dx2``
      -  ``d2value_drho_tor2``
      -  Second order derivative of y with respect to quantity x. In this
         context only, t refers to time. 

   *  -  ``e_field``
      -  
      -  Electric field

   *  -  ``b_field``
      -  
      -  Magnetic field

   *  -  ``a_field``
      -  
      -  Electromagnetic vector potential

   *  -  ``q``
      -  
      -  Safety Factor

   *  -  ``zeff``
      -  
      -  Effective charge of the plasma

   *  -  ``ip``
      -  
      -  Plasma current

   *  -  ``li1``, ``li2``, ``li3``
      -  
      -  Plasma Internal Inductance

   *  -  ``r``
      -  
      -  Major radius (see exact definition in `ITER_D_2F5MKL
         <https://user.iter.org/?uid=2F5MKL&action=get_document>`__)

   *  -  ``z``
      -  
      -  Height in the machine coordinates (see exact definition in
         `ITER_D_2F5MKL
         <https://user.iter.org/?uid=2F5MKL&action=get_document>`__)

   *  -  ``phi``
      -  
      -  When used in conjunction with ``r`` and ``z`` above, toroidal angle,
         anti-clockwise as seen from above (see exact definition in
         `ITER_D_2F5MKL
         <https://user.iter.org/?uid=2F5MKL&action=get_document>`__)

         Toroidal flux otherwise

   *  -  ``theta``
      -  
      -  Poloidal angle

   *  -  ``phi_potential``
      -  
      -  Electrostatic potential

   *  -  ``psi``
      -  
      -  Poloidal flux

   *  -  ``psi_potential``
      -  
      -  Electromagnetic super potential related to an MHD mode, see ref
         [Antonsen/Lane Phys Fluids 23(6) 1980, formula 34], so that
         ``A_field_parallel=1/(i*2pi*frequency) (grad psi_potential)_parallel``

   *  -  ``dim1``, ``dim2``, ..., ``dimn``
      -  
      -  Coordinates of N-Dimensional grids (from leftmost to rightmost)

   *  -  ``pf``
      -  
      -  Poloidal Field

   *  -  ``tf``
      -  
      -  Toroidal Field

   *  -  ``rad``
      -  
      -  radian, used as units

   *  -  ``UTC``
      -  
      -  UTC time, a string to give absolute time

   *  -  ``ec``
      -  
      -  Electron cyclotron (heating and current drive)

   *  -  ``ece``
      -  
      -  Electron cyclotron emission

   *  -  ``ic``
      -  
      -  Ion cyclotron (heating and current drive)

   *  -  ``lh``
      -  
      -  Lower hybrid (heating and current drive)

   *  -  ``m_pol``
      -  
      -  Poloidal mode number

   *  -  ``n_phi``
      -  
      -  Toroidal mode number

   *  -  ``mhd``
      -  
      -  Magnetohydrodynamic

   *  -  ``ntm``
      -  
      -  Neoclassical Tearing Mode

   *  -  ``ntv``
      -  
      -  Neoclassical toroidal viscosity

   *  -  ``nbi``
      -  
      -  Neutral beam injection

   *  -  ``a``
      -  
      -  Atomic mass

   *  -  ``z_n``
      -  
      -  Nuclear charge

   *  -  ``[*_]exb[_*]``
      -  
      -  Related to the vector product between electric and magnetic fields
         (:math:`E\times B`), can be used between underscores at any place in
         the node name.

   *  -  ``ggd``
      -  
      -  General grid description

   *  -  ``k_*``
      -  ``k_parallel``, ``k_perpendicular``
      -  Wave vector

   *  -  ``n_*``
      -  ``n_parallel``, ``n_perpendicular``
      -  Wave refractive index

   *  -  ``h_*``
      -  ``h_98``, ``h_mode`` flag
      -  Energy confinement time enhancement factor (with respect to a scaling
         expression), or related to H-mode.

   *  -  ``amns_*``
      -  ``amns_data`` IDS
      -  Atomic, molecular, nuclear, and surface related data

   *  -  ``rmps``
      -  ``summary`` IDS
      -  Resonant Magnetic Perturbations

   *  -  ``adc``
      -  ``neutron_diagnostic`` IDS
      -  Analogic-Digital Converter

   *  -  ``mse``
      -  ``mse`` IDS
      -  Motional Stark Effect

   *  -  ``bes``
      -  bes structure in the ``charge_exchange`` IDS
      -  Beam Emission Spectroscopy

   *  -  ``ir``
      -  ``camera_ir``
      -  Infrared

   *  -  ``[*_]gyroav[_*]``
      -  ``j_parallel_gyroav_real``
      -  Gyroaveraged

   *  -  ``_limit_``
      -  ``temperature_limit_max``
      -  Technical limit of a system. Always used with the suffix ``min`` or
         ``max``. By convention, nodes having this abbreviation in their name
         don't have errorbars.

   *  -  ``pcs``
      -  ``pcs`` IDS
      -  Plasma Control System

   *  -  ``*_over_*``
      -  ``vorticity_over_r`` in the ``MHD`` IDS
      -  Left term divided by right term

   *  -  ``*_*``
      -  ``r_j_phi`` in the ``MHD`` IDS
      -  Left term multiplied by right term

   *  -  ``focs``
      -  ``FOCS`` IDS
      -  Fiber Optic Current Sensor (diagnostic)


Prefixes
--------

.. list-table::
   :header-rows: 1

   *  -  Prefix
      -  Example
      -  Definition and comment

   *  -  ``t_e[_*]``
      -  
      -  Electron temperature

   *  -  ``t_i[_*]``
      -  
      -  Ion temperature

   *  -  ``n_e[_*]``
      -  
      -  Electron density

   *  -  ``n_i[_*]``
      -  
      -  Ion density

   *  -  ``tau[_*]``
      -  
      -  Characteristic time

   *  -  ``j_``
      -  
      -  Current density, authorized only as a prefix

   *  -  ``j_i_``
      -  
      -  Ion current density, authorized only as a prefix

   *  -  ``v_``
      -  
      -  Voltage or electric potential, authorized only as a prefix

   *  -  ``em_``
      -  
      -  Electromagnetic

   *  -  ``delta_``
      -  In the ``NBI`` IDS: ``unit/beamlets_group/tilting/delta_angle``
      -  Additive correction to static data (see G1.2) or more generally a
         quantity defined relatively to another one. The name of the original
         quantity is used after the prefix


Suffixes
--------

.. list-table::
   :header-rows: 1

   *  -  Suffix
      -  Example
      -  Definition and comment

   *  -  ``*_min``
      -  ``flux_min``
      -  Minimum value of, not to be confused with minute, which is not a
         standard IM unit

   *  -  ``*_max``
      -  ``power_max``
      -  Maximum value of

   *  -  ``*_sign``
      -  ``ip_sign``
      -  Sign of

   *  -  ``*_n``
      -  ``points_outline_n``
      -  Number of ..., requires underscore.

   *  -  ``*_tor[_], *_phi``
      -  ``rho_tor``
      -  ``Toroidal. In the context of (r,phi,z) coordinate system, toroidal vector components (and toroidal mode numbers) are marked with the suffix _phi (instead of _tor) for similarity with the other components *_r, *_z.``

   *  -  ``*_pol``
      -  ``b_field_pol``
      -  Poloidal

   *  -  ``*_norm``
      -  ``rho_tor_norm``
      -  Normalised

   *  -  ``*_1d``, ``*_2d``, ...
      -  ``profiles_1d``
      -  1-dimension, 2-dimensions, ...

   *  -  ``*_hfs``
      -  
      -  High field side

   *  -  ``*_lfs``
      -  
      -  Low field side

   *  -  ``*_parallel``
      -  ``k_parallel``
      -  Parallel component with respect to the local magnetic field

   *  -  ``*_perpendicular``
      -  ``k_perpendicular``
      -  Perpendicular component with respect to the local magnetic field

   *  -  ``*_flag``
      -  ``multiple_states_flag``
      -  Denotes an integer quantity equivalent to a boolean with the following
         convention: .FALSE. = 0 and .TRUE. = 1. Boolean types don't exist in
         all IMAS HLI languages and are thus not allowed in the Data Dictionary

   *  -  ``*_sigma``
      -  ``j_i_parallel_sigma``
      -  Standard deviation of a quantity


.. _`Forbidden names`:

Forbidden names
===============

A list of known forbidden names is given below but it is not exhaustive:
any name that creates potential conflicts with programming languages
used by the IMAS is forbidden as a node name.

.. list-table::
   :header-rows: 1

   *  -  Forbidden name
      -  Motivation

   *  -  ``global``, ``class``, ``switch``, ``static``
      -  Language conflict

   *  -  ``ne``, ``eq``, ``gt``, ``lt``, ``ge``, ``le``, ``or``, ``and``,
         ``if``, ``then``, ``else``
      -  Language conflict

   *  -  ``real``, ``complex``, ``integer``, ``long``, ``short``, ``double``,
         ``float``, ...
      -  Language conflict

   *  -  All single character names, with the exceptions listed in section 6.1
      -  Clarity of the naming

A more exhaustive list of forbidden names can be found in `reserved_names.txt
<https://github.com/iterorganization/IMAS-Data-Dictionary/blob/develop/reserved_names.txt>`__.


.. _`List of the existing data types`:

List of the existing data types
===============================

The following data types are available for data nodes (as opposed to
parent nodes which have children, see rule R3.2):

.. list-table::
   :header-rows: 1

   *  -  Data type
      -  Definition

   *  -  ``INT_0D``, ``INT_1D``, ``INT_2D``, ``INT_3D``
      -  Integer and arrays of integers

   *  -  ``FLT_0D``, ``FLT_1D``, ``FLT_2D``, ``FLT_3D``, ``FLT_4D``, ``FLT_5D``,
         ``FLT_6D``
      -  Real and arrays of reals

   *  -  ``STR_0D``, ``STR_1D``
      -  String and arrays of strings

   *  -  ``CPX_0D``, ``CPX_1D``, ``CPX_2D``, ``CPX_3D``, ``CPX_4D``, ``CPX_5D``,
         ``CPX_6D``
      -  Complex number and arrays of complex numbers.

   *  -  ``BYT_1D``
      -  Series of bytes. Note: not implemented in the Access Layer.
