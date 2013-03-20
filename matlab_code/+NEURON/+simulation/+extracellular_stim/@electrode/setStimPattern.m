function setStimPattern(objs,start_times,phase_durations,phase_amplitudes)
%setStimPattern
%
%   setStimPattern(objs,start_times,phase_durations,phase_amplitudes)
%
%   This method allows specification of the stimulus as a
%   series of fixed amplitude stimulus phases which start at a
%   given time after the start of the simulation.
%
%   INPUTS ===============================================================
%   objs             : 1 or more object instances
%   start_times      : (ms) Start of the stimulus
%   phase_durations  : (ms) (singular vector or cell array of arrays)
%                        Duration of each stimulus phase
%   phase_amplitudes : (uA) See notes on stimulus amplitude
%
%   EXAMPLES
%   ======================================================================
%   setStimPattern(objs,0.1,[0.2 0.1],{[1 -0.5] [-1 0.5]})
%
%   FULL PATH:
%   NEURON.simulation.extracellular_stim.electrode.setStimPattern
%
%   TODO
%   -------------------------------------
%   1) Update documentation to reflect the different types of inputs that
%   can be specified for start_times, phase_durations, and
%   phase_amplitudes.
%   

n_electrodes = length(objs);

%INPUT CHECKING
%==========================================================================

%Start Time Checking
%--------------------------------------------------------------------------
if length(start_times) ~= n_electrodes
    if length(start_times) == 1
        start_times = repmat(start_times,1,n_electrodes);
    else
        error('# of start time values must match the # of input electrodes or be singular')
    end
end

assert(all(start_times > 0),'Start times must occur after time 0');

%Phase duration checking
%--------------------------------------------------------------------------
if isempty(phase_durations)
    error('Phase durations may not be empty')
elseif iscell(phase_durations)
    if length(phase_durations) == n_electrodes
        %Great do nothing
    elseif length(phase_durations) == 1
        phase_durations = repmat(phase_durations,1,n_electrodes);
    else
        error('# of phase duration specifications must match the # of electrode or be singular')
    end
elseif isvector(phase_durations)
    phase_durations = repmat({phase_durations},1,n_electrodes);
else
    error('Unrecognized input format for phase duration input')
end

assert(all(cellfun(@(x) all(x > 0),phase_durations)),...
    'All phase durations must be greater than 0')

%Phase amplitude checking
%--------------------------------------------------------------------------
if isempty(phase_amplitudes)
    error('Phase amplitudes may not be empty')
elseif iscell(phase_amplitudes)
    if length(phase_amplitudes) == n_electrodes
        %Great do nothing
    elseif length(phase_amplitudes) == 1
        phase_amplitudes = repmat(phase_amplitudes,1,n_electrodes);
    else
        error('# of phase amplitude specifications must match the # of electrode or be singular')
    end
elseif isvector(phase_amplitudes)
    phase_amplitudes = repmat({phase_amplitudes},1,n_electrodes);
else
    error('Unrecognized input format for phase amplitude input')
end

if any(cellfun(@(x,y) length(x) ~= length(y),phase_amplitudes,phase_durations))
    %This is specifically checking on a per electrode basis, not on the
    %original electrodes.
    error('All phase amplitude and phase duration inputs must have the same length')
end

%Assignment
%==========================================================================
for iElec = 1:n_electrodes
    %NOTE: We ensure taking care of start times and end times
    cur_start_time       = start_times(iElec);
    cur_phase_durations  = phase_durations{iElec};
    cur_phase_amplitudes = phase_amplitudes{iElec};
    
    objs(iElec).stimulus_transition_times  = [0 cur_start_time cur_start_time + cumsum(cur_phase_durations)];
    objs(iElec).base_amplitudes            = [0 cur_phase_amplitudes 0]; %Start at 0, end at 0
end

objectChanged(objs)

end