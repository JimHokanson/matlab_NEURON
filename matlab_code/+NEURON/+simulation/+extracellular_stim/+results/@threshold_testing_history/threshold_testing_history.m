classdef threshold_testing_history < handle_light
    %threshold_testing_history
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.results.threshold_testing_history
    %
    %   See Also:
    %   NEURON.simulation.extracellular_stim.threshold_analyis.determine_threshold
    
    properties
        success     %Not yet defined ...
        
        n_loops = 0
        n_above = 0
        n_below = 0
        
        threshold_info %Class: NEURON.cell.threshold_info
        
        stimulus_threshold %Main result of this class. This is the stimulus
        %threshold required to fire an action potential ...
        
        tested_stimuli  = zeros(1,20) %
        ap_propogated   = false(1,20) %(logical array)
        max_vm          = zeros(1,20)
    end
    
    properties (Dependent)
        v_ap_threshold_estimate 
    end
    
    methods 
        function value = get.v_ap_threshold_estimate(obj)
           value = predictMembranePotential(obj,obj.stimulus_threshold); 
        end
    end
    
    methods
        function obj = threshold_testing_history(threshold_info)
           %Nothing currently
           %
           %    NOTE: Object should be finalized after simulation. See
           %    method finalizeData()
           obj.threshold_info = threshold_info;
           
        end
        function logResult(obj,tested_value,ap_fired,max_vm)
           n_local = obj.n_loops + 1;
           
           obj.tested_stimuli(n_local) = tested_value;
           obj.ap_propogated(n_local)  = ap_fired;
           obj.max_vm(n_local)         = max_vm;
           
           %if ~ap_fired
           %if max_vm > max_vm_not_fired
           %    update object property ...
           %end
           %end
           
           obj.n_loops = n_local;
           
           if ap_fired
               obj.n_above = obj.n_above + 1;
           else
               obj.n_below = obj.n_below + 1;               
           end
        end

        function finalizeData(obj,stimulus_threshold)
           obj.tested_stimuli(obj.n_loops+1:end) = [];
           obj.ap_propogated(obj.n_loops+1:end)  = [];
           obj.max_vm(obj.n_loops+1:end)         = [];
           obj.stimulus_threshold = stimulus_threshold; 
        end
        function str = getSummaryString(obj)
            str = sprintf('SIMULATION FINISHED: THRESHOLD = %0g, n_loops = %d',...
                obj.stimulus_threshold,obj.n_loops); 
        end
    end
    
    %Membrane Threshold & Stimulus Level Prediction Methods ...
    %These functions are in limbo ....
    methods
        function stim_target = predictThreshold(obj)
           [x,y] = getXYvalues(obj);
           p = polyfit(x,y,2); %hardcoded order ...
           stim_target = polyval(p,obj.threshold_info.v_rough_threshold);
        end
        function thresh_value = predictMembranePotential(obj,stimulus_level)
           [x,y] = getXYvalues(obj);
           if obj.n_below > 1
               p = polyfit(y,x,2);
           else
               p = polyfit(y,x,1);
           end
           thresh_value = polyval(p,stimulus_level);
        end
        function [x,y] = getXYvalues(obj)
           %For now this will be limited to below
           use_values = ~obj.ap_propogated(1:obj.n_loops);
           y = [0 obj.tested_stimuli(use_values)];
           x = [obj.threshold_info.v_rest obj.max_vm(use_values)];
        end 
    end
end

