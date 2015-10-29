classdef threshold_testing_history < NEURON.sl.obj.handle_light
    %
    %   Class:
    %       NEURON.simulation.extracellular_stim.results.threshold_testing_history
    %
    %   This is a results class which summarizes our attempt to determine
    %   threshold for a given extracellular simulation setup.
    %
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.threshold_analyis.determine_threshold
    
    properties
        n_loops = 0 
        n_above = 0
        n_below = 0
        
        threshold_info  %Class: NEURON.cell.threshold_info
        
        stimulus_threshold %Main result of this class. This is the estimated
        %stimulus threshold required to fire an action potential.
        
        tested_stimuli  = zeros(1,20) %Stimulus scalars tested
        response_type   = zeros(1,20) %
        %1 - propagation
        %2 - too strong a stimulus - no propagation
        %3 - way too strong a stimulus - NEURON threw an error (tissue fried case)
        %4 - no propagation, stimulus too weak
        
        last_threshold_stimulus
        last_non_threshold_stimulus
        last_threshold_vm = [] %[time x space] Potential recorded
        %at each point in space. Spatial interpretation is left up to the
        %cell. Values are for the last tested stimuli which showed action
        %potential propagation.
    end
    
    methods
        function obj = threshold_testing_history(threshold_info)
           %threshold_testing_history
           %
           %    NOTE: Object should be finalized after simulation. See
           %    method finalizeData()
           
           obj.threshold_info = threshold_info;
        end
        function plot(obj)
           mesh(obj.last_threshold_vm)
           title(sprintf('Stimulus Threshold: %0.2f',obj.stimulus_threshold))
        end
        function logResult(obj,tested_value,response_type,vm)
           %logResult
           %
           %    logResult(obj,tested_value,response_type,vm)
           
           n_local = obj.n_loops + 1;
           
           if response_type == 1
              obj.last_threshold_vm = vm; 
           end
           
           obj.tested_stimuli(n_local) = tested_value;
           obj.response_type(n_local)  = response_type;
           obj.n_loops                 = n_local;
           
           if response_type == 4
               obj.n_below = obj.n_below + 1;
           else
               obj.n_above = obj.n_above + 1;               
           end
        end
        function finalizeData(obj,stimulus_threshold)
           obj.tested_stimuli(obj.n_loops+1:end) = [];
           obj.response_type(obj.n_loops+1:end)  = [];
           obj.stimulus_threshold = stimulus_threshold; 
           
           %TODO: Fix this ...
           %??? - the solver should have this information ...
           %We should probably just get it from the solver ...
           obj.last_threshold_stimulus = ...
                    obj.tested_stimuli(find(obj.response_type == 1,1,'last'));
           obj.last_non_threshold_stimulus = ...
                    obj.tested_stimuli(find(obj.tested_stimuli < obj.last_threshold_stimulus,1,'last'));
        end
        function str = getSummaryString(obj)
            str = sprintf('SIMULATION FINISHED: THRESHOLD = %0g, n_loops = %d',...
                obj.stimulus_threshold,obj.n_loops); 
        end
    end
end

