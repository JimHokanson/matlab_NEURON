function predictor_info = getThresholds(obj)


%1) Match based on applied stimulus
%---------------------------------------------------------------
%Our current approach will use the low d stimulus for redundancy testing ...
obj.initializeLowDStimulus();

%This will allow us to run less simulations if the stimuli match
%NOTE: Eventually we might want to be able to expand this to
%allow a roughly-equivalent method
%This could go in the same method with a switch flag
%to determine which method is used ...
obj.applied_stimulus_matcher.getStimulusMatches();

%2) Initialize groupings
%---------------------------------------------------------------

g = obj.grouper;

indices = g.getNextGroup();

while ~isempty(indices)
    
    predicted_thresholds = obj.predictThresholds(indices);
    
    threshold_result_obj = obj.getThresholdsFromSimulation(indices,predicted_thresholds);

    %NOT YET FINISHED
    threshold_result_obj.logResults();
    
    
    
    %Log results, analyze accuracy, update guessing accordingly ...
    indices = g.getNextGroup();

    if ~isempty(indices)
        
    end
end

%Remaining steps:
%1) Create prediction for indices to run
%    - this class will also for resolution updates ...
%2) Solve for indices
%3) Update results
%4) Create summary of how we did


keyboard

%possible early return
if obj.all_done
    return
end


end