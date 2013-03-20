function [dual_counts,single_counts,stim_amplitudes] = getCountData(obj,...
    max_stim_level,electrode_locations,stim_widths,fiber_diameters,varargin)
%getCountData
%
%   [dual_counts,single_counts,stim_amplitudes] = getCountData(obj,...
%                   max_stim_level,electrode_locations,stim_widths,fiber_diameters,varargin)
%
%   This method computes the volume of tissue activated for the specified
%   set of input conditions. It also computes the volume of tissue
%   activated given the same set of conditions but with single electrodes
%   at each electrode location for the multiple electrode condition. In the
%   single electrode case the threhsolds are for independent
%   (non-temporally aligned stimuli) with overlaps only counted once and
%   the threshold value used being the minimum of all overlapping points.
%
%   INPUTS
%   =======================================================================
%   max_stim_level      : Max stimulus amplitude (can be + or -), must be
%                         an integer
%
%   NOTE: The three values below can either match the maximum # of
%   conditions to test, or can be singular.
%
%   electrode_locations : (units um) cell array, each cell should contain a matrix
%                         describing the locations of electrodes to test.
%                         [electrodes x xyz]
%   stim_widths         : (units ms) cell array, for details on the valid contents of
%                         each cell, see:
%       NEURON.simulation.extracellular_stim.electrode.setStimPattern
%   fiber_diameters     : (units um) vector
%
%   OPTIONAL INPUTS
%   =======================================================================
%
%   OUTPUTS
%   =======================================================================
%   dual_counts     : [stim amps x conditions], # of points in volume with
%           threshold values below each stimuluation amplitude for multiple
%           electrode case.
%   single_counts   : "         " single electrode case, replicated to each
%                       electrode location in dual_counts.
%   stim_amplitudes : Stimulus amplitudes used for outputs given
%                       max_stim_level input.
%
%   2)

in.stim_resolution = 0.5;
in = processVarargin(in,varargin);

SINGLE_ELECTRODE_PAIRING = obj.ALL_ELECTRODE_PAIRINGS{1};
STIM_START_TIME          = 0.1;
PHASE_AMPLITUDES         = [-1 0.5];

%MLINT
%==========================================================================
%#ok<*CTPCT> = warning about error strings
%Note that Code Analyzer can display this message erroneously for error or
%warning functions, because Code Analyzer is also trying to determine
%whether the first argument is a message ID or a format string.

assert(round(max_stim_level) == max_stim_level,'max_stim_level must be an integer')
assert(iscell(electrode_locations),'Electrode locations input must be a cell array')
assert(iscell(stim_widths),'Stim widths input must be a cell array')
assert(isvector(fiber_diameters),'Fiber diameters input must be a vector')

in.stim_resolution = abs(in.stim_resolution);

if max_stim_level < 0
    stim_amplitudes_original = -1:-1:max_stim_level;
    stim_amplitudes_final    = -1:-1*in.stim_resolution:max_stim_level;
else
    stim_amplitudes_original = 1:max_stim_level;
    stim_amplitudes_final    = 1:in.stim_resolution:max_stim_level;
end
stim_amplitudes = stim_amplitudes_final; %populate output

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
n_stim        = max_stim_level; %1:max_stim_level
single_counts = zeros(n_stim,n_conditions);

%We save some time if we can use the same act_obj for all instances of the
%single electrode case
if all(fiber_diameters) == fiber_diameters(1) && ...
    all(cellfun(@(x) isequal(x,stim_widths{1}),stim_widths))

    act_obj = helper__getActivationObjectInstance(obj,fiber_diameters(1),...
        stim_widths{1},PHASE_AMPLITUDES,SINGLE_ELECTRODE_PAIRING,STIM_START_TIME);

    use_single_act_obj = true;
else
    use_single_act_obj = false; 
end


for iBase = 1:n_conditions
    
    fprintf('Running Base Condition %d/%d\n',iBase,n_conditions);
    
    if ~use_single_act_obj
    act_obj = helper__getActivationObjectInstance(obj,fiber_diameters(iBase),...
        stim_widths{iBase},PHASE_AMPLITUDES,SINGLE_ELECTRODE_PAIRING,STIM_START_TIME);
    end
    
    single_counts(:,iBase) = act_obj.getVolumeCounts(max_stim_level,...
        'replication_points',electrode_locations{iBase});
end


%Step 3 - Dual Stim Counts
%--------------------------------------------------------------------------
dual_counts = zeros(n_stim,n_conditions);

for iDual = 1:n_conditions
    
    fprintf('Running Dual Stim Condition %d/%d\n',iDual,n_conditions);
    
    act_obj = helper__getActivationObjectInstance(obj,fiber_diameters(iDual),...
        stim_widths{iDual},PHASE_AMPLITUDES,electrode_locations{iDual},STIM_START_TIME);
    
    dual_counts(:,iDual) = act_obj.getVolumeCounts(max_stim_level);
    
end

%Step 4 - Interpolation of results
%--------------------------------------------------------------------------
n_stim_final = length(stim_amplitudes_final); 
single_counts_interpolated = zeros(n_stim_final,n_conditions);
dual_counts_interpolated   = zeros(n_stim_final,n_conditions);

for iCondition = 1:n_conditions
    single_counts_interpolated(:,iCondition) = interp1(stim_amplitudes_original(:),...
                single_counts(:,iCondition),stim_amplitudes_final(:),'pchip');
    dual_counts_interpolated(:,iCondition) = interp1(stim_amplitudes_original(:),...
                dual_counts(:,iCondition),stim_amplitudes_final(:),'pchip');        
end

dual_counts   = dual_counts_interpolated;
single_counts = single_counts_interpolated; 

end

function act_obj = helper__getActivationObjectInstance(obj,fiber_diameter,...
    stim_widths,PHASE_AMPLITUDES,electrode_locations,STIM_START_TIME)

options = {...
    'electrode_locations',electrode_locations,...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

xstim_obj.cell_obj.props_obj.changeFiberDiameter(fiber_diameter);
xstim_obj.elec_objs.setStimPattern(STIM_START_TIME,stim_widths,PHASE_AMPLITUDES);

act_obj   = xstim_obj.sim__getActivationVolume();

end