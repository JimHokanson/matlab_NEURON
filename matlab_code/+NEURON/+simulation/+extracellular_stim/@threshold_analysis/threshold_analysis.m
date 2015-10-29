classdef threshold_analysis < NEURON.sl.obj.handle_light
    %
    %   Class: 
    %       NEURON.simulation.extracellular_stim.threshold_analysis
    %
    %   This class handles things related to analyzing extracellular
    %   stimulation. In general it should not be called directly by the
    %   user. It is mainly a location to hide methods related to threshold
    %   analysis. Access to this class is obtained through method calls to
    %   an instance of the extracellular stimulation simulation class.
    %
    %   Relevant Clases
    %   ==================================================================
    %   For instructions on how to process the threshold information, the
    %   cell must produce an object of the class:
    %   NEURON.cell.threshold_info
    %
    %   For other instructions for this class, see the object:
    %   NEURON.simulation.extracellular_stim.threshold_options
    %
    %   The following are result classes that this class produces:
    %   from .run_stimulation() -
    %       NEURON.simulation.extracellular_stim.results.single_sim
    %   from .determine_threshold()
    %       NEURON.simulation.extracellular_stim.results.threshold_testing_history
    %
    %   IMPROVEMENTS:
    %   ===================================================================
    %   1) For propagation index, don't allow within a certain distance of
    %   the stimulation maximum. I'm not sure how to quantify this yet ...
    %
    %   PUBLIC ACCESS METHODS
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
    %   NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
    %
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.sim_determine_threshold
    %       NEURON.simulation.extracellular_stim.results.single_sim
    %       NEURON.simulation.extracellular_stim.results.threshold_testing_history
    
    properties (Hidden)
        parent    %Class: NEURON.simulation.extracellular_stim
        cmd_obj   %Class: NEURON.cmd
    end
    
    %Threshold analysis options   %========================================
    properties (Access = private,Hidden)
        threshold_info  %Class: NEURON.cell.threshold_info
        %This property is set just before running a simulation.
        %See: NEURON.simulation.extracellular_stim.init__simulation
    end
    
    %Temporary Properties     %============================================
    properties (Hidden)
       ap_propagation_observed = false %This is a temporary variable used by
       %the determine_threshold() method to ensure that we actually get an
       %action potential to propagate, not just oscillations between
       %nothing and a super strong stimulus.
    end
    
    properties (Constant, Hidden)
       %This is the string that is returned by NEURON when we apply a stimulus
       %that is too large. Instead of throwing an error often times we will
       %just indicate that the stimulus is too large. This is primarily
       %used by the .determine_threshold() code.
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
    
    methods (Hidden)
        function setThresholdInfo(obj,threshold_info_obj)
           %setThresholdInfo
           %
           %    setThresholdInfo(obj,threshold_info_obj)
           %
           %    I created this method to discourage direct manipulation 
           %    of the property.
           
           obj.threshold_info = threshold_info_obj;
        end
        function result_obj = run_stimulation(obj,scale,auto_expand)
            %run_stimulation
            %
            %   result_obj = run_stimulation(obj,scale, *auto_expand)
            %
            %   This is the main method for running a single extracellular
            %   stimulation. It should only be called by an instance of the
            %   extracellular stimulation simulation class.
            %
            %   Specifically, this method is called by:
            %       NEURON.simulation.extracellular_stim.sim__single_stim
            %
            %   INPUTS
            %   ===========================================================
            %   scale :  Multiplier of loaded data
            %
            %   OUTPUTS
            %   ===========================================================
            %   result_obj : Class: NEURON.simulation.extracellular_stim.results.single_sim
            %
            %   See Also:
            %   NEURON.simulation.extracellular_stim.sim__single_stim
            %   NEURON.simulation.extracellular_stim.results.single_sim
            %
            %   FULL PATH:
            %   NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
            
            BASE_VOLTAGE_ADDED_VALUE = 10;
            
            t_info = obj.threshold_info;
            if isempty(t_info)
                error('Threshold info must be set before calling this class')
                %See: NEURON.simulation.extracellular_stim.init__simulation
            end
            
            initial_tstop = obj.parent.props.getExpectedSimDuration;
            
            result_obj = NEURON.simulation.extracellular_stim.results.single_sim(...
                            obj.parent,scale,t_info,initial_tstop);
            result_obj.tested_scale = scale;
            result_obj.xstim_obj    = obj.parent;
            
            %Running the simulation
            %--------------------------------------------------------------
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
            %vm [time x space]
            vm = obj.parent.data_transfer_obj.getMembranePotential;
            
            %Simulation time expansion code
            %--------------------------------------------------------------
            if auto_expand
               %This current expansion approach relies on an assumption
               %of a stable membrane voltage. Should we get oscillating
               %dynamics then we need to fix this approach.
               
               %Test diff of voltage
               %- need max time
               %- need growth instructions - what time instructions
               %continuerun(new_time)
                
               %TODO: Clean this code up ...
               
               %NOTE: We might want to merge these two
               %I saw one weird example of a very long hyperpolarization
               %potential which was growing back to baseline and for
               %some reason the sides were already above baseline (and were
               %falling) which meant that:
               %1) growth was occuring - (the center most points)
               %2) points were above baseline - (the sides)
               %
               %If the masks from 1 & 2 were linked, we might get a more
               %stable result ??
               
               
               %< 0 indicates newer voltage is greater than older voltage, i.e. growth,
               continue_test = (@(vm) any(vm(end-1,:) - vm(end,:) < 0) && ...
                   ... %This is a test for being above baseline
                   any(vm(end,:) > vm(1,:) + BASE_VOLTAGE_ADDED_VALUE)); 
               
               if continue_test(vm)
                  sim_ext_options = obj.parent.sim_ext_options_obj;
                   
                  tstop_growth   = sim_ext_options.sim_growth_rate;
                  current_t_stop = initial_tstop;
                  max_t_stop     = current_t_stop + sim_ext_options.max_absolute_sim_growth;
                   
                  extension_successful = false;
                  
                  c = obj.cmd_obj;
                  
                  n_loops = 0;
                  while current_t_stop < max_t_stop
                      current_t_stop = current_t_stop + tstop_growth;
                      n_loops = n_loops + 1;
                      
                      str = sprintf('{xstim__continue_simulation(%0g)}',current_t_stop);
                      c.run_command(str);
                      vm = obj.parent.data_transfer_obj.getMembranePotential;
                      
                      extension_successful = ~continue_test(vm);
                      if extension_successful
                          break
                      end
                  end
                  
                  %TODO: provide more details
                  if ~extension_successful
                      error('Attempt to extend simulaton failed')
                  end
                  result_obj.final_simulation_time = current_t_stop; 
               end
            else
                result_obj.final_simulation_time = initial_tstop;
            end
            
            result_obj.membrane_potential = vm;
            result_obj.ap_propagated      = obj.analyzeMembranePotential(vm);  

        end
    end
    
    %Membrane Voltage Analysis   %=========================================
    %----------------------------------------------------------------------
    % I'm not sure that I want this code here. I'm not sure how it is best
    % to organize this. These functions might become their own class or be
    % placed into the threshold_info class. The threshold_info class is
    % strongly dependent on, and is populated in, the cell class, as the
    % action potential properteis are a function of the cell type.
    methods (Hidden)
        function ap_propagated = analyzeMembranePotential(obj,vm)
            %
            %   
            %   ap_propagated = analyzeMembranePotential(obj,vm)   
            %
            %   INPUTS
            %   ===========================================================
            %   vm : [time x space], membrane potential
            %   
            %
            
            
            t_info = obj.threshold_info;

            %Currently only a very basic check mechanism is implemented
            max_vm_desired_location = max(vm(:,t_info.v_ap_propagation_index));
            ap_propagated = max_vm_desired_location > t_info.v_ap_threshold;        
        end
        function any_above_threshold = anyAboveThreshold(obj,vm)
            %anyAboveThreshold
            %
            %   any_above_threshold = anyAboveThreshold(obj,vm)
            
            
            t_info = obj.threshold_info;
            
            max_vm_all          = max(vm,[],1);
            any_above_threshold = any(max_vm_all > t_info.v_ap_threshold);
        end
    end
end

