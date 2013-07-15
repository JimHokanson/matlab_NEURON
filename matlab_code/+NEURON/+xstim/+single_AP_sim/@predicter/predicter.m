classdef predicter < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.predicter
    %
    
    properties
        s
        opt__min_prediction_size = 20; %Minimum # of elements
        %that must be known before we attempt to do prediction ...
        opt__default_prediction_magnitude = 1; %When we can't 
    end
    
    properties
        initialized = false
        old_low_d_stimulus  %Unique full set
        old_thresholds      
        new_low_d_stimulus  %Full set, we'll decimate as necessary
        %when doing predictions
    end
    
    methods
        function obj = predicter(s_obj)
            obj.s = s_obj;
        end
        function reset(obj)
           obj.initialized = false; 
        end
        function initialize(obj)
            
            stim_manager   = obj.s.stimulus_manager;
            old_data_local = obj.s.old_data;
            
            [old_stim,obj.new_low_d_stimulus] = stim_manager.getLowDStimulusInfo();
            
            if isempty(old_stim)
                obj.old_low_d_stimulus = [];
                obj.old_thresholds     = [];
            else
                unique_old_indices      = stim_manager.getUniqueOldIndices;
                obj.old_low_d_stimulus  = old_stim(unique_old_indices,:);
                obj.old_thresholds      = old_data_local.thresholds(unique_old_indices);
            end
            
            obj.initialized = true;
        end
        function [learned_low_d_stimuli,known_thresholds] = getLearnedLowDStimuliAndThresholds(obj)
            %This is a merger of the old stimuli
            %along with new stimuli for which we have threshold values

            new_data_local      = obj.s.new_data;
            %
            learned_new_indices = new_data_local.getIndicesOfUniqueStimuliWithKnownThresholds();
            
            if isempty(learned_new_indices) && isempty(obj.old_thresholds)
                learned_low_d_stimuli = [];
                known_thresholds            = [];
            elseif isempty(learned_new_indices)
                learned_low_d_stimuli = obj.old_low_d_stimulus;
                known_thresholds            = obj.old_thresholds;
            elseif isempty(obj.old_thresholds)
                learned_low_d_stimuli = obj.new_low_d_stimulus(learned_new_indices,:);
                known_thresholds            = new_data_local.thresholds(learned_new_indices);
            else
                learned_low_d_stimuli = [obj.old_low_d_stimulus; ...
                        obj.new_low_d_stimulus(learned_new_indices,:)];
                known_thresholds            = [obj.old_thresholds ...
                    new_data_local.thresholds(learned_new_indices)];
            end
        end
        function default_thresholds = getDefaultPrediction(obj,n)
           default_thresholds = obj.s.stim_sign*obj.opt__default_prediction_magnitude*ones(1,n); 
        end
    end
    
end

