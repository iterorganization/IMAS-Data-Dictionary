.. _`introduction`:

Introduction
============

The IMAS Data Dictionary (DD) defines the standardized data structures used
for IMAS data.


IMAS overview
-------------

IMAS is the Integrated Modeling and Analysis Suite of ITER. It consists of
numerous infrastructure components, physics components and tools. An up-to-date
overview of these can be found at `<https://imas.iter.org/>`_ (ITER
Organization account required).

The IMAS core consists of:

1. Standardized data structures for storing experimental and simulation data.
2. Infrastructure for storing and loading these data structures.

Data dictionary
'''''''''''''''

The standardized data structures are defined in the Data Dictionary, of which
you are currently reading the documentation. The DD defines, for
example:

- :ref:`Which data structures (IDSs) exist <reference>`
- :ref:`What data is contained in these structures <data types>`
- :ref:`What units a data field has <units>`
- :ref:`What are the coordinates belonging to a data field <coordinates>`


Access layer
''''''''''''

The Access Layer provides the libraries for working with these data structures,
for example:

- Loading an IDS from disk
- Storing an IDS to disk
- Using and manipulating IDSs in your program

.. _`AL docs`:

The Access Layer has interfaces for the following programming languages. Click
on the link to go to the respective documentation pages:

- `Python
  <https://imas-python.readthedocs.io/en/stable/api.html>`_
- `C++ <https://sharepoint.iter.org/departments/POP/CM/IMDesign/Code%20Documentation/ACCESS-LAYER-doc/cpp/latest.html>`_
- `Fortran <https://sharepoint.iter.org/departments/POP/CM/IMDesign/Code%20Documentation/ACCESS-LAYER-doc/fortran/latest.html>`_
- `Java <https://sharepoint.iter.org/departments/POP/CM/IMDesign/Code%20Documentation/ACCESS-LAYER-doc/java/latest.html>`_
- `MATLAB <https://sharepoint.iter.org/departments/POP/CM/IMDesign/Code%20Documentation/ACCESS-LAYER-doc/matlab/latest.html>`_
