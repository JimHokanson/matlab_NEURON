function [t_vec,all_scales] = getMergedStimTimes(objs)
%getMergedStimTimes  Merges all stimulus times from all electrodes
%   
%   [t_vec,all_stim] = extracellular_stim.mergeStimTimes(elec_objs)
%
%   OUTPUTS
%   =======================================================================
%   t_vec      : time vector in which to apply stimuli
%   all_scales : (times x electrodes), current levels for all times in 
%                 which a current level changes on any channel
%
%	BACKGROUND
%   =======================================================================
%   In the end there is only a single stimulus applied to the cell, which
%   is a result of all electrodes present.
%
%      Need to ask for each what the current would be
%      at all change times
%
%    ex. stim times 1 2 3 4
%        stim 1     0   1
%        stim 2     0 1   0  <= current level
%    NOTE: stim 1 would have only 2 times, stim 2 only 3
%    We would need to have 4, where the props at the undefined
%    times for one are extended to the other
%        stim 1     0 0 1 1  <= currents extended to all time
%        stim 2     0 1 1 0  <= current level



n_electrodes = length(objs);

if ~all(objs.is_set)
   error('Stimuli for all objects must be set before running this method') 
end

if  n_electrodes == 1
    %Great!, We're all set
    t_vec    = objs.time;
    all_scales = objs.scale(:); %Column vector
else
    
    %NOTE: This could be built into a function
    %Step 1: Gather Information regarding timing
    %----------------------------------------------------------------------
    all_times = cell(1,n_electrodes);
    all_ids   = cell(1,n_electrodes);
    for iElec = 1:n_electrodes
        all_times{iElec} = objs(iElec).time;
        all_ids{iElec}   = iElec*ones(1,length(objs(iElec).time));
    end
    
    %Step 2: Combine and sort to get all unique times
    %----------------------------------------------------------------------
    allTimes_v = [all_times{:}];
    allIDS_v   = [all_ids{:}];
    
    %NOTE: Use of unique2 allows an efficient way of knowing which
    %electrodes contributed to each unique time
    [t_vec,uI] = unique2(allTimes_v);
    
    %Step 3: Use this information to create the variable - all_scales
    %----------------------------------------------------------------------
    n_unique_stim_times = length(t_vec);
    all_scales = zeros(n_unique_stim_times,n_electrodes);
    
    %This conceptually is really simple, it is too bad the code looks so
    %awful ... :/
    
    %use_previous_mask - for each entry in all_scales (the output) this
    %will represent whether or not to continue using the previous scale, or
    %whether or not the electrode has specified a new scale at the
    %transition time specified by the row index
    use_previous_mask = true(n_unique_stim_times,n_electrodes);
    
    for iStim = 1:n_unique_stim_times
        participating_ids = allIDS_v(uI{iStim});
        use_previous_mask(iStim,participating_ids) = false;
    end
    
    %Now for each electrode, we follow the instructions of the variable:
    %use_previous_mask
    for iElec = 1:n_electrodes
        cur_scale_index = 0;
        for iStim = 1:n_unique_stim_times
            if use_previous_mask(iStim,iElec)
                all_scales(iStim,iElec) = all_scales(iStim-1,iElec);
            else
                %Need to figure out which stim to use :/
                cur_scale_index = cur_scale_index + 1;
                all_scales(iStim,iElec) = objs(iElec).scale(cur_scale_index);
            end
        end
    end
end
end