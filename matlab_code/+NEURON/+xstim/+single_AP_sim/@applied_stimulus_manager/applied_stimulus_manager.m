classdef applied_stimulus_manager < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.applied_stimulus_manager
    %
    %   Held by:
    %   NEURON.xstim.single_AP_sim.predictor AS stimulus_manager
    
    properties
        dim_reduction_options %NEURON.xstim.single_AP_sim.dim_reduction_options
        %
        %   This class provides a set of instructions on how to compute
        %   the low dimensional stimulus
        %
        applied_stimulus_matcher %NEURON.xstim.single_AP_sim.applied_stimulus_matcher
    end
    
    properties
        p
        new_data
        old_data
    end

    properties (Access = private)
        %.getLowDStimulusInfo()
        low_d_initialized = false
        old_stimuli  %Class: NEURON.xstim.single_AP_sim.applied_stimuli
        new_stimuli  %"      "
    end
    
% % %     properties
% % %         original_old_stimuli
% % %     end
    
    methods
        function obj = applied_stimulus_manager(p_obj,xstim_obj,new_data,old_data)

            obj.p        = p_obj;
            obj.new_data = new_data;
            obj.old_data = old_data;   
            
            obj.dim_reduction_options = NEURON.xstim.single_AP_sim.dim_reduction_options;
            obj.applied_stimulus_matcher = NEURON.xstim.single_AP_sim.applied_stimulus_matcher(obj);
            

            obj.old_stimuli = obj.old_data.getAppliedStimulusObject(xstim_obj);
            obj.new_stimuli = obj.new_data.getAppliedStimulusObject(xstim_obj);
        end
    end
    
    %Incoming request methods =============================================
    methods 
        function getStimulusMatches(obj)
           %I want this to be the setup method
           %
           %    See Also:
           %    #OBJ.applyStimulusMatchInfo
            obj.applied_stimulus_matcher.getStimulusMatches(); 
        end
        function reducePointsToSolveByMatchingStimuli(obj)
            obj.applied_stimulus_matcher.applyStimulusMatchInfo();
        end
    end
    
    %Methods for the applied stimulus matcher ...
    %----------------------------------------------------------------------
    methods
        function [low_d_old,low_d_new] = getLowDStimulusInfo(obj)
            %
            %
            %   See Also:
            %   NEURON.xstim.single_AP_sim.applied_stimuli
            %   
            %
            %   FULL PATH:
            %   NEURON.xstim.single_AP_sim.applied_stimulus_manager.getLowDStimulusInfo
            
            if ~obj.low_d_initialized
               obj.old_stimuli.initializeReducedDimStimulus(obj.new_stimuli,obj.dim_reduction_options);
               obj.low_d_initialized = true;
            end
            low_d_old = obj.old_stimuli.getLowDStimulus();
            low_d_new = obj.new_stimuli.getLowDStimulus();
        end
        function setSameAsOld(obj,new_indices,old_indices) 
           obj.p.setSameAsOld(new_indices,old_indices)
        end
    end
    
end

