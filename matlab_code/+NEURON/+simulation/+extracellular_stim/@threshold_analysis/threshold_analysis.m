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
        threshold_info %Class: NEURON.cell.threshold_info
        
        %NOTE: This prop is not exposed to the user in a clean way yet ...
        opt_use_halfway_point_for_threshold = true; %If true, threshold
        %is not actually tested for threshold but is half way between the
        %minimum and maximum. In general this will be a more accurate
        %estimate of threshold but 
    end
    
    properties
        %.determine_threshold() PROPERTIES NOT YET USED
        %
        %   TODO: Finish this documentation
        %
        %   The following are edge stimulus cases:
        %   1) No stimulus. This can occur for a cell
        %
        %   Sometimes when testing for a stimulus threshold one may
        %   encounter no stimulus being applied, or essentially no stimulus
        %   or an infinite stimulus
        %   when the cell and electrode are at the same location. In
        %   general both are not desired but generic thresholds for both
        %   can be applied.
        
        no_stim_threshold         = Inf %With no stimulus (or a very small one)
        %it would take an infinite stimulus to activate the cell
        throw_error_no_stimulus   = false
        infinite_stim_threshold   = 0 %A default of zero suggests that if 
        %an electrode were truly at the same location as a cell, that it
        %would require no stimulus, or a very very small stimulus, to
        %activate the cell.
        throw_error_inf_stim      = false
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

