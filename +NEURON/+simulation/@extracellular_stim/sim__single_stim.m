function [apFired,extras] = sim__single_stim(obj,scale,varargin)
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
%               properties, TODO: This could be expanded to a class which
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

in.save_data = false;
in.complicated_analysis = false;
in = processVarargin(in,varargin);

%Important call to make sure everything is synced
initSystem(obj.ev_man_obj)

c   = obj.cmd_obj;
str = sprintf('ap_fired = xstim__run_stimulation(%0g,%d,%d)\n io__print_variable("ap_fired",ap_fired)',scale,in.save_data,in.complicated_analysis);
[~,result_str] = c.run_command(str);

apFired = str2double(c.extractSingleParam(result_str,'ap_fired'));
extras  = struct;

if in.save_data
   %TODO: This should be a wrapped method for the model
   %something like:
   %getData(obj,'membrane_voltage')
   %This would allow for handling of different process ids, if we ever do
   %parallel runs, as well as centralizing things in general
   root_path = fullfile(obj.cell_obj.getModelRootDirectory,'data');
   filepath  = fullfile(root_path,'extracellular_stim_mrg_vm.bin');
   extras.vm = c.loadMatrix(filepath);
end

end