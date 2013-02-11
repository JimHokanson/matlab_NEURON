classdef threshold_analysis < handle_light
    %
    %   Class: 
    %       NEURON.simulation.extracellular_stim.threshold_analysis
    %
    %   This class handles things related to analyzing stimulation data.
    %   Eventually it might need to be expanded to handle intracellular
    %   stimulation. In other words this would move to being a part of
    %   stimulation with possible subclassing for exracellular versus
    %   intracellular.
    %
    %
    %   IMPROVEMENTS:
    %   ===================================================================
    %   1) For propogation index, don't allow within a certain distance of
    %   the stimulation maximum. I'm not sure how to quantify this yet ...
    %   2) Move options into threshold options class
    %
    %   PUBLIC ACCESS METHODS
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
    %   NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.sim_determine_threshold
    %       NEURON.simulation.extracellular_stim.results.single_sim
    %       NEURON.simulation.extracellular_stim.results.threshold_testing_history
    
    properties (Hidden)
        parent
        cmd_obj
    end
    
    %Threshold analysis options ===========================================
    properties
        threshold_info %Class: NEURON.cell.threshold_info
    end
    
    properties (Constant, Hidden)
       %This is the string that is returned by NEURON when we apply a stimulus
       %that is too large. Instead of throwing an error often times we will
       %just indicate that the stimulus is too large. This is primarily
       %used by the .determine_threshold() code
       FRIED_TISSUE_MESSAGE = 'out of range, returning exp(700)' 
    end
    
    %CONTSTRUCTOR =========================================================
    methods
        function obj = threshold_analysis(xstim_obj,cmd_obj)
            obj.parent  = xstim_obj;
            obj.cmd_obj = cmd_obj;
        end
    end

    %METHODS IN OTHER FILES ===============================================
    %NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
    
    methods
        function result_obj = run_stimulation(obj,scale)
            %run_stimulation
            %
            %   result_obj = run_stimulation(obj,scale)
            %
            %   OUTPUTS
            %   ===========================================================
            %   result_obj : Class: NEURON.simulation.extracellular_stim.results.single_sim
            %
            %   Class:
            %   NEURON.simulation.extracellular_stim.threshold_analysis
            %
            
            result_obj = NEURON.simulation.extracellular_stim.results.single_sim;
            result_obj.tested_scale = scale;
            result_obj.xstim_obj    = obj.parent;
            
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
                   result_obj.setFriedTissueValues();
                   return
                end
            end
            
            %Membrane threshold analysis
            %--------------------------------------------------------------
            %NOTE: This could get a lot more complicated with time varying
            %stimuli. For now we'll keep it simple ...
            vm = obj.parent.data_transfer_obj.getMembranePotential;
            
            max_vm_by_space = max(vm); %i.e. take max over time at each point in space
            
            t_info = obj.threshold_info;
            if isempty(t_info)
                error('Threshold info must be set before calling this class')
            end
            
            result_obj.vm_threshold            = t_info.v_ap_threshold;
            result_obj.ap_propogation_index = t_info.v_ap_propogation_index;
            
            result_obj.max_membrane_potential = max(max_vm_by_space);
            result_obj.membrane_potential     = vm;
            result_obj.threshold_crossed      = result_obj.max_membrane_potential > t_info.v_ap_threshold;
            result_obj.ap_propogated          = max_vm_by_space(t_info.v_ap_propogation_index) > t_info.v_ap_threshold;
            result_obj.max_vm_per_node        = max_vm_by_space;
        end
    end
end

