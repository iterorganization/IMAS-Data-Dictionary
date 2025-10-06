The IDS *path* syntax to identify a part of an IDS
==================================================

Scope
-----

This document describes the syntax of the ***path*** that identifies a *part* of an IDS.
In this context a part can be defined by a given node (or node element in the case of an array of structure) 
with all its leaves, or by a single leaf of the IDS structure. As a reminder, nodes are structures or arrays 
of structure and leaves are quantities.

Parts that are represented by arrays (either arrays of structure or quantities) can be identified
as a whole (all the elements of the array), as a range (contiguous elements within two bounds) or 
as a single element.

While this document presents of few examples of *URI fragments* where an *idspath* can be specified,
please refer to the `IMAS URI scheme <IMAS-URI-scheme.html>`_ document for the full description of the URI syntax.


Syntax
------

An IDS *path* is represented by a string that respects the following rules:

- a slash ``/`` separates nested structures, the leading one indicates the root of an IDS
- quantities (scalar or arrays) as well as structures and arrays of structures are given by their name
- index of arrays (quantities and arrays of structure) can be given between round brackets ``()`` just after the array name
- round brackets ``()`` and **index specifiers** herein can be omitted for leaves/quantities, but are mandatory for arrays of structure
- if omitted for a quantity, the path covers all elements of the leaf array (which can be multidimensional)


Index and range specifiers
~~~~~~~~~~~~~~~~~~~~~~~~~~

The Data-Dictionary is using a **1-based indexing** (as in Fortran) and this is also the case for the indices in IDS paths.

Indexing and array slicing (which is not equivalent to the time slice operations in the data-access libraries) must respect the following rules, which are mostly the ones from Fortran 90, with the addition of indexing from the end and sets of indices:

- indices are specified within round brackets ``()`` that are appended to the name of the array
- for multidimensional arrays, each dimension is separated by a comma ``,``. E.g in 3D: ``(first dimension, second dimension, third dimension)``
- each dimension of an array must be addressed, with either:

  + a colon ``:`` operator (full slice) that indicates all elements for the dimension, e.g ``(:)`` corresponds to all elements of a 1D array (possibly an array of structures);
  + an integer that indicates a single element for the dimension, e.g ``(3,1)`` corresponds to the third element in the first dimension and the first element in the second dimension;
  + a set of indices can be specified by curly brackets ``{}`` (does not have to be monotonic increasing), e.g ``({1,5,3},:)`` indicates the first, fifth and third elements in the first dimension and all elements in the second dimension;
  + indexing from the end of the array is possible by using negative indices, e.g ``(-1)`` is the last elements (or think of it as the first element from the end);
  + indicating a range of elements is possible by adding an integer before the colon (corresponds to the first element included in the range, or lower bound, if omitted the range includes the start of the array) and/or after the colon (corresponds to the last element included in the range, or upper bound, if omitted the range includes the end at the array), e.g ``(2:5)`` indicates all elements between the second and the fifth, i.e ``({2,3,4,5})`` while ``(:5)`` is equivalent to ``({1,2,3,4,5})``;
  + using a stride is possible by adding another colon ``:`` specifier following the syntax ``lower_bound:upper_bound:stride``. If omitted, the range has a stride of ``1`` which means it contains all elements within the lower and the upper bound. E.g. ``(::2)`` corresponds to all odd indices while ``(2::2)`` corresponds to all even ones.


Use cases and examples
----------------------

An IDS *path* can be used in the following cases: 

- alone, it can be used as a value of some fields (string) in IDSs or as an argument of a ``partial_get`` operation from a data-access library;
- as part of a URI fragment to identify a specific subset of a given IDS in a given `data-entry <./dataentry_and_occurrence.html#data-entry>`_.


*idspath* or *fragment* as ``path`` field in IDSs
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In several places in the Data-Dictionary, specific string fields of an IDS allow references to be made to other fields in the same IDS. 
This is the case for instance of the field ``/ids_properties/provenance/node(:)/path``. In this field, an idspath is expected to point 
to a subset of the current IDS.

In other cases, the reference ``path`` field allows to point to a different IDS within the same `data-entry <./dataentry_and_occurrence.html#data-entry>`_ (e.g in ``grid_ggd(:)/path``). 
In such a case, the string following the syntax of idspath can point to a subset of the same IDS, or a subset of another IDS.
In the latter case, ``path`` can contain a *same-document* URI fragment (i.e. following the syntax ``#ids[:occurrence][/idspath]``). 
Refer to `URI syntax <IMAS-URI-scheme.html>`_ documentation for more information.


*idspath* in URI fragment
~~~~~~~~~~~~~~~~~~~~~~~~~

When *idspath* is given as a part of an IMAS URI, it is always contains the specific IDS (and optionally its `occurrence <./dataentry_and_occurrence.html#occurrence>`_) 
and follows the syntax ``#ids[:occurrence][/idspath]`` described in the `URI syntax <IMAS-URI-scheme.html>`_ documentation.


*idspath* as an argument of a ``partial_get`` operation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When given as an argument of the ``partial_get`` function of the Access-Layer, please refer to the `Access-Layer User Guide <https://user.iter.org/?uid=YSQENW&action=get_document>`_ 
to get more information about possible limitations of the supported languages and allowed comintations of range specifiers.
