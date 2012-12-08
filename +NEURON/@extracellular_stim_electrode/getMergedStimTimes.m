function [t_vec,all_stim] = getMergedStimTimes(objs)
%getMergedStimTimes  Merges all stimulus times from all electrodes
%   
%   [t_vec,all_stim] = extracellular_stim.mergeStimTimes(elec_objs)
%
%   OUTPUTS
%   ====================================================================
%   t_vec    : time vector in which to apply stimuli
%   all_stim : (times x electrodes), current levels for all
%               times in which a current level changes on any channel

nElecs = length(objs);

%TODO: Ensure stim data is actually set

%ELECTRODE MERGING
%==========================================================
%NOTE: For multiple electrodes, need to consolidate time
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


if  nElecs == 1
    %Great!, We're all set
    t_vec    = objs.time;
    all_stim = objs.scale(:); %Column vector
else
    
    %NOTE: This could be built into a function
    allTimes = cell(1,nElecs);
    allIDs   = cell(1,nElecs);
    for iElec = 1:nElecs
        allTimes{iElec} = objs(iElec).time;
        allIDs{iElec}   = iElec*ones(1,length(objs(iElec).time));
    end
    %---------------------------------------------
    
    allTimes_v = [allTimes{:}];
    allIDS_v   = [allIDs{:}];
    [t_vec,uI] = unique2(allTimes_v);
    
    nStimTimes      = length(t_vec);
    
    %NOTE: If an electrodes not change its 
    %stim pulse for a given unique time
    %then at that time we keep the stimulus amplitude it had
    %previously
    usePreviousMask = true(nStimTimes,nElecs);
    
    for iStim = 1:nStimTimes
        participating_ids = allIDS_v(uI{iStim});
        usePreviousMask(iStim,participating_ids) = false;
    end
    
    all_stim = zeros(nStimTimes,nElecs);
    for iElec = 1:nElecs
        curElecStimChangeIndex = 0;
        for iStim = 1:nStimTimes
            if usePreviousMask(iStim,iElec)
                all_stim(iStim,iElec) = all_stim(iStim-1,iElec);
            else
                %Need to figure out which stim to use :/
                curElecStimChangeIndex = curElecStimChangeIndex + 1;
                all_stim(iStim,iElec) = objs(iElec).scale(curElecStimChangeIndex);
            end
        end
    end
end
end