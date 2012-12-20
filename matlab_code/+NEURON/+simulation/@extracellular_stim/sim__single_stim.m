function [apFired,extras] = sim__single_stim(obj,scale)
%sim__single_stim
%
%   [apFired,extras] = sim__single_stim(obj,scale,varargin)
%
%   This function runs a single extracellular stimulation and returns the
%   result to the user.
%
%   INPUTS
%   =======================================================================
%   scale: This is the factor that gets multipled by the stimulus waveform
%          to determine the final stimulus amplitude. Units: uA
%   
%   OPTIONAL INPUTS
%   =======================================================================
%   save_data : (default false), if true the output populates additional
%               properties
%               TODO: This could be expanded to a class which
%               has specific properties that can be toggled as to whether
%               or not they should be returned (length, time, 
%               membrane voltage, etc)
%   complicated_analysis : (default false), if true in NEURON this does
%       some analysis to try and determine when the stimulus is too large
%       and subsequently inactivation is occuring. Otherwise the analysis
%       simply returns whether or not
%
%   OUTPUTS:
%   =======================================================================
%   apFired : numeric as to whether or not an AP was fired
%               0 - no
%               1 - yes
%               2??? - inhibition
%   extras  : (struct)
%       .vm    - membrane threshold, space x time, not sure of order of
%                dimensions
%       
%   NEURON FUNCTIONS
%   =======================================================================
%   xstim__run_stimulation
%
%   IMPROVEMENTS
%   =======================================================================
%   1) apFired should be made a class. Specifically this would allow for
%   more details as to the numeric values being returned. In addition we
%   could build in support for multiple stimuli where we might want to know
%   whether or not we received multiple action potentials. In addition we
%   could save the rules that were used for determining the result.
%
%   See Also:
%       sim__determine_threshold

%Important call to make sure everything is synced
initSystem(obj.ev_man_obj)

%c   = obj.cmd_obj;

%NOTE: This will need to be encapsulated into a function
obj.threshold_analysis_obj.run_stimulation(scale);



end