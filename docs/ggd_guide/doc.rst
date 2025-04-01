..
    GGD doc initially copied from https://git.iter.org/projects/IMEX/repos/ggd/browse/doc/guide/source

.. _ggd-doc:

=================================
Introduction to the GGD structure
=================================

The purpose of this guide is to provide a better insight on the **Generalized
Grid Description (GGD)** structure found in **Data Dictionary** [DD_git]_ and
how to utilize it for storing description of grids such as **structured**
and **unstructured** grids.

----------------------------------
Basic principles of tree hierarchy
----------------------------------

**Data Dictionary** is a complex hierarchical structure consisting
of tree nodes and it is fundamental to know the basics. Each leaf of a tree
is set to hold specified data in specified format. There are next building
blocks that compose the Data Dictionary:

- a **node**, the main building block of the data tree, referring to any
  element of the tree. There are two types of nodes:

  - **simple structure node**, being a regular single node, and
  - **array of structures node (AOS)**, describing a 1D array of structures
    under a single node label,

- a **leaf**, referring to an end-point of a tree,
- a **parent**, referring to an element one level above a particular node,
- a **sibling**, referring to an element at the same level as a given node,
- a **child**, referring to an element one level below a particular node,
  with navigation through the tree nodes running from start-point
  nodes through lower-level nodes to the end-point leafs.

.. figure:: images/data_tree_simpleStructureNode.png
   :align: center
   :width: 350px

   The simple structure node concept (source: [Thesis]_).

.. figure:: images/data_tree_arrayOfStructuresNode.png
   :align: center
   :width: 400px

   The array of structures (AOS) node concept, with structures running from
   ``1 to n``, where ``n`` is total number of structures.

.. figure:: images/data_tree_parentChildSibling.png
   :align: center
   :width: 350px

   Parent, sibling, child and leaf element of data structure unit tree
   (source: [Thesis]_).

-----------
Grid basics
-----------

The grid (or mesh) is an assemblage of multiple connected elements, provided
through their geometry information, which as a whole represents a discrete
approximation of geometry of a real-life physical object. Grids are required
for solving
physical or mathematical problems like fluid flow and heat transfer, producing
virtual presentations of simulations intended for analysis of simulation
results and other computing-related work in connection with the real-life object.

Each grid is constructed by many low-level components of various geometrical
types, hereafter referred to as **objects**, as the same term is used for
geometrical types in Data Dictionary.

The main objects forming the grid are:

1. **points** or **nodes**,
2. **edges** or **lines**,
3. **faces** or **surfaces**, also known as **two-dimensional cells**, and
4. **three-dimensional cells** or **volumes**.

A point with given coordinates in a specific coordinate system represents the
**base-level** grid object. Two specific points form an object specified as an
edge, and two or more edges form an object specified as a face or a
two-dimensional cell. The most commonly used two-dimensional cell shapes are
triangles, formed by three edges, and quadrilaterals, formed by four edges as
shown in figures below. In three-dimensional space, multiple 2D cells form a 3D
cell, of which the most commonly used are tetrahedron (formed using four
triangle 2D cells) and hexahedron (formed using six quadrilateral 2D cells).

.. figure:: images/grid_structure_1.png
   :align: center
   :width: 550px

   An example of the basic principle of the two-dimensional quadrilateral cell
   formation starting with four anti-clockwise assorted points P1, P2, P3,
   and P4 (a). Those points represent the edge boundary of the E1 to E4 edges
   (b), and are used for their formation, where the points P1 and P2 define
   the boundary of the edge E1, the points P2 and P3 define the boundary of
   the edge E2, etc. Then the same previously defined edges E1, E2, E3, and
   E4 define the boundary of the two-dimensional quadrilateral cell C1 (c).
   Each cell inside the grid is described the same way (source: [Thesis]_).

.. figure:: images/grid_structure_4.png
   :align: center
   :width: 500px

   An example of a connectivity array of a 2D unstructured quadrilateral grid
   (source: [Thesis]_).

^^^^^^^^^^^^
Grid subsets
^^^^^^^^^^^^

