classdef single_sim < NEURON.sl.obj.handle_light
    %
    %   Class: 
    %       NEURON.simulation.extracellular_stim.results.single_sim;
    %
    %   This class is supposed to the results of running a single
    %   extracellular stimulation simulation. This class is created by:
    %   NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.threshold_analysis.run_stimulation
    %
    %   IMPROVEMENTS:
    %   ===================================================================
    %   1) Get accurate labels of space & time for plotting method
    
    properties (Hidden)
        xstim_obj          %Class: NEURON.simulation.extracellular_stim
        
        cell_obj           %Class: Subclass of NEURON.neural_cell &
        %NEURON.cell.extracellular_stim_capable
        
        threshold_info_obj %Class: NEURON.cell.threshold_info
    end
    
    properties
       tested_scale        %Scaling amplitude tested.
       
       success             %Whether or not simulation ran without an error
       %NOTE: Currently if this is false it indicates that the tissue is
       %fried, as otherwise an error will be thrown. It might eventually be
       %changed to have other reasons.
       
       tissue_fried        %Numerical overflow due to too strong a stimulus
    end
    
    properties
       simulation_time_extended = false;
       initial_simulation_time
       final_simulation_time
    end
    
    properties
        membrane_potential       = []    %[time x space] Potential recorded
        %at each point in space. Spatial interpretation is left up to the
        %cell.
        
        ap_propagated            = false %Whether or not propagation was
        %detected.
    end
    
    methods
        function obj = single_sim(xstim_obj,tested_scale,threshold_info_obj,initial_tstop)
           %
           %
           %    obj = single_sim(xstim_obj,tested_scale,threshold_info_obj,initial_tstop)
           %
           %    FULL PATH:
           %        NEURON.simulation.extracellular_stim.results.single_sim
           
           obj.xstim_obj               = xstim_obj;
           obj.cell_obj                = obj.cell_obj;
           obj.tested_scale            = tested_scale;
           obj.threshold_info_obj      = threshold_info_obj;
           obj.initial_simulation_time = initial_tstop;
        end
        function plot(obj,varargin)

            %TODO:
            %=========================================================
            %This method is out of date.
            %1) Implement movie of voltage over time
            %2) Provide method in cell for parsing spatial response
            %into parts and for providings spatial scales
            
            vm_local       = obj.membrane_potential;
            
            %NOTE: Due to time extension dt may be wrong ...
            %?? - why would dt be wrong and not final time
            time_vector   = obj.xstim_obj.props.getTimeVector;
            
            n_space_points = size(vm_local,2);
            mesh(1:n_space_points,time_vector,vm_local)
            
% % %             in.font_size = 18;
% % %             in = NEURON.sl.in.processVarargin(in,varargin);
% % %             %TODO: Reference this to some plotting method of the cell
% % %             %This functionaly could be useful elsewhere ...
% % %             
% % %             
% % %             
% % %             
% % %             
% % %             x = obj.ap_propogation_index;
% % %             y = time_vector([1 end]);
% % %             z = obj.vm_threshold;
% % %             
% % %             line([x x],y,[z z],'Linewidth',3,'Color','k')
% % %             zlabel('Membrane Potential','FontSize',in.font_size)
% % %             xlabel('Space','FontSize',in.font_size)
% % %             ylabel('time','FontSize',in.font_size)
% % %             title(sprintf('Stimulus Scale: %0.2f',obj.tested_scale),...
% % %                 'FontSize',in.font_size)
        end
        function plot__singleSpace(obj,index)
           vm_local = obj.membrane_potential;
           time_vector   = obj.xstim_obj.props.getTimeVector;
           plot(time_vector,vm_local(:,index))
           xlabel('Time (ms)')
           ylabel('Membrane Potential (mV)')
        end
    end
    
end

