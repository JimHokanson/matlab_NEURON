classdef Dennis_2011 < handle
    %
    %
    %   IMPORTANT ASPECTS
    %   ==================================
    %   see Dennis_2011.important_notes
    %
    %
    %
    
    
    properties
    end
    
    methods (Static)
        function [t_all,steps] = getCurrentDistanceCurve(fiber_diameter,varargin)
            
           %NOTE: How can I save these results ???
           in.TISSUE_RESISTIVITY = 500;
           in.distance_steps = [10 20:20:200 250:50:1200]; 
           in.starting_value = 1;
           in.dim            = 1;
           in.ELECTRODE_LOCATION = [0 0 0];
           in.CELL_CENTER     = [0 0 0];
           in.STIM_START_TIME = 0.1;
           in.STIM_DURATION   = [0.2 0.4];
           in.STIM_SCALE      = [-1 0.5];
           in.get_default_steps = false;
           in = processVarargin(in,varargin);
           
           steps = in.distance_steps;
           
           if in.get_default_steps
               t_all = [];
               return
           end
           
           obj = NEURON.simulation.extracellular_stim;
           obj.threshold_cmd_obj.use_max_threshold = false;
           set_Tissue(obj,NEURON.tissue.createHomogenousTissueObject(in.TISSUE_RESISTIVITY));
           
           %Electrode handling
           e_obj = NEURON.extracellular_stim_electrode(in.ELECTRODE_LOCATION);
           setStimPattern(e_obj,in.STIM_START_TIME,in.STIM_DURATION,in.STIM_SCALE);
           set_Electrodes(obj,e_obj);
           
           %Cell handling
           cell = NEURON.cell.axon.MRG(in.CELL_CENTER);
           %CRAP: I need to be fix this 
           %the order matters here ...
           %NOTE: event_manager should take care of this ...
           cell.props_obj.fiber_diameter = fiber_diameter;
           set_CellModel(obj,cell)
           
           
           %Was toggling this ...
           obj.n_obj.debug = false;
           
           t_all = sim__getCurrentDistanceCurve(obj,in.distance_steps,in.dim,in.starting_value);
           
           
        end
    end
    
end