The grid subset, or subgrid, represents a portion of the contents of a larger
full grid, usually intended for a more accurate analysis of an exactly specified
piece of the grid. Each grid subset is defined by objects of only one type,
that being either points/nodes, lines/edges, or surfaces/two-dimensional
cells, etc.


.. figure:: images/AUG_2.png
   :align: center
   :width: 250px

   Tokamak ASDEX Upgrade: 2D unstructured quadrilateral grid.
   (source: [Thesis]_).

.. figure:: images/AUG_1.png
   :align: center
   :width: 250px

   Tokamak ASDEX Upgrade: SOLPS simulation domain regions - grid subsets:
   **Core**, **SOL**, **Inner Divertor**, **Outer Divertor** and **Seperatrix**.
   (source: [Thesis]_).

--------------------------------
Review of the GGD (sub)structure
--------------------------------

The GGD structure is present within many Interface Data Structures (IDSs)
found in the Data Dictionary (DD) [DD_git]_.

:guilabel:`GGD` term is being used to refer to both :guilabel:`grid_ggd(:)` and
:guilabel:`ggd(:)`
Arrays of Structures (AOS). At first, there was only a :guilabel:`ggd(ti)` AOS
which contained both grid description and physical quantities for given
timeslice ``ti``.
As in many cases, the grid is static e.g. it doesn't change through time
rewriting it for each time slice is unnecessary and space consuming. For those
reasons, with the IMAS 3.15.1 release (see [IMAS_releases]_), the grid was moved
out to a separate AOS, the same tree-hierarchy-level as the :guilabel:`ggd` AOS,
named :guilabel:`grid_ggd`.

.. figure:: images/edge_profiles-grid_ggd-ggd.png
   :align: center
   :width: 450px

   :guilabel:`grid_ggd` and :guilabel:`ggd` AOSs located within the
   :guilabel:`edge_profiles` IDS hierarchical tree structure (as seen in
   the Oxygen XML Editor).

^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The :guilabel:`grid_ggd` AOS
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The :guilabel:`grid_ggd` AOS holds the grid description for different time
slices. In case the grid does not change with time it is enough to fill
grid description only for the first "time slice". Note that the readers
(methods, routines, etc.) must be aware of this!

.. figure:: images/grid_ggd_AOS.png
   :align: center
   :width: 400px

   Overview of the :guilabel:`grid_ggd` AOS displaying :guilabel:`identifier`
   node, :guilabel:`space` AOS, :guilabel:`grid_subset` AOS and :guilabel:`time`
   node (as seen in the Oxygen XML Editor).

It consists of :guilabel:`identifier` node, :guilabel:`space` AOS,
:guilabel:`grid_subset` AOS and :guilabel:`time` node.

"""""""""""""""""""""""""""
:guilabel:`identifier` node
"""""""""""""""""""""""""""

The :guilabel:`identifier` node holds information on the grid, see
:dd:identifier:`ggd_identifier` for the possible values.

- :guilabel:`name` leaf (:dd:data_type:`STR_0D`), holding the name of the grid,
- :guilabel:`index` leaf (:dd:data_type:`INT_0D`), holding the grid index correlating with the
  time slices (starting with index 1), and
- :guilabel:`description` leaf (:dd:data_type:`STR_0D`), holding the custom description of the
  grid.

.. figure:: images/grid_ggd-identifier_node.png
   :align: center
   :width: 350px

   Overview of the grid :guilabel:`identifier` node displaying :guilabel:`name`,
   :guilabel:`index` and :guilabel:`description` nodes (as seen in the Oxygen
   XML Editor).

"""""""""""""""""""""
:guilabel:`space` AOS
"""""""""""""""""""""

The :guilabel:`space` AOS holds information on the various spaces of the grid:

- :guilabel:`identifier` node, holding basic information for given space,
- :guilabel:`geometry_type` node, defining type of space geometry,
- :guilabel:`coordinates_types` leaf (:dd:data_type:`INT_0D`), holding coordinates IDs that are
  being used to define given space. The coordinate IDs can be found in
  :dd:identifier:`coordinate_identifier` or
  **$IMAS_PREFIX/include/cpp/coordinate_identifier.h**. For example, ID 1
  describes first Cartesian
  coordinate in the horizontal plane - x[m] , ID 2 describes second cartesian
  coordinate in the horizontal plane - y[m], etc.
