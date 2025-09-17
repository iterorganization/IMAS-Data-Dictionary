.. _dataentry_and_occurrence:

Data-Entry and Occurrence
==========================

Data-Entry
----------

A Data-Entry is a collection of IDSs (potentially all IDSs) and their multiple 
occurrences. It is a database concept that allows grouping and storing data 
(compliant to the IMAS data model) as a single dataset with a unique reference 
via an IMAS URI.

Occurrence
----------

There can be multiple instances, or "occurrences" of a given IDS in a data entry.
These occurrences can correspond to different methods for computing the physical 
quantities of the IDS, or to different functionalities in a workflow (e.g. initial 
values, prescribed values, values at next time step, …), or even to multiple 
subsystems (e.g. diagnostics) of the same type in a given experiment.