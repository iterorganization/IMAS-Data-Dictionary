Coordinate conventions
======================

COCOS
-----

This version of the IMAS Data Dictionary corresponds to COCOS = |cocos| coordinate convention.

.. caution::
     Major version 4 corresponds to COCOS = 17, while major version 3 corresponds to COCOS = 11.

The COCOS (Coordinate COnvetionS for 3D current and magnetic fields) conventions
are described in detail in: `O. Sauter and S.Yu. Medvedev, Computer Physics
Communications 184 (2013) 293
<https://crppwww.epfl.ch/~sauter/COCOS/Sauter_COCOS_Tokamak_Coordinate_Conventions.pdf>`_.

More information is also available on `the web page of O. Sauter
<https://crppwww.epfl.ch/~sauter/COCOS/>`_.


Cylindrical coordinate convention
---------------------------------

For conversion between cylindrical :math:`(R,\phi,Z)` and Cartesian
:math:`(X,Y,Z)` coordinates, IMAS follows the `ISO 31-11 standard
<https://en.wikipedia.org/wiki/ISO_31-11>`_: the origin and Z axis align
and the X axis corresponds to :math:`\phi=0`.


.. todo::
    Add transformations to reference

    -   cocos_alias
    -   cocos_label_transformation
    -   cocos_leaf_name_aos_indices
    -   cocos_replace
    -   cocos_transformation_expression
