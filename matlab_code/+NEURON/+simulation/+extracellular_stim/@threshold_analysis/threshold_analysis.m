classdef threshold_analysis < handle_light
    %
    %
    %   Class: NEURON.simulation.extracellular_stim.threshold_analysis
    %
    %
    %   IMPROVEMENTS:
    %   ===================================================================
    %   1) For propogation index, don't allow within a certain distance of
    %   the stimulation maximum. I'm not sure how to quantify this yet ...
    %
    %   ACCESS METHODS
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
    %   NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
    
    properties (Hidden)
        parent
        cmd_obj
    end
    
    %Threshold analysis options ===========================================
    properties
        %TODO: Set via options, class automatically created by parent
        %so we'll change settings via a separate method instead of adding
        %onto the parent constructor
        membrane_threshold = 0  %Value above which action potential
        propogation_index  = 1  %Index to check. Could allow negative values
        %Negative values not yet implemented ...
        
        no_stim_threshold         = Inf;
        infinite_stim_threshold   = 0;
        throw_error_for_edge_case = false;
    end
    
    properties (Constant, Hidden)
       FRIED_TISSUE_MESSAGE = 'out of range, returning exp(700)' 
    end
    
    %CONTSTRUCTOR =========================================================
    methods
        function obj = threshold_analysis(xstim_obj,cmd_obj)
            obj.parent  = xstim_obj;
            obj.cmd_obj = cmd_obj;
        end
    end

    methods
        function result_obj = run_stimulation(obj,scale)
            %run_stimulation
            %
            %   result_obj = run_stimulation(obj,scale)
            %
            %   OUTPUTS
            %   ===========================================================
            %   result_obj : Class NEURON.simulation.extracellular_stim.results.single_sim
            %
            %   Class:
            %   NEURON.simulation.extracellular_stim.threshold_analysis
            %
            
            result_obj = NEURON.simulation.extracellular_stim.results.single_sim;

            %Running the simulation
            str = sprintf('{xstim__run_stimulation2(%0g)}',scale);
            [result_obj.success,result_str] = obj.cmd_obj.run_command(str,'throw_error',false);
            
            %Determining if we used too large of a scale ...
            %--------------------------------------------------------------
            if result_obj.success
                result_obj.tissue_fried = false;
            else
                result_obj.tissue_fried = ~isempty(strfind(result_str,obj.FRIED_TISSUE_MESSAGE));
                if ~result_obj.tissue_fried
                   error(result_str) 
                else
                   return
                end
            end
            
            %Membrane threshold analysis
            %--------------------------------------------------------------
            %NOTE: This could get a lot more complicated with time varying
            %stimuli. For now we'll keep it simple ...
            vm = obj.parent.data_transfer_obj.getMembranePotential;
            
            max_vm_by_space = max(vm); %i.e. take max over time at each point in space
            
            result_obj.max_membrane_potential = max(max_vm_by_space);
            result_obj.membrane_potential     = vm;
            result_obj.threshold_crossed      = result_obj.max_membrane_potential > obj.membrane_threshold;
            result_obj.ap_propogated          = max_vm_by_space(obj.propogation_index) > obj.membrane_threshold;
            result_obj.max_vm_per_node        = max_vm_by_space;
        end
    end
end

