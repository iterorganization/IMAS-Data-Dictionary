=======================================
Physics Data Dictionary developer guide
=======================================

Documentation maintained by F. Imbeaux (CEA)

**IMAS DD v3.21.1 and above (compatible with AL 4.0.0 and above).**


Definitions
===========

The Physics Data Dictionary (DD) provides information for data providers
and data consumers on:

-  What data exists?
-  What are they called?
-  How are they structured as seen by the user?

An Interface Data Structure (IDS) is an entry point of the Data
Dictionary that can be used as a single entity to be used by a user. The
IDS also define standardized interface points between IMAS physics
components. An IDS is a part of the Data Dictionary, an entry point into
it, thus the IMAS components are interfaced with the same structures as
those constituting the Data Dictionary.

Within the context of a tree structure, we define the following: a node
is any element of a tree, a leaf is a node which is an end-point of a
tree, a parent is one level above a particular node, a sibling is a node
sharing the same parent with a particular node and a child is one level
below a particular node. Nodes have either children or data, not both.


Overview of DD source files
===========================

The DD is implemented in the form of XML schemas (XSD). This form has
been preferred to plain XML because it allows reusing structures in
various places of the DD. These XSD files are the unique source
containing all information about the DD. They are organized in a modular
way, with one file per IDS.

The repository for the data dictionary is located at
`<https://git.iter.org/projects/IMAS/repos/data-dictionary/browse>`_

The repository contains:

-  ``dd_data_dictionary.xml.xsd``: this is the root of the data dictionary tree,
   listing the IDS and their maximum occurrence number (has to be pre-declared,
   temporary limitation). Its root element also contains the information of
   which COCOS convention is consistent with this version of the DD (``cocos=17`` in the
   example below):

   .. code-block:: xml

      <xs:element name="physics_data_dictionary">
         <xs:annotation>
            <xs:documentation>Root of the Physics Data Dictionary</xs:documentation>
            <xs:appinfo>
               <cocos>17</cocos>
            </xs:appinfo>
         </xs:annotation>
      </xs:element>

-  Folders containing a single XSD file describing each IDS. By
   convention, folders have the name of the IDS and the XSD file names
   are ``dd_{IDSNAME}.xsd``.

-  The ``utilities/dd_support.xsd`` file contains the definition of basic
   data types as well as of structures (complexTypes in the XSD sense)
   that can be reused in various parts of the DD.

-  Three XSL transforms (``.xsl`` files) for generating the documentation,
   the DD validation report and the IDSDef.xml file. A Makefile is
   provided to execute these XSLT transforms.

-  Two documentation folders:

   -  ``html_documentation`` contains the legacy generated HTML documentation.
   -  ``docs`` contains the Sphinx-based documentation.

-  ``dd_data_dictionary.xml`` (previously ``IDSDef.xml``): this is a single file
   containing the XML description of the whole Data Dictionary,
   self-generated from the XSD files. This is a useful intermediate step
   of the XSD processing for some applications (e.g. generation of
   Access Layer methods and documentation).

Note that only the first four items constitute the source of
information, the last two items being derived from them. Nonetheless,
they are part of the GIT repository since they are important information
which needs to be available at the same time as the original XSD
schemas.

The chosen file granularity follows the guideline (moved here from the
original version of the Rules and Guidelines for the ITER Physics Data
Model):


.. list-table::
   :header-rows: 1

   *  -  ID
      -  Guideline
      -  Motivation
      -  Date of last modification
   *  -  G_DD.1
      -  Use modular organisation of the XSD files for describing IDSs and big
         structures of the Data Dictionary
      -  Clarity of IDS management
      -  10 May 2013 (was G6.1 in the original document)

Complex types are organized according to the following rule:

.. list-table::
   :header-rows: 1

   *  -  ID
      -  Rule
      -  Motivation
      -  Date of last modification
   *  -  R_DD.1
      -  A complex type used only within the context of a single IDS must be
         declared within the IDS XSD file. If it is used by multiple IDSs, it
         should be described in the ``utilities/dd_support.xsd`` file
      -  Keep the information modular when possible and shared from a unique
         place otherwise
      -  New


Implementation of the root level dd_data_dictionary.xml.xsd
===========================================================

It starts with a series of ``<xs:include>`` instructions, first the
``utilities/dd_support.xsd`` file, then all IDS files. The list of IDS
includes uses alphabetic order for human readability (although the order
is not important from the software point of view).

Then, it has a root element, ``physics_data_model``, under which all IDSs
are listed as children, with an attribute ``maxOccurs`` which corresponds to
their maximum number of occurrences (has to be pre-declared, temporary
limitation). In fact one more occurrence is available, i.e. from 0 to
maxOccursValue. The list of IDS uses alphabetic order for human
readability (although the order is not important from the software point
of view).

To add a new IDS to the DD:

-  Add the include instruction:

   .. code-block:: xml

      <xs:include schemaLocation="{IDSname}/dd_{IDSname}.xsd"/>

   for example:

   .. code-block:: xml

      <xs:include schemaLocation="actuator/dd_actuator.xsd"/>

-  Add the IDS element as a child of physics_data_model

   .. code-block:: xml

      <xs:element ref="{IDSname}" maxOccurs="{maxOccursValue}"/>
               for example:

   .. code-block:: xml

      <xs:element ref="actuator" maxOccurs="6"/>

The complete structure of the files has the following form:

