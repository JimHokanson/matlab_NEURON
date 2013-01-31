classdef single_sim < handle_light
    %
    %   Class: 
    %       NEURON.simulation.extracellular_stim.results.single_sim;
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
    %       NEURON.simulation.extracellular_stim
    %       NEURON.simulation.extracellular_stim.plot <-?
    %
    %   IMPROVEMENTS:
    %   ===================================================================
    %   1) Fix propagation spelling.
    %   2) Get accurate labels of space & time for plotting method
    
    properties (Hidden)
       xstim_obj 
    end
    
    properties
        vm_threshold             %Threshold that needed to be crossed to consider
        %AP at a given point point in space
        
        ap_propogation_index     %index that needed to cross threshold
        %for considering propogation to have occurred
    end
    
    properties
        %see NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
        success                  %Result ran without error
        %NOTE: Currently if this is false it indicates that the tissue is
        %fried, as otherwise an error will be thrown ...
        
        tested_scale             %Value tested ...
        
        tissue_fried             %Numerical overflow due to too strong a stimulus
        membrane_potential       %potential at nodes, time x space
        threshold_crossed        = false %Whether threshold was crossed at any point
        max_membrane_potential   = NaN %max(membrane_potential(:))
        ap_propogated            = false %Whether or not a particular node crossed threshold
        max_vm_per_node          %For each node this is the maximum potential recorded
    end
    
    methods
        function setFriedTissueValues(obj)
            
            %Not sure if I should put anything else in here ...
            obj.max_membrane_potential = Inf;
        end
        function plot(obj,varargin)

            in.font_size = 18;
            in = processVarargin(in,varargin);
            %TODO: Reference this to some plotting method of the cell
            %This functionaly could be useful elsewhere ...
            
            time_vector    = obj.xstim_obj.props_obj.time_vector;
            n_space_points = size(obj.membrane_potential,2);
            mesh(1:n_space_points,time_vector,obj.membrane_potential)
            zlabel('Membrane Potential','FontSize',in.font_size)
            xlabel('Space','FontSize',in.font_size)
            ylabel('time','FontSize',in.font_size)
            title(sprintf('Stimulus Scale: %0.2f',obj.tested_scale),...
                'FontSize',in.font_size)
        end
    end
    
end