- :guilabel:`objects_per_dimension` AOS, holding definition of the space
  objects for every dimension. For example, ``objects_per_dimension(1)``
  (note: Fortran notation, index starting with 1) holds the description on the
  **0D objects - points/nodes/vertices**; ``objects_per_dimension(2)`` holds
  the description on **1D objects - lines/edges**, ``objects_per_dimension(3)``
  holds the description on **2D objects - surfaces**,
  ``objects_per_dimension(4)`` holds information on **3D objects - volumes**,
  etc.

.. figure:: images/space_AOS.png
   :align: center
   :width: 500px

   Overview of the :guilabel:`space` AOS displaying :guilabel:`identifier` node,
   :guilabel:`geometry_type` node, :guilabel:`coordinates_types` leaf and
   :guilabel:`objects_per_dimension` AOS (as seen in the Oxygen
   XML Editor).

'''''''''''''''''''''''''''
:guilabel:`identifier` node
'''''''''''''''''''''''''''

The :guilabel:`identifier` node holds information on the space, see
:dd:identifier:`ggd_space_identifier` for the possible values.

- :guilabel:`name` leaf (:dd:data_type:`STR_0D`), holding the name of the space,
- :guilabel:`index` leaf (:dd:data_type:`INT_0D`), holding the space integer/index identifier
  (starting with index 1), and
- :guilabel:`description` leaf (:dd:data_type:`STR_0D`), holding the custom description of the
  space.

.. figure:: images/space_identifier_node.png
   :align: center
   :width: 400px

   Overview of the space :guilabel:`identifier` node displaying
   :guilabel:`name`, :guilabel:`index` and :guilabel:`description`
   nodes (as seen in the Oxygen XML Editor).

''''''''''''''''''''''''''''''
:guilabel:`geometry_type` node
''''''''''''''''''''''''''''''

The :guilabel:`identifier` node holds information on the geometry type used in
given space description:

- :guilabel:`name` leaf (:dd:data_type:`STR_0D`), holding the name of the geometry type,
- :guilabel:`index` leaf (:dd:data_type:`INT_0D`), holding the geometry type integer/index
  identifier, ``0`` for standard geometry, ``1`` for Fourier geometry, and
- :guilabel:`description` leaf (:dd:data_type:`STR_0D`), holding the custom description of the
  geometry type.

.. figure:: images/space_geometry_type_node.png
   :align: center
   :width: 400px

   Overview of the geometry_type :guilabel:`identifier` node displaying
   :guilabel:`name`, :guilabel:`index` and :guilabel:`description`
   nodes (as seen in the Oxygen XML Editor).

'''''''''''''''''''''''''''''''''''''
:guilabel:`objects_per_dimension` AOS
'''''''''''''''''''''''''''''''''''''

The :guilabel:`objects_per_dimension` AOS holds definition of
**all space objects in the domain** for each dimension. For example,
``objects_per_dimension(1)`` (note: Fortran notation, index starting with 1)
holds the description on the
**0D objects - points/nodes/vertices**; ``objects_per_dimension(2)`` holds
the description on **1D objects - lines/edges**, ``objects_per_dimension(3)``
holds the description on **2D objects - surfaces**,
``objects_per_dimension(4)`` holds information on **3D objects - volumes**,
etc.

Its child is :guilabel:`object` AOS. For `n` objects (for example, points)
there are `n` :guilabel:`object` structures. Each :guilabel:`object` structure
holds:

- :guilabel:`boundary` AOS, describing a set of `n-1` dimensional objects
  defining the boundary of given `n`-dimensional object. For example, for
  **2D object - surface**, the boundary would be defined by
  **1D objects - edges/lines**.
- :guilabel:`geometry` leaf (:dd:data_type:`FLT_1D`), describing geometry of the object through
  coordinates. This usually refers only to **0D objects**, higher dimensional
  objects have this leaf empty. This is an array, and its size depends on the
  **space** :guilabel:`coordinates_type` leaf. For example, in a case of one
  point with **X** and **Y** coordinates the :guilabel:`coordinates_type` leaf
  would hold coordinate IDs ``1`` and ``2`` while
  ``objects_per_dimension(1).object(1).geometry`` would hold an 1D array
  containing two float numbers defining the "value" of the **X** and **Y**
  coordinates.
