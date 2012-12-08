%function notes
%{

Global variables:
==========================================================================
When using global variables in a function, the type of variable should be
defined before loading the function. It seems that on loading a function
the type is defined

EXAMPLE:
----------------------------------------------------------------------------
THIS WORKS: (ote xstim__load_data() uses sim_hash
strdef sim_hash
{load_file("hoc_code_library/extracellular_stim/xstim__load_data.hoc")}
sim_hash = "blah"
xstim__load_data()

THIS DOESN'T
{load_file("hoc_code_library/extracellular_stim/xstim__load_data.hoc")}
strdef sim_hash
sim_hash = "blah"
xstim__load_data()















%}