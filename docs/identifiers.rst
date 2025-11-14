.. _`identifiers`:

Identifiers
===========

Identifiers are used to provide an enumerated list of options for defining, for example:

- A particular coordinate system, such as Cartesian, cylindrical, or spherical.
- A particle, which may be either an electron, an ion, a neutral atom, a molecule, a
  neutron, or a photon.
- Plasma heating may come from neutral beam injection, electron cyclotron heating, ion
  cyclotron heating, lower hybrid heating, alpha particles.

Identifiers are a list of possible valid labels. Each label has three representations:

1. An index (integer)
2. A name (short string)
3. A description (long string)

The list of possible labels for a given identifier structures can be found in the
:ref:`identifier reference`. In the :ref:`ids reference` you can find which identifier
structure is applicable.

The use of private indices or names in identifiers structure is discouraged, since this
would defeat the purpose of having a standard enumerated list. Please create a new discussion in `proposed changes 
<https://github.com/iterorganization/IMAS-Data-Dictionary/discussions/categories/proposed-changes>`_ when you want to add a
new identifier value.