- :guilabel:`nodes` leaf (:dd:data_type:`INT_0D`), describing which **0D objects** form this
  element. For example, in a case of a **2D object - surface** that is
  constructed by nodes 1, 2, 3, and 4, the :guilabel:`nodes` leaf would hold
  integers (object IDs) 1, 2, 3, and 4, referring to
  ``objects_per_dimension(1).object(1)``, ``object(2)``, ``object(3)`` and
  ``object(4)``, where object IDs are indices to navigate to ``object(i)``
  node.
- :guilabel:`measure` leaf (:dd:data_type:`FLT_0D`), describing the measure of the given
  object. For example, for **1D object - line/edge** -> **length**
  value, for **2D object - surface** -> **surface area** and
  **3D object - volume** -> **volume**.

.. figure:: images/objects_per_dimension_AOS.png
   :align: center
   :width: 600px

   Overview of the space :guilabel:`objects_per_dimension` AOS displaying
   :guilabel:`object` AOS and its children :guilabel:`boundary` AOS,
   :guilabel:`geometry` leaf, :guilabel:`nodes` leaf and :guilabel:`measure`
   leaf (as seen in the Oxygen XML Editor).

The child AOS of the :guilabel:`object` AOS is :guilabel:`boundary` AOS,
describing a set of :math:`{n-1}` dimensional objects defining the boundary of given
`n`-dimensional object which can additionally characterize the grid.
Boundary represents a list of :math:`{n-1}` dimensional components defining
the ``n`` dimensional object or bounds of the :math:`{n}` dimensional
object inside the grid. For example, the boundary of an **edge** object would
be **two points/nodes**, while the boundary of a **2D quadrilateral cell**
object would be **four edges**.
The :guilabel:`boundary` AOS children are:

- :guilabel:`index` leaf (:dd:data_type:`INT_0D`), defining index of given ``n-1`` dimensional
  object,
- :guilabel:`neighbours` leaf (:dd:data_type:`INT_1D`), defining neighbours of given ``n-1``
  dimensional boundary object.

.. figure:: images/boundary_AOS.png
   :align: center
   :width: 450px

   Overview of the :guilabel:`boundary` AOS and its children :guilabel:`index`
   leaf and :guilabel:`neighbours` leaf (as seen in the Oxygen XML Editor).

"""""""""""""""""""""""""""
:guilabel:`grid_subset` AOS
"""""""""""""""""""""""""""

The :guilabel:`grid_subset` AOS holds information on the various
**grid subsets** of the grid. The grid subset, or subgrid, represents a portion
of the contents of a larger full grid, usually intended for more accurate
analysis of an exactly specified piece of the grid, for example, inner divertor
region, outer divertor region etc.

Each grid subset is defined by objects of only one type, that being either
points or nodes, edges, surfaces, etc.

List of confirmed grid subset **labels** and their belonging **IDs** can be
found in :dd:identifier:`ggd_subset_identifier` or
**$IMAS_PREFIX/include/cpp/ggd_subset_identifier.h**.

The :guilabel:`grid_subset` AOS children are:

- :guilabel:`identifier` node, holding basic information on the grid subset,
- :guilabel:`dimension` leaf (:dd:data_type:`INT_0D`), defining dimension of the grid subset
  elements,
- :guilabel:`element` AOS, defining a set of elements defined by combination
  of objects from potentially all spaces,
- :guilabel:`base` AOS, defining set of bases for the grid subset, and
- :guilabel:`metric` node, defining metric of the canonical frame onto
  Cartesian coordinates.

.. figure:: images/grid_subset_AOS.png
   :align: center
   :width: 450px

   Overview of the :guilabel:`grid_subset` AOS and its children
   :guilabel:`identifier` node, :guilabel:`dimension` leaf,
   :guilabel:`element` AOS, :guilabel:`base` AOS and :guilabel:`metric` node.
   (as seen in the Oxygen XML Editor).

'''''''''''''''''''''''''''
:guilabel:`identifier` node
'''''''''''''''''''''''''''

