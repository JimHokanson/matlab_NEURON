function [dual_counts,single_counts] = getCountData(obj,...
    stim_amplitudes,electrode_locations,stim_widths,fiber_diameters)
%
%
%
%   stim_amplitudes     : vector, same for all inputs
%
%   electrode_locations : cell array
%   stim_widths         : cell array
%   fiber_diameters     : vector

%electrode_locations - cell array
%stim_amplitudes

SINGLE_ELECTRODE_PAIRING = obj.ALL_ELECTRODE_PAIRINGS{1};
STIM_START_TIME          = 0.1;
PHASE_AMPLITUDES         = [-1 0.5];

%MLINT
%==========================================================================
%#ok<*CTPCT> = warning about error strings
%Note that Code Analyzer can display this message erroneously for error or
%warning functions, because Code Analyzer is also trying to determine
%whether the first argument is a message ID or a format string.

assert(iscell(electrode_locations),'Electrode locations input must be a cell array')
assert(iscell(stim_widths),'Stim widths input must be a cell array')
assert(isvector(fiber_diameters),'Fiber diameters input must be a vector')

%Step 1 - replicate inputs if necessary
%--------------------------------------------------------------
n_e = length(electrode_locations);
n_w = length(stim_widths);
n_f = length(fiber_diameters);

n_conditions = max([n_e n_f n_w]);

base_error_str = ['Number of %s, %d is not singular and does not'...
    'match the max # of variations given: ' int2str(n_conditions)];

if n_e == 1
    electrode_locations = repmat(electrode_locations,[1 n_conditions]); 
elseif n_e ~= n_conditions
    error(base_error_str,'electrode locations',n_e) 
end

if n_w == 1
    stim_widths = repmat(stim_widths,[1 n_conditions]);
elseif n_w ~= n_conditions
    error(base_error_str,'stimulus widths',n_w)
end

if n_f == 1
    fiber_diameters = repmat(fiber_diameters,[1 n_conditions]);
elseif n_f ~= n_conditions
    error(base_error_str,'fiber diameters',n_f)
end

%Step 2 - Single Counts
%--------------------------------------------------------------------------
n_stim = length(stim_amplitudes);
single_counts  = zeros(n_stim,n_conditions);

for iBase = 1:n_conditions
options = {...
    'electrode_locations',SINGLE_ELECTRODE_PAIRING,...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

%Apply stim widths and fiber diameter
%Yikes - perhaps bring method out to cell
xstim_obj.cell_obj.props_obj.changeFiberDiameter(fiber_diameters(iBase));
xstim_obj.elec_objs.setStimPattern(STIM_START_TIME,stim_widths{iBase},PHASE_AMPLITUDES);

act_obj   = xstim_obj.sim__getActivationVolume();

single_counts(:,iBase) = act_obj.getVolumeCounts(stim_amplitudes,...
    'replication_points',electrode_locations{iBase}); 

end

keyboard

%Step 3 - Dual Stim Counts
%--------------------------------------------------------------------------
dual_counts = zeros(n_stim,n_conditions);

for iDual = 1:n_conditions
options = {...
    'electrode_locations',SINGLE_ELECTRODE_PAIRING,...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

%Apply stim widths and fiber diameter
%Yikes - perhaps bring method out to cell
xstim_obj.cell_obj.props_obj.changeFiberDiameter(fiber_diameters(iDual));
xstim_obj.elec_objs.setStimPattern(STIM_START_TIME,stim_widths{iDual},PHASE_AMPLITUDES);

act_obj   = xstim_obj.sim__getActivationVolume();

dual_counts(:,iBase) = act_obj.getVolumeCounts(stim_amplitudes); 

end


end