.. code-block:: xml

   <?xml version="1.0" encoding="ISO-8859-1" standalone="yes"?>
   <?modxslt-stylesheet type="text/xsl" media="fuffa, screen and
         $GET[stylesheet]" href="./%24GET%5Bstylesheet%5D" alternate="no"
         title="Translation using provided stylesheet" charset="ISO-8859-1" ?>
   <?modxslt-stylesheet type="text/xsl" media="screen" alternate="no"
         title="Show raw source of the XML file" charset="ISO-8859-1" ?>
   <?xml-stylesheet type="text/xsl" href="./xsd_2_IDSDef.xsl"?>

   <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema"
         elementFormDefault="qualified" attributeFormDefault="unqualified">
      <!--
         Here we must declare all included schemas, not only those directly
         below TOP but also all those used at any sublevel (makes it easier for
         the recursive XSL transformation generating the type definitions)
      -->
      <xs:include schemaLocation="utilities/dd_support.xsd"/>
      <xs:include schemaLocation="actuator/dd_actuator.xsd"/>
      <xs:include schemaLocation="controllers/dd_controllers.xsd"/>
      <xs:include schemaLocation="core_profiles/dd_core_profiles.xsd"/>
      <xs:include schemaLocation="core_sources/dd_core_sources.xsd"/>
      <xs:include schemaLocation="core_transport/dd_core_transport.xsd"/>
      <xs:include schemaLocation="em_coupling/dd_em_coupling.xsd"/>
      <xs:include schemaLocation="equilibrium/dd_equilibrium.xsd"/>
      <xs:include schemaLocation="magnetics/dd_magnetics.xsd"/>
      <xs:include schemaLocation="pf_active/dd_pf_active.xsd"/>
      <xs:include schemaLocation="pf_passive/dd_pf_passive.xsd"/>
      <xs:include schemaLocation="schedule/dd_schedule.xsd"/>
      <xs:include schemaLocation="sdn/dd_sdn.xsd"/>
      <xs:include schemaLocation="simulation/dd_simulation.xsd"/>
      <xs:include schemaLocation="temporary/dd_temporary.xsd"/>
      <xs:include schemaLocation="tf/dd_tf.xsd"/>

      <xs:element name="physics_data_model">
         <xs:annotation>
            <xs:documentation>Root of the Physics Data Model</xs:documentation>
         </xs:annotation>
         <xs:complexType>
            <xs:sequence>
               <xs:element ref="actuator" maxOccurs="6"/>
               <xs:element ref="controllers" maxOccurs="2"/>
               <xs:element ref="core_plasma" maxOccurs="6"/>
               <xs:element ref="core_profiles"/>
               <xs:element ref="core_sources" maxOccurs="6"/>
               <xs:element ref="core_transport" maxOccurs="6"/>
               <xs:element ref="em_coupling" maxOccurs="6"/>
               <xs:element ref="equilibrium" maxOccurs="6"/>
               <xs:element ref="magnetics" maxOccurs="6"/>
               <xs:element ref="pf_active" maxOccurs="6"/>
               <xs:element ref="pf_passive" maxOccurs="6"/>
               <xs:element ref="schedule"/>
               <xs:element ref="sdn" maxOccurs="6"/>
               <xs:element ref="simulation"/>
               <xs:element ref="temporary" maxOccurs="6"/>
               <xs:element ref="tf" maxOccurs="6"/>
            </xs:sequence>
         </xs:complexType>
      </xs:element>
   </xs:schema>


Implementation of utilities/dd_support.xsd
==========================================

This file contains all complexTypes and reference elements that are used
by more than one IDS.

The use of metadata in these data structures is slightly different than
in the rest of the Data Dictionary XSDs, since some code generation is
done directly on these structures outside of the context of the
ancestors which are using these structures. Therefore some information
of the ancestor context must be inserted in the structure. In addition,
the ``timebasepath`` attribute calculated during the DD XML file generation
has a different meaning in the context of utilities, thus an additional
way of using the ``coordinateN`` appinfo is available.


Information on ancestor context: aos3Parent appinfo
----------------------------------------------------

For some operations (e.g. the automated addition of the errorbar-related
nodes), the system must know whether a ``complexType`` is used as a
descendent of type 3 array of structure (see :ref:`dev_aosnode`). In order to mark
this, insert the attribute ``aos3Parent`` at the root of the ``complexType`` as
follows:

.. code-block:: xml

   <xs:complexType name="identifier_dynamic_aos3">
      <xs:annotation>
         <xs:documentation>
            Standard type for identifiers (dynamic within type 3 array of
            structures (index on time)). The three fields: name, index and
            description are all representations of the same information.
            Associated with each application of this identifier-type, there
            should be a translation table defining the three fields for all
            objects to be identified.
         </xs:documentation>
         <xs:appinfo>
            <aos3Parent>yes</aos3Parent>
         </xs:appinfo>
      </xs:annotation>
      <xs:sequence>
         ...
      </xs:sequence>
   </xs:complexType>

If a ``complexType`` can be used in different contexts (aos3 parent or not),
then it must be duplicated with a different name depending on the
context in which it will be used.


Coordinates
-----------

When it doesn't start with ``/`` the ``<coordinateN>`` attribute indicates,
as in the rest of the DD, the path of the N-th coordinate relative to
the node (see :ref:`dev_leafnode`). If the relative path goes above the root of the
``complexType`` being defined, add a sibling attribute
``<utilities_aoscontext>`` as follows:

.. code-block:: xml

   <coordinate1>../../time</coordinate1>
   <utilities_aoscontext>yes</utilities_aoscontext>

This additional attribute will enable a correct calculation of the
timebasepath attribute in the ``dd_data_dictionary.xml`` file (utilities
section), by defining it relative to the nearest AoS parent. Otherwise,
``timebasepath`` will use the ``\`` prefix and assume it is defined relative
to the root of the ``complexType``.

When it starts with ``/``, the ``<coordinateN>`` attribute indicates the path
of the N-th coordinate relative to the IDS root. This notation must be
used in case the coordinate is not located below the same AoS parent as
the node (this means a change of "context" for the Low Level and must
thus be calculated from the IDS root).


Implementation of an IDS
========================


IDS overview
------------

An IDS is implemented as a single file ``dd_{IDSNAME}.xsd``, stored in a
folder having the name of the IDS.

First, include the description of data types and reusable structures:

.. code-block:: xml

   <xs:include schemaLocation="../utilities/dd_support.xsd"/>

Second, include the description of all complex types used in the IDS.
Every node with children in the IDS must be declared as a complex type,
even if used only in a single place. Although regular XSD does not
require declaring a node with children as a separate complex type, this
has to be done because of the way structures are declared in Fortran. We
summarize here the important technical constraint rules related to the
complex type declaration:

.. list-table::
   :header-rows: 1

   *  -  ID
      -  Rule
      -  Motivation
      -  Date of last modification

   *  -  R_TC.1
      -  Sub-trees (i.e. nodes that have children) must be declared by creating
         generic complex types with unique name over the complete Data
         Dictionary.
      -  Languages which create variables outside the context of an IDS would
         otherwise have collisions of the definitions in the source code. This
         happens with Fortran, where derived types cannot be declared in a
         nested way.
      -  29 March 2012 (was R6.1 in the original document).

   *  -  R_TC.2
      -  Within an XSD file, the generic complex types must be listed in an
         order compatible with Fortran compilers, i.e. define the basic (lowest
         level) types first, then the high level types which may reuse the
         lowest level ones.
      -  The list of complex types will be translated in the same order in
         Fortran, which interprets type definitions from top to bottom.
         Therefore the compiler will fail when trying to interpret a definition
         which has not been given above.
      -  New (the constraint was there already but the rule was not explicit).

   *  -  R_TC.3
      -  A given complex type cannot be used simultaneously for a simple
         structure and arrays of structure. If there is such need, the complex
         type must be duplicated and its 2 instances reserved respectively for
         i) simple structure and ii) array of structure usage.
      -  Creates a problem in Python.
      -  29 March 2012 (was R6.2 in the original document).

.. list-table::
   :header-rows: 1

   *  -  ID
      -  Rule
      -  Motivation
      -  Date of last modification

   *  -  G_TC.1
      -  To help obtaining the unicity of a complex type name over the complete
         Data Dictionary, the following naming convention is recommended:

         1. If the complex type is used within a single IDS, its name starts
            with ``IDSName_``.
         2. The name is extended with the enumeration of ancestors of the node
            (if there is a single one) using the complex type, i.e.
            ``IDSName_complexType1Name_..._complexTypeNName``.

         However, it appears that some versions of gfortran do not accept
         derived type names above 60 characters, the complex type naming must
         therefore stay within this limit.
      -  Example: the node ``magnetics/flux_loops`` is declared as a complex
         type with name ``magnetics_flux_loops``.
      -  15 February 2015

A complex type is declared as:

.. code-block:: xml

   <xs:complexType name="{complexTypeName}">
      <xs:annotation>
         <xs:documentation>
            Write here the definition of the complex type
         </xs:documentation>
      </xs:annotation>
      <xs:sequence>
         <xs:element name="{node1Name}"/>
         <!-- list here all the child nodes -->
         <xs:element name="{nodeNName}"/>
      </xs:sequence>
   </xs:complexType>

Third, describe the IDS root and its children. The IDS root must have
some mandatory child structures (``ids_properties``, ``code`` and ``time``),
which are listed always in the same order for homogeneity. The general
structure of this third part of the IDS implementation is indicated
below with some interlaced comments. Detailed explanations are given in
subsequent sections.

