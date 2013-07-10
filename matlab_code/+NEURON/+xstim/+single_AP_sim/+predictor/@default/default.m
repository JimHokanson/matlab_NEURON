classdef default < NEURON.xstim.single_AP_sim.predictor
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.predictor.default
    %
    %
    %   Possible options to support
    %   -------------------------------------------------------------------
    %   1) Threshold prediction based on neighboring spatial locations ...
    %       - use gridfit 3d
    %   2) Determining what to learn next
    %   3) When to stop full solution and just use estimates ...
    %
    %
    %
    %
    %
    %
    
    %OPTIONS - eventually move these to a class
    %----------------------------------------------------------------------
    properties
        
    end
    
    methods
        function predictor_info = getThresholds(obj)
            
           %PIPELINE
           %---------------------------------------------------------------
           
           
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
           
           keyboard
           
           %2) Initialize groupings
           %---------------------------------------------------------------
           
           %possible early return
           if obj.all_done
              return 
           end
           
           
        end
    end
    
end