The :guilabel:`identifier` node holds information on the grid subset,  see
:dd:identifier:`ggd_subset_identifier` for the possible values.

- :guilabel:`name` leaf (:dd:data_type:`STR_0D`), holding the **name/label** of the grid subset,
- :guilabel:`index` leaf (:dd:data_type:`INT_0D`), holding the **integer/index identifier**
  (starting with index 1), and
- :guilabel:`description` leaf (:dd:data_type:`STR_0D`), holding the custom description of the
  grid subset.

.. figure:: images/grid_subset_identifier_node.png
   :align: center
   :width: 350px

   Overview of the grid subset :guilabel:`identifier` node displaying
   :guilabel:`name`, :guilabel:`index` and :guilabel:`description`
   nodes (as seen in the Oxygen XML Editor).

'''''''''''''''''''''''
:guilabel:`element` AOS
'''''''''''''''''''''''

The :guilabel:`element` AOS is designed to contain data on each **element** of
the **same dimension**, forming the **grid subset**. Each element can be
formed by one or more **objects** and the data on the objects forming the
element is stored in its child
named :guilabel:`object AOS`. The relation between
**grid**, **grid subset**, **element**, and **object** is shown in figure below.

.. figure:: images/grid_subset_element_AOS.png
   :align: center
   :width: 550px

   Overview of the grid subset :guilabel:`element` AOS, its child
   :guilabel:`object` and its children :guilabel:`space`, :guilabel:`dimension`
   and :guilabel:`index` nodes (as seen in the Oxygen XML Editor).

.. figure:: images/grid_hierarchy_scheme.png
   :align: center
   :width: 300px

   Hierarchy scheme of grid and grid components (**grid subset**, **element**,
   **object**).

The children of the :guilabel:`object` AOS are:

- :guilabel:`space` leaf (:dd:data_type:`INT_0D`), representing index of the space from which
  that object is taken,
- :guilabel:`dimension` leaf (:dd:data_type:`INT_0D`), referring to the dimension of the
  object, and
- :guilabel:`index` leaf (:dd:data_type:`INT_0D`), defining the object index.

The :guilabel:`space`, :guilabel:`dimension` and :guilabel:`index` integers
represent a **navigation indicies** to navigate through
:guilabel:`grid_ggd(:).space` AOS ->
:guilabel:`grid_ggd(:).space(space_index).objects_per_dimension(dimension_index) .object(object_index)`.
This way we can get our **object** defining the **element** that composes
**grid subset**.

For example, in a case we have a grid subset composed by one **2D surface**,
this 2D surface would represent our **element**. 2D surface is then composed
by either **4 points** or **4 edges** - **objects**.

For direct examples and better insight on the relation between
**grid subsets**, **elements**, and **objects** check the :ref:`ggd-examples`.


''''''''''''''''''''''''''''''''''''''''''''''''
:guilabel:`base` AOS and :guilabel:`metric` node
''''''''''''''''''''''''''''''''''''''''''''''''

The :guilabel:`base` AOS contains a set of bases for the grid subset.
For each base, the structure describes the projection of the base vectors on
the canonical frame of the grid.

The :guilabel:`metric` node contains the metric of the canonical frame onto
Cartsian coordinates.

Both have children with the same labels and characteristics:

- :guilabel:`jacobian` node (:dd:data_type:`FLT_1D`)
- :guilabel:`tensor_covariant` node (:dd:data_type:`FLT_3D`)
- :guilabel:`tensor_contravariant` node (:dd:data_type:`FLT_3D`)

.. figure:: images/grid_subset_base_metric.png
   :align: center
   :width: 450px

   Overview of the grid subset :guilabel:`base` AOS and :guilabel:`metric` node
   (as seen in the Oxygen XML Editor).

^^^^^^^^^^^^^^^^^^^^^^^
The :guilabel:`ggd` AOS
^^^^^^^^^^^^^^^^^^^^^^^

The :guilabel:`ggd` AOS holds the plasma quantities represented using the
**Generalized Grid Description** for various time slices. The quantities
correspond directly to one of the grid subsets (e.g. 100 values corresponding to
grid subset composed by 100 points). :guilabel:`ggd` AOS contents differ
between IDSs and usually it contains many child nodes/AOSs however the same
rules apply to all.

The most common :guilabel:`ggd` child nodes/AOS are the :guilabel:`electrons`
node and :guilabel:`ions` AOS. There can be many different ion species and each
ion specie refers to one structure of the :guilabel:`ions` AOS
(``...ion(ion_specie_index)``).

.. figure:: images/edge_profiles-ggd.png
   :align: center
   :width: 750px

   Overview (partial) of the :guilabel:`edge_profiles` IDS :guilabel:`ggd` AOS
   with belonging children including :guilabel:`electrons` node and
   :guilabel:`ions` AOS (as seen in the Oxygen XML Editor).

In continuation of this guide only the :guilabel:`electrons` node will be
presented as for other siblings the same rules apply.

""""""""""""""""""""""""""
:guilabel:`electrons` node
""""""""""""""""""""""""""

The :guilabel:`electrons` node holds plasma quantities related to
electrons, as implied in the label of the node. It contains many child
AOSs, as seen in the figure below. For all of those AOSs the same rules
apply (for so called **generic grid scalar** node type). In this guide
the **electron temperature** - :guilabel:`temperature` AOS will be looked into.

.. figure:: images/edge_profiles-ggd-electrons.png
   :align: center
   :width: 750px

   :guilabel:`electrons` node with its underlying children AOS that describe
   quantities related to electrons (as seen in the Oxygen XML Editor).

'''''''''''''''''''''''''''
:guilabel:`temperature` AOS
'''''''''''''''''''''''''''

The :guilabel:`temperature` node holds plasma quantities related to (electron)
temperature. Its children are:

- :guilabel:`grid_index` leaf (:dd:data_type:`INT_0D`), holding index of the grid used to
  represent this quantity,
- :guilabel:`grid_subset_index` leaf (:dd:data_type:`INT_0D`), holding index of the grid
  subset the data is provided on (Each structure of :guilabel:`temperature`
  AOS corresponds to one of the grid subsets),
- :guilabel:`values` leaf (:dd:data_type:`FLT_1D`) holding values corresponding to the
  grid subset (**one value** per **element** in the grid subset), and
- :guilabel:`coefficients` leaf (:dd:data_type:`FLT_2D`) holding interpolation coefficients, to
  be used for a high precision evaluation of the physical quantity with finite
  elements, provided per element in the grid subset (first dimension).

.. figure:: images/temperature_AOS.png
   :align: center
   :width: 550px

   :guilabel:`temperature` AOS with its underlying children
   :guilabel:`grid_index`, :guilabel:`grid_subset_index`, :guilabel:`values`,
   and :guilabel:`coefficients` leaves (as seen in the Oxygen XML Editor).

:guilabel:`grid_index` and :guilabel:`grid_subset_index` indices are used to
**navigate** through ``...grid_ggd(grid index).grid_subset(grid_subset_index)``
and locate the corresponding grid subset definition. The :guilabel:`values`
holds :math:`{n}` values which correspond to
``...grid_ggd(grid index).grid_subset(grid_subset_index).element(1...n)``
elements.

.. [DD_git] Data Dictionary repository: https://github.com/iterorganization/IMAS-Data-Dictionary
.. [IMAS_releases] IMAS Data Dictionary releases: https://github.com/iterorganization/IMAS-Data-Dictionary/releases
.. [Thesis] M. Sc. Thesis: Visualisation of Fusion Data-Structures for Scrape-Off Layer Plasma Simulations, , University of Ljubljana, Faculty of Mechanical Engineering, September 2017
.. [JOREK] The JOREK non-linear MHD Code website: http://jorek.eu/

.. [Czarny-Huysmans-2008] O. Czarny, G. Huysmans, J.Comput.Phys 227, 7423 (2008) https://www.sciencedirect.com/science/article/pii/S0021999108002118

.. [VanVugt19] Daniël Cornelis van Vugt, thesis, Nonlinear coupled MHD-kinetic particle simulations of heavy impurities in tokamak plasmas, 2019 https://research.tue.nl/en/publications/nonlinear-coupled-mhd-kinetic-particle-simulations-of-heavy-impur