.. code-block:: xml
   
   <xs:element name="{IDSname}">
      <xs:annotation>
         <xs:documentation>Definition of this IDS</xs:documentation>
         <!-- 
            Provide lifecycle information (inherited recursively by all
            descendants except if one of them is marked with different lifecycle
            information):
         -->
         <xs:appinfo>
            <lifecycle_status>alpha</lifecycle_status>
            <lifecycle_version>3.0.0</lifecycle_version>
            <lifecycle_last_change>3.10.0</lifecycle_last_change>
            <!--
               Optional IDS-specific validation check (just skip the line below
               if there aren't any):
            -->
            <specific_validation_rules>yes</specific_validation_rules>
         </xs:appinfo>
      </xs:annotation>
      <xs:complexType>
         <xs:sequence>
            <xs:element ref="ids_properties"/>
            <xs:element name="{node1Name}"/>
            <!-- 
               List here all the child nodes
            -->
            <xs:element name="{nodeNName}"/>
            <xs:element ref="code"/>
            <xs:element ref="time"/>
         </xs:sequence>
      </xs:complexType>
   </xs:element>


Lifecycle information
~~~~~~~~~~~~~~~~~~~~~

The lifecycle information must be placed at least at the top of the IDS
and by default applies to all nodes of the IDS. It's inherited
recursively by all descendants except if one of them is marked with
different lifecycle information (it allows to set different lifecycle
status to some parts of the IDS). It consists in three properties:

``<lifecycle_status>``
   The lifecycle status. Can be either: ``alpha``, ``active`` or
   ``obsolescent``.

``<lifecycle_version>``
   The tagged version since which this structure has this lifecycle status.
   
``<lifecycle_last_change>``
   The tagged version at which the last change occurred to this structure.


IDS-specific validation rules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

It is possible to introduce IDS-specific validation rules to check that
its content has a physical meaning. For instance, in the ``core_*`` and
``edge_*`` IDSs, allocating ion or neutral species requires filling the
description of these species (``element`` AoS). An example of such a rule
has been implemented in the Fortran High Level Interface (IMAS-2162),
implemented in the ``specific_validation_rules.f90`` source file.

To activate such checks for a given IDS (they must be coded in the above
HLI source file), the IDS must be tagged at its root (e.g. just below
the lifecycle information) with:

.. code-block:: xml

   <specific_validation_rules>yes</specific_validation_rules>


Node properties
---------------

Each node is declared as an ``<xs:element>`` with some properties. What
follows replaces the ``<xs:element name="{nodeNName}"/>`` lines in the list
above. Although most of the properties are common to all nodes, we
distinguish three cases: leaf, simple structure node, array of structure
node.

.. _`dev_leafnode`:

Leaf (node with data)
~~~~~~~~~~~~~~~~~~~~~

A leaf node is declared as:

.. code-block:: xml

   <xs:element name="{nodeName}">
      <xs:annotation>
         <xs:documentation>
            Write here the definition of the node
         </xs:documentation>
         <xs:appinfo>
            <!--
               Indicate the time-variation of the node (dynamic, constant or
               static). For example:
            -->
            <type>dynamic</type>
            <!--
               Indicate here the units of the node, e.g. "W" for a power.
            -->
            <units>W</units>
            <!-- Indicate relative paths to all coordinates of the node: -->
            <coordinate1>../channels"</coordinate1>
            <coordinate2>../time"</coordinate2>
         </xs:appinfo>
      </xs:annotation>
      <xs:complexType>
         <!-- Indicate the data type of the node, for example FLT_2D: -->
         <xs:group ref="FLT_2D"/>
      </xs:complexType>
   </xs:element>

The detailed meaning of each property can be found in the
:ref:`dm_rules_guidelines`. In particular sections :ref:`Self-description
Conventions` and :ref:`List of the existing data types`.

NB1: units are normally explicitly defined at the level of the leaf node.
However, in the case of a node belonging to a structure that can be used in different contexts,
it's possible to refer to the units of the parent node by indicating ``<units>as_parent</units>``.
It's also possible to refer to the units of the grandparent node with 
``<units>as_parent_level_2</units>``. The references will be explicitly resolved 
when generating the ``dd_data_dictionary.xml`` file.

NB2: ``FLT_*`` and ``CPX_*`` nodes will have sibling errorbar nodes automatically created
when generating the dd_data_dictionary.xml file. To avoid this, for performance reasons
(e.g. in large size GGD objects), the data type of the leaf should be declared in a different way,
using the simpleTypes defined in utilities.xsd (named flt_type and flt_nd_type). Example:

.. code-block:: xml

	<xs:element name="time" type="flt_1d_type">
		<xs:annotation>
			<xs:documentation>Generic time</xs:documentation>
			<xs:appinfo>
			<coordinate1>1...N</coordinate1>
			<type>dynamic</type>
			<units>s</units>
			</xs:appinfo>
		</xs:annotation>
	</xs:element>

Simple structure node
~~~~~~~~~~~~~~~~~~~~~

A simple structure is declared as

.. code-block:: xml

   <xs:element name="{nodeName}" type="{complexTypeName}">
      <xs:annotation>
         <xs:documentation>
            Write here the definition of the node
         </xs:documentation>
      </xs:annotation>
   </xs:element>

An example from the core_profiles IDS:

.. code-block:: xml

   <xs:element name="global_quantities" type="core_profiles_global_quantities">
      <xs:annotation>
         <xs:documentation>
            Various global quantities derived from the profiles
         </xs:documentation>
      </xs:annotation>
   </xs:element>

Structure nodes shouldn't have units, unless these are refered to by descendent
leaf nodes (see ``<units>as_parent</units>`` case above)

Note that the previous (from DD tags 3.0.0 to 3.21.0) way of declaring
signals (data, time structures with their own time bases) is deprecated.
With the new Low Level (AL tag 4.0.0) the flexibility of the possible
location of time bases has been increased and it suffices to use
existing generic structures such as signal_flt_1d for standard signals.
This is the source of backward incompatibility of the DD with the old
low level AL implementation (starting from 3.21.1).

.. _`dev_aosnode`:

Array of structure node
~~~~~~~~~~~~~~~~~~~~~~~

In the present implementation, an array of structure is only 1D.

From the DD developer point of view, there are three types of array of
structure nodes, which are implemented in three different ways:

1. Array of structure of which the index is NOT a time base and
   containing dynamic nodes which do NOT have the same time base. A
   typical example is a set of equipment or sensors e.g. the active PF
   coils or the magnetics flux loops. Each index of the array of
   structure is implemented as an explicit node in the storage. This
   requires defining a maximum size of the array of structure node.

2. Array of structure of which the index is NOT a time base and
   for which all dynamic nodes it contains (if any) use the same time
   base. For this type a more powerful and elegant storage method is
   implemented, using objects corresponding to time slices of the unique
   time base. These objects can also be used for constant or static data
   (i.e. a type 2 array of structure may contain only constant or static
   data). Note that this type of AoS is for the moment only implemented
   as nested below (a descendent of) a type 3 AoS.

3. Array of structure of which the index is a time base. All
   nodes contained must be dynamic and refer to the time base, which is
   a ``time`` child of the array of structure node.

An array of structure is declared as:

.. code-block:: xml

   <!--
      Note: {maxOccurs} is a fixed number for type 1 array of structure, or
      "unbounded" for types 2 and 3
   -->
   <xs:element name="{nodeName}" type="{complexTypeName}" maxOccurs="{maxOccurs}">
      <xs:annotation>
         <xs:documentation>
            Write here the definition of the node
         </xs:documentation>
         <xs:appinfo>
            <!--
               coordinate1 should be:
               - "1...N" for types 1 and 2, or
               - "time" for type 3
            -->
            <coordinate1>...</coordinate1>
            <!-- Only for type 3. Leave <type> out for types 1 and 2: -->
            <type>dynamic</type>
         </xs:appinfo>
      </xs:annotation>
   </xs:element>

Arrays of structure can be nested within an IDS. The table below shows
the nesting combinations that are possible and already implemented ("OK"
in that case):

.. list-table::
   :header-rows: 2

   *  -  Type of the parent AoS 1 →
      -  1
      -  2
      -  3
   *  -  Type of the nested AoS
      -  
      -  
      -  
   *  -  1
      -  OK
      -  Not implemented
      -  Not possible
   *  -  2
      -  Not implemented [#aos_tp2_in_tp1]_
      -  Not implemented
      -  OK
   *  -  3
      -  OK
      -  Not implemented
      -  Not possible

.. [#aos_tp2_in_tp1] Not implemented with type 1 as direct parent, but possible
   as a descendent of a type 3 inside a type 1 AoS.


.. _`dev url`:

Attaching further documentation to a node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to the mandatory documentation indicated above, it is
possible (optionally) to attach further documentation to a node in the
form of a web link (URL). This URL can e.g. point either to an external
web site or to a local document which then has to be part of the DD
repository (and put in the html_documentation folder under an ``IDS``
sub-folder for the sake of organization). This has to be declared as an
additional ``<url>`` tag within the ``<appinfo>`` tag of the node in the
``dd_{IDS}.xsd`` file. See example below:

.. code-block:: xml

   <xs:appinfo>
      <type>static</type>
      <coordinate1>1...N</coordinate1>
      <coordinate2>1...N</coordinate2>
      <url>pf_active/PFConnections.html</url>
   </xs:appinfo>

This property will be turned into a URL in the HTML documentation by the
documentation generator (XSL transform). In case of a local file, the
relative path with respect to the html_documentation folder must be
specified.


.. _`dev doc_identifier`:

Attaching an enumerated list definition to an "identifier" node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The "identifier" complex type is frequently used in the Data Dictionary
to play the role of an enumerated list (short string, integer index,
longer string). The meaning of this enumerated list is optionally
specified by attaching an XML file with standardized format to the node
of "identifier" complex type. For example:

.. code-block:: xml

   <xs:element name="grid_type" type="identifier">
      <xs:annotation>
         <xs:documentation>
            Selection of one of a set of grid types
         </xs:documentation>
         <xs:appinfo>
            <doc_identifier>
               equilibrium/equilibrium_profiles_2d_identifier.xml
            </doc_identifier>
         </xs:appinfo>
      </xs:annotation>
   </xs:element>


.. _`dev alternative_coordinate1`:

Attaching a list of alternative coordinates to a coordinate node
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Only one coordinate is associated to a given dimension of a node (see
above). However, in some cases, alternative coordinates can be also
considered -- they are equivalent and one can map easily one into
another. See the example with the radial coordinate in core_profiles. It
means that it's no longer mandatory to fill the "main" coordinate of a
non-empty node, it's possible to fill any of the alternative coordinates
instead (at least one in the list [main or alternative coordinates]).

The alternative coordinate list is indicated in the Data Dictionary (see
IMAS-4725) at the level of the "main" coordinate node (i.e. the one
which is mentioned in the ``<coordinateN>`` tags of the nodes using this
coordinate). This is the most efficient convention since it avoids
having to repeat the information in multiple places. This is done by
adding an ``<alternative_coordinate1>`` tag to the main coordinate metadata,
as shown in the example below (from core_profiles IDS). The "N" refers to the
dimension index (as the "N" in the ``<coordinateN>`` tags). If there are
multiple alternative coordinates, list them separated with a semicolumn
";". Don't insert white spaces or any other character in the list of
relative paths, since this would break the translation from relative to
absolute path when generating the dd_data_dictionary.xml file.

.. code-block:: xml

   <xs:element name="rho_tor_norm">
      <xs:annotation>
         <xs:documentation>
            Normalised toroidal flux coordinate. The normalizing value for
            rho_tor_norm, is the toroidal flux coordinate at the equilibrium
            boundary (LCFS or 99.x % of the LCFS in case of a fixed boundary
            equilibium calculation, see time_slice/boundary/b_flux_pol_norm in
            the equilibrium IDS)
         </xs:documentation>
         <xs:appinfo>
            <type>dynamic</type>
            <coordinate1>1...N</coordinate1>
            <alternative_coordinate1>../rho_tor;../psi;../volume;../area;../surface;../rho_pol_norm</alternative_coordinate1>
            <units>1</units>
         </xs:appinfo>
      </xs:annotation>
      <xs:complexType>
         <xs:group ref="FLT_1D"/>
      </xs:complexType>
   </xs:element>

This information is later used when generating the documentation
and for the IDS consistency check related to coordinates.


.. _`dev appendable_by_appender_actor`:

Marking an array of structure node as "appendable by appender actor"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

From feature request IMAS-1916, an "appender" actor has been develop to
append some pre-defined AoS, e.g. to add another source term in an
already existing set of source terms core_sources/source(:).

To simplify the development and because this functionality will likely
be used only for a limited set of arrays of structure of the DD, the
nodes that can be potentially processed by this actor are marked with a
specific metatadata, namely:

.. code-block:: xml

   <xs:appinfo>
      <appendable_by_appender_actor>yes</appendable_by_appender_actor>
   </xs:appinfo>


Marking non-backward compatible changes in the DD
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Non-backward compatible changes in the DD can be marked as additional
metadata, to allow for instance the Access Layer to deploy alternative
strategies to read from IMAS files written with previous versions of the
DD and map them to the loaded DD version.

NB: when a new category of NBC metadata is introduced in the DD, 
it should be also documented in ``docs/sphinx_dd_extension/autodoc.py``,
otherwise the Sphinx documentation generation will not recognize it and
will fail.

The following use cases are implemented :

1. Renaming

   -  Renaming of a leaf: mark the new node with the following metadata
      (within ``<appinfo>``):

      .. code-block:: xml

         <!-- Version at which the non-backward compatible change occurred: -->
         <change_nbc_version>3.26.0</change_nbc_version>
         <!-- Description of the non-backward compatible change -->
         <change_nbc_description>leaf_renamed</change_nbc_description>
         <!-- Previous name of the node (before the change) -->
         <change_nbc_previous_name>r/data</change_nbc_previous_name>

   -  Renaming of an array of structure: mark the new node with the
      following metadata (within ``<appinfo>``) :

      .. code-block:: xml

         <change_nbc_version>3.26.0</change_nbc_version>
         <change_nbc_description>aos_renamed</change_nbc_description>
         <change_nbc_previous_name>antenna</change_nbc_previous_name>

   -  Renaming of a simple structure: mark the new node with the following
      metadata (within ``<appinfo>``) :

      .. code-block:: xml

         <change_nbc_version>3.26.0</change_nbc_version>
         <change_nbc_description>structure_renamed</change_nbc_description>
         <change_nbc_previous_name>launching_angle_pol</change_nbc_previous_name>

   -  Renaming of an IDS : mark the new node with the following metadata
      (within ``<appinfo>``) :

      .. code-block:: xml

         <change_nbc_version>3.40.0</change_nbc_version>
         <change_nbc_description>ids_renamed</change_nbc_description>
         <change_nbc_previous_name>gyrokinetics</change_nbc_previous_name>

   The software can handle multiple renamings, here is a syntax example:

   .. code-block:: xml

      <change_nbc_version>3.26.0,3.40.0</change_nbc_version>
      <change_nbc_description>aos_renamed</change_nbc_description>
      <change_nbc_previous_name>antenna,launcher</change_nbc_previous_name>

2. Changing the type of a node (although there is not necessarily a
   conversion rule, e.g. when the dimension of the quantity is changed,
   it is still interesting to trace since errors may occur in physics
   code related to the change): mark the new node with the following
   metadata (within ``<appinfo>``):

   .. code-block:: xml
      :caption: Example for a leaf type change

      <change_nbc_version>3.39.0</change_nbc_version>
      <change_nbc_description>type_changed</change_nbc_description>
      <change_nbc_previous_type>FLT_0D</change_nbc_previous_type>

   .. code-block:: xml
      :caption: Example for a structure type change (indicate the name of the previous ``xsd:complexType``)

      <change_nbc_version>3.39.0</change_nbc_version>
      <change_nbc_description>type_changed</change_nbc_description>
      <change_nbc_previous_type>generic_grid_scalar</change_nbc_previous_type>

3. Characterize closed contours by repeating the last point. This change of convention (IMAS-5168) is documented to enable automated conversion (before closed countour were either implicit, or indicated by a ``closed`` node, and the first point was never repeated). The NBC tags must be placed at the level of the parent structure of the coordinates describing the countour (within ``<appinfo>``):

   .. code-block:: xml
      :caption: Example for an implicitly closed contour (the contour is always closed, so the first point must be repeated when doing the conversion)

      <change_nbc_version>4</change_nbc_version>
      <change_nbc_description>repeat_children_first_point</change_nbc_description>

   .. code-block:: xml
      :caption: Example for a contour that is not necessarily closed (the conversion tool will check the closed child flag in DDv3)

      <change_nbc_version>4</change_nbc_version>
      <change_nbc_description>repeat_children_first_point_conditional</change_nbc_description>

   .. code-block:: xml
      :caption: Example for a contour that is not necessarily closed (the conversion tool will check the closed sibling flag in DDv3)

      <change_nbc_version>4</change_nbc_version>
      <change_nbc_description>repeat_children_first_point_conditional_sibling</change_nbc_description>

   .. code-block:: xml
      :caption: Example for a dynamic contour that is not necessarily closed (the conversion tool will check the closed sibling flag in DDv3)

      <change_nbc_version>4</change_nbc_version>
      <change_nbc_description>repeat_children_first_point_conditional_sibling_dynamic</change_nbc_description>
      
   .. code-block:: xml
      :caption: Specific case for wall annular thickness (which has a size equals to the contour size-1): remove the last point of a vector in case the ../centreline/closed flag is False in DDv3

      <change_nbc_version>4</change_nbc_version>
      <change_nbc_description>remove_last_point_if_open_annular_centreline</change_nbc_description>



Attaching COCOS transformation metadata at the node level
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Information about how some nodes of the DD should be transformed in case
of conversion from one COCOS value to another can be added as follows.

-  If the node is specific, i.e. not part of a generic structure that
   can be used in multiple contexts in the DD, then the COCOS metadata
   must be inserted directly at the node level, within its ``<appinfo>``:

   .. code-block:: xml

      <!-- Label of the cocos transformation: -->
      <cocos_label_transformation>ip_like</cocos_label_transformation>
      <!-- Expression of the cocos transformation: -->
      <cocos_transformation_expression>.sigma_ip_eff</cocos_transformation_expression>
      <!-- 
         Full path to the quantity, using "." instead of "/" as path separator.
         Arrays of structure indices must be indicated with {i} (first level
         from the top) and {j} (second level from the top). The case of more
         than two nested AoS in the path is not addressed by the COCOS
         conversion library (but there is no relevant node in the DD so far).
      -->
      <cocos_leaf_name_aos_indices>core_profiles.global_quantities.ip</cocos_leaf_name_aos_indices>
   
-  If the node is part of a generic structure that can be used in
   multiple contexts in the DD (e.g. a signal structure with two
   children data and time), but that isn't systematically
   COCOS-dependent, then the COCOS metadata must be inserted directly at
   the level of its parent, within its <appinfo>. This use case is
   relevant when a single node in the generic structure is
   COCOS-dependent. In the example below, the COCOS information applies
   to the ``pf_active/coil/current/data`` node but is carried by its parent
   ``pf_active/coil/current`` because only the parent carried the context
   that makes its child COCO-dependent.

   .. code-block:: xml

      <cocos_label_transformation>ip_like</cocos_label_transformation>
      <cocos_transformation_expression>.sigma_ip_eff</cocos_transformation_expression>
      <cocos_leaf_name_aos_indices>pf_active.coil{i}.current.data</cocos_leaf_name_aos_indices>

-  If the node is part of a generic structure that can be used in
   multiple contexts in the DD (e.g. a toroidal position node ``phi`` in an
   ``R``, ``Z``, ``phi`` structure) and that is systematically COCOS-dependent, then
   the COCOS metadata must be inserted directly at the level of the
   node. Since their full path cannot be known a priori (depending on
   the context in which they will be used), a mechanism to insert their
   final DD path is provided. At the level of the COCOS-dependent leaf
   in the generic structure (e.g. in ``dd_support.xsd``), indicate:

   .. code-block:: xml

      <cocos_label_transformation>b0_like</cocos_label_transformation>
      <cocos_transformation_expression>.sigma_b0_eff</cocos_transformation_expression>
      <cocos_leaf_name_aos_indices>IDSPATH.b0</cocos_leaf_name_aos_indices>

   The ``IDSPATH`` string will be replaced following information provided in
   one of the ancestors of the generic structure. So often it's practical
   to specify just ``IDSPATH.relative_path_within_generic_structure``.

   In one of the ancestor node using that structure, indicate the following
   metadata: the resulting ``cocos_leaf_name_aos_indices`` path will be
   obtained by replacing the ``cocos_alias`` string by the ``cocos_replace``
   string. This mechanism will work only if the same string replacement is
   relevant for all COCOS-dependent metadata located below the ancestor
   node.

   .. code-block:: xml

      <cocos_alias>IDSPATH</cocos_alias>
      <cocos_replace>core_profiles.vacuum_toroidal_field</cocos_replace>

   In case the replacing path involves arrays of structures, they must
   be indicated in the ``<cocos_replace>`` metadata as follows (two levels
   of AoS in this example):

   .. code-block:: xml

      <cocos_replace>core_instant_changes.change{i}.profile_1d{j}</cocos_replace>

The COCOS-related metadata are added directly to the
``dd_data_dictionary.xml`` file without further transformation (see below).
A dedicated XSLT transform applied to the ``dd_data_dictionary.xml`` file
will then generate the ``ids_cocos_transformation_symbolic_table.csv`` file,
gathering all COCOS-related metadata in a form ready for use by the
COCOS conversion library. During the XSLT transform, additional
cocos-related metadata required by the cocos conversion library are
computed from the DD metadata. These are:

-  ``cocos_leaf_name``: same as ``cocos_leaf_name_aos_indices`` but without the
   AoS indices in the path.
-  ``cocos_length_i``: Path to the first AoS, ``[1]`` if no AoS.
-  ``cocos_length_j``: Path to the second AoS, ``[1]`` if no second AoS

Note that there is no information on the errorbar nodes in any of these
metadata: the COCOS conversion library will deal with that by simply
applying the same conversion on the errorbar nodes as on the main node.


Adding node creation tag in the DD
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Following a feature request, it was decided to introduce metadata
indicating after which tag a node has been introduced into the DD. In
case of a structure node, this information applies by default to all
of its descendants.

This done with the following metadata, to be located within the
``<appinfo>`` tag of the node:

.. code-block:: xml

   <introduced_after_version>LAST TAG BEFORE THE INTRODUCTION OF THE NODE</introduced_after_version>

These metadata will be added manually at each DD extension, from June
2021 onwards. At some point, it would be worth to replace this manual
procedure by an automated tool making use of the information contained
in the GIT repository.


The dd_data_dictionary.xml file
===============================

The ``dd_data_dictionary.xml`` file contains as a single file the XML
description of the whole Data Dictionary, self-generated from the XSD
files. This is a useful intermediate step of the XSD processing for some
applications (e.g. generation of Access Layer methods and
documentation). During that step, errorbar nodes are systematically
added as siblings to all ``FLT_*`` and ``CPX_*`` nodes (except those
containing ``_limit_`` in their name). All information from the XSD is
replicated in the ``dd_data_dictionary.xml`` file, with a slightly different
syntax as indicated below. Note that this choice of syntax is purely
internal to the DD processing, since the developer only codes the DD in
form of the XSDs as described in previous sections. In addition to
replicating the XSD ``<appinfo>`` tags, some attributes are computed by
sometimes sophisticated logic in the XSD to XML transform (e.g. ``timebasepath``).

It starts with a main element ``<IDSs>``, containing the list of all IDSs.

During Access Layer compilation, a tag is added just after this to
record the DD version (commit hash or tag), for example:

.. code-block:: xml

   <version>3.28.1-8-gdbe00f7</version>

The COCOS convention used in this version of the DD is then copied from
the XSD file:

.. code-block:: xml

   <cocos>11</cocos>

Just below, a ``<utilities>`` section replicates the content of
``utilities/dd_support.xsd``, i.e. the list of generic types used in several
places of the DD. This section is used to generate AL code related to
these generic types, in order to avoid repetition of this code at each
place where the structure is used.

Each IDS is indicated by an ``<IDS>`` tag, having the following attributes:

-  ``name``: IDS name
-  ``maxoccur``: maximum number of occurrences of this IDS (temporary
   technical limitation)
-  ``documentation``: description of this IDS
-  ``lifecycle_status``: lifecycle status as defined in the DD lifecycle
   document
-  ``lifecycle_version``: version of the DD since which this IDS has this
   lifecycle status

Example:

.. code-block:: xml

   <IDS
      name="actuator"
      maxoccur="6"
      documentation="Generic simple description of a heating/current drive
         actuator, for a first simplified version of the Plasma Simulator
         component"
      lifecycle_status="alpha"
      lifecycle_version="3.0.0">

Within an IDS, each node is indicated by a ``<field>`` tag, having the
following attributes:

-  ``name``: node name
-  ``path``: path relative to the nearest parent IDS
-  ``path_doc``: same as path, but arrays of structure in the path are
   marked with a (:) suffix. This is used for documentation purposes.
-  ``documentation``: description of this node
-  ``data_type``: data type of this node (e.g. ``FLT_1D``, ``structure``,
   ``struct_array``)
-  ``type``: time-variation character of the node: ``dynamic`` OR ``constant`` OR
   ``static``
-  ``maxoccur``: this attribute is present only in the case of an array of
   structure. The relation with the three types of arrays of structure
   is as follows:

   -  If ``maxoccur`` is finite, this is a type 1 array of structure and
      ``maxoccur`` indicates the maximum size of the array (temporary
      limitation).
   -  If ``maxoccur="unbounded"`` and the node has no ``type="dynamic"``
      attribute this is a type 2 array of structure.
   -  If ``maxoccur="unbounded"`` and the node has a ``type="dynamic"``
      attribute this is a type 3 array of structure.

-  ``coordinate1`` ... ``coordinateN``: N attributes listing the coordinates of
   the node (absolute paths, i.e. relative to the root of the IDS)
-  ``units``: units of the node. In case the units in the IDS schema refer 
   to the parent or grandparent node, these references are explicitly resolved
   in the ``dd_data_dictionary.xml`` file
-  ``lifecycle_status``: lifecycle status as defined in the DD lifecycle
   document
-  ``lifecycle_version``: version of the DD since which this node has this
   lifecycle status
-  ``structure_reference`` (introduced for the New Low Level and calculated
   by the DD XSD to XML transform): name of the original XSD ``complexType`` in
   which the structure is defined. This attribute exists only for
   structure and array of structure nodes. This information is kept in
   the DD XML file in order to organize code generation by structures
   and avoid replicating the structure-related code at every occurrence
   of the structure in the DD. In the ``<utilities>`` section, ``complexTypes``
   defining structures are marked with ``structure_reference = "self"``.
-  ``timebasepath``. This attribute exists only for nodes that have a
   timebase in their coordinates (i.e. for dynamic nodes NOT located
   under an AoS3 parent). This attribute is the path of the timebase of
   this node:

   -  Relative to the nearest AoS ancestor (or relative to the IDS root
      if the node has no AoS ancestor) if timebasepath doesn't starts
      with ``/`` or ``\``.
   -  Relative to the IDS root if timebasepath starts with ``/``.
   -  Relative to the root of the utilities ``complexType`` or element if
      timebasepath starts with ``\`` (case occurring only in the
      ``<utilities>`` section).

   In the ``<IDS>`` sections, this attribute is then used directly in the
   Access Layer as the timebase path argument to be passed to the Low
   Level for this node.

   By convention, we add a ``timebasepath='time'`` attribute to any AoS3
   node (see IMAS-4618).

-  ``url``: link to a separate file for the HTML documentation, see :ref:`dev
   url`.
-  ``doc_identifier``: link to an identifier XML file, see :ref:`dev
   doc_identifier`.
-  ``alternative_coordinate_1`` ... ``alternative_coordinate_1``, see :ref:`dev
   alternative_coordinate1`

-  ``appendable_by_appender_actor``: see :ref:`dev appendable_by_appender_actor`

Example:

.. code-block:: xml

   <field
      name="rho_tor_norm"
      path="profiles_1d/rho_tor_norm"
      path_doc="profiles_1d(:)/rho_tor_norm"
      documentation="Normalised toroidal flux coordinate. The normalizing value
         for rho_tor_norm, is the toroidal flux coordinate at the equilibrium
         boundary (LCFS or 99.x % of the LCFS in case of a fixed boundary
         equilibium calculation)"
      data_type="FLT_1D"
      type="dynamic"
      coordinate1="1...N"
      units="-" />


Applying the XSL Transforms
===========================

Using the make command, the XSL transforms are applied and generate from
the DD schemas:

-  The ``dd_data_dictionary.xml`` file

-  The HTML documentation, under
   ``html_documentation/html_documentation.html``

-  A DD validation report, under ``dd_data_dictionary_validation.txt``. This
   files reports on the compliance of the DD to Rules and Guidelines for which
   an automated checking could be implemented. The present version of the
   validation procedure checks the present of ``<units>``,`` <type>`` and
   ``<coordinate>`` metadata for all relevant DD nodes. Further checks can be
   added to the procedure by editing ``dd_data_dictionary_validation.txt.xsl``.
