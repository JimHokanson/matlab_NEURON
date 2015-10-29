function [dual_counts,single_counts,stim_amplitudes,extras] = getCountData(obj,...
    max_stim_level,electrode_locations,stim_widths,fiber_diameters,varargin)
%getCountData
%
%   [dual_counts,single_counts,stim_amplitudes,extras] = getCountData(obj,...
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
%                         an integer. 
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
%
%   OPTIONAL INPUTS
%   =======================================================================
%   stim_resolution : (default 0.1) 
%
%
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
%   extras : This became a bit of a catch all for things that I needed ...
%       Example ------
%       dual_slice_thresholds: {1x5 cell}
%              dual_slice_xyz: {{1x3 cell}  {1x3 cell}  {1x3 cell}  {1x3 cell}  {1x3 cell}}
%     single_slice_thresholds: {1x5 cell}
%            single_slice_xyz: {{1x3 cell}  {1x3 cell}  {1x3 cell}  {1x3 cell}  {1x3 cell}}
%           internode_lengths: [1 x n]
%
%   See Also:
%       NEURON.simulation.extracellular_stim.create_standard_sim.
%       NEURON.simulation.extracellular_stim.create_standard_sim.sim__getActivationVolume
%   

extras = struct;

in.stim_resolution = 0.1;
in.custom_setup    = '';  %Not yet implemented 
in = NEURON.sl.in.processVarargin(in,varargin);

in.stim_resolution = abs(in.stim_resolution);

SINGLE_ELECTRODE_PAIRING = obj.ALL_ELECTRODE_PAIRINGS{1};
STIM_START_TIME          = 0.1;
PHASE_AMPLITUDES         = [-1 0.5];

SLICE_DIM_USE   = 2;
SLICE_DIM_VALUE = 0;

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
%TODO: Should be static method of activaton object ...
n_stim        = length(1:in.stim_resolution:max_stim_level);


single_counts           = zeros(n_stim,n_conditions);
single_slice_thresholds = cell(1,n_conditions);
single_slice_xyz        = cell(1,n_conditions);
internode_lengths       = zeros(1,n_conditions);

%We save some time if we can use the same act_obj for all instances of the
%single electrode case
if all(fiber_diameters) == fiber_diameters(1) && ...
    all(cellfun(@(x) isequal(x,stim_widths{1}),stim_widths))

    [act_obj,internode_length] = helper__getActivationObjectInstance(obj,fiber_diameters(1),...
        stim_widths{1},PHASE_AMPLITUDES,SINGLE_ELECTRODE_PAIRING,STIM_START_TIME);

    use_single_act_obj = true;
else
    use_single_act_obj = false; 
end


for iBase = 1:n_conditions
    
    fprintf('Running Base Condition %d/%d\n',iBase,n_conditions);
    
    if ~use_single_act_obj
    [act_obj,internode_length] = helper__getActivationObjectInstance(obj,fiber_diameters(iBase),...
        stim_widths{iBase},PHASE_AMPLITUDES,SINGLE_ELECTRODE_PAIRING,STIM_START_TIME);
    end
    
    %NEURON.simulation.extracellular_stim.results.activation_volume.getVolumeCounts
    single_counts(:,iBase) = act_obj.getVolumeCounts(max_stim_level,...
        'replication_points',electrode_locations{iBase},'stim_resolution',in.stim_resolution);
    
    [single_slice_thresholds{iBase},single_slice_xyz{iBase}] = ... 
        act_obj.getSliceThresholds(max_stim_level,SLICE_DIM_USE,SLICE_DIM_VALUE,'replication_points',electrode_locations{iBase});
    
    internode_lengths(iBase) = internode_length;
    
    %TODO: Retrieve threshold image at y = 0, and full extents of x & z
    %=> Need new activation_volume method ...
end


%Step 3 - Dual Stim Counts
%--------------------------------------------------------------------------
dual_counts             = zeros(n_stim,n_conditions);
dual_slice_thresholds = cell(1,n_conditions);
dual_slice_xyz        = cell(1,n_conditions);

for iDual = 1:n_conditions
    
    fprintf('Running Dual Stim Condition %d/%d\n',iDual,n_conditions);
    
    act_obj = helper__getActivationObjectInstance(obj,fiber_diameters(iDual),...
        stim_widths{iDual},PHASE_AMPLITUDES,electrode_locations{iDual},STIM_START_TIME);
    
    [dual_counts(:,iDual),temp_extras] = act_obj.getVolumeCounts(max_stim_level,'stim_resolution',in.stim_resolution);
    [dual_slice_thresholds{iDual},dual_slice_xyz{iDual}] = ... 
        act_obj.getSliceThresholds(max_stim_level,SLICE_DIM_USE,SLICE_DIM_VALUE);
    
end

stim_amplitudes = temp_extras.stim_amplitudes;

extras.dual_slice_thresholds   = dual_slice_thresholds;
extras.dual_slice_xyz          = dual_slice_xyz;
extras.single_slice_thresholds = single_slice_thresholds;
extras.single_slice_xyz        = single_slice_xyz;
extras.internode_lengths       = internode_lengths;

end

function [act_obj,internode_length] = helper__getActivationObjectInstance(obj,fiber_diameter,...
    stim_widths,PHASE_AMPLITUDES,electrode_locations,STIM_START_TIME)

xstim_obj = obj.instantiateXstim(electrode_locations);

xstim_obj.cell_obj.props_obj.changeFiberDiameter(fiber_diameter);

internode_length = xstim_obj.cell_obj.getAverageNodeSpacing;

xstim_obj.elec_objs.setStimPattern(STIM_START_TIME,stim_widths,PHASE_AMPLITUDES);

%NEURON.simulation.extracellular_stim.sim__getActivationVolume
%NEURON.simulation.extracellular_stim.results.activation_volume
act_obj   = xstim_obj.sim__getActivationVolume();

end