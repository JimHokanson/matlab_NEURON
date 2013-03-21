%{
Installation Instructions
%--------------------------------------------------------------------------

1) Initialize.m needs to be called to setup the path. For users with access
to the RNEL library one can specify to add the NEURON toolbox in their user
constants.
    => C.GIT_TOOLBOX_ROOT
    => C.GIT_TOOLBOXES_LOAD_ON_START

2) Windows users require specification of a compiler.



2) The executable path should be specified in the user constants or as a
constant in the class NEURON.paths
3) Make sure the line NEURON.init_system is added to startup
    NOTE: I might add this to the NEURON constructor so that
    there is less work to do to get things setup


Pathing Considerations
---------------------------------------------------------------------------


%}