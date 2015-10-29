classdef applied_stimulus_manager < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.applied_stimulus_manager
    %
    %   Held by the solver (parent) AS:
    %       stimulus_manager
    %
    %   This class is responsbile for anything related to the stimulus.
    %   
    %   
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.solver
    %   NEURON.xstim.single_AP_sim.applied_stimuli
    %   NEURON.xstim.single_AP_sim.dim_reduction_options
    %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher
    
    
    properties
        dim_reduction_options %NEURON.xstim.single_AP_sim.dim_reduction_options
        %
        %   This class provides a set of instructions on how to compute
        %   the low dimensional stimulus
        %
        applied_stimulus_matcher %NEURON.xstim.single_AP_sim.applied_stimulus_matcher
    end
    
    properties
        s   %SC: NEURON.xstim.single_AP_sim.solver
        %
        %   Needed for calling:
        %   .setSameAsOld()
        %
        new_data
        old_data
    end

    properties (SetAccess = private)
        %.getLowDStimulusInfo()
        low_d_initialized = false
        old_stimuli  %Class: NEURON.xstim.single_AP_sim.applied_stimuli
        new_stimuli  %"      "
    end
    
    methods
        function obj = applied_stimulus_manager(s_obj)
            obj.s        = s_obj;
            obj.dim_reduction_options    = NEURON.xstim.single_AP_sim.dim_reduction_options;
            obj.applied_stimulus_matcher = NEURON.xstim.single_AP_sim.applied_stimulus_matcher(obj);
        end
        function initialize(obj,xstim_obj,new_data,old_data)
            %
            %
            %   This method needs to be called any time the xyz data
            %   is changed in the solver.
            %
            %   See Also:
            %   
            obj.new_data = new_data;
            obj.old_data = old_data;  
            
            %NEURON.xstim.single_AP_sim.applied_stimuli
            obj.old_stimuli = obj.old_data.getAppliedStimulusObject(xstim_obj);
            obj.new_stimuli = obj.new_data.getAppliedStimulusObject(xstim_obj);
            obj.low_d_initialized = false;
            obj.applied_stimulus_matcher.reset();
        end
    end
    
    %Incoming request methods =============================================
    methods 
        function unique_old_indices = getUniqueOldIndices(obj)
            unique_old_indices = obj.applied_stimulus_matcher.getUniqueOldIndices();
        end
        function reducePointsToSolveByMatchingStimuli(obj)
            %NEURON.xstim.single_AP_sim.applied_stimulus_manager.reducePointsToSolveByMatchingStimuli
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
           obj.s.setSameAsOld(new_indices,old_indices);
        end
    end
    
end

