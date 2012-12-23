classdef threshold_analysis < handle_light
    %
    %
    %   Class: NEURON.simulation.extracellular_stim.threshold_analysis

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
        propogation_index  = 1  %Index to check 
    end
    
    %Determining threshold ================================================
    properties 
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
    
    %THRESHOLD ANALYSIS
    %======================================================================
    %Things to know:
    %----------------------------------------------------------------------
    %1) Anything above threshold
    %2) Fried tissue
    %3) Highest subthreshold response - i.e. if we have nothing, what is
    %       the maximum potential that was reached? This may have
    %       predictive purposes ...
    %4) Was a certain area above threshold - i.e. to test propogation
    
    %Cases
    %----------------------------------------------------------------------
    %1) A.P. but propogation failure:
    %      - due to lack of simulation time, AP should propogate
    %      - due to anodal block phenomena
    %      - NOTE: We could eventually try and differentiate between these
    %      two but we would need to rely on stim times ...
    %
    %2) No AP
    %      - insufficient stimulus
    
    methods
        function result_obj = run_stimulation(obj,scale)
            %
            %
            %   result_obj = run_stimulation(obj,scale)
            %
            %   OUTPUTS
            %   ===========================================================
            %   
            
            result_obj = NEURON.simulation.extracellular_stim.results.single_sim;
            
            %Move this back into simulation class with throw error optional????
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

