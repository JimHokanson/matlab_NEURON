classdef stim
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.matcher.stim
    %
    %
    %   This is a linearization of all relevant stim objects
    %   
    %   I also need an instance of a single object ...
    
    %??? How to distinguish between + and - thresholds ?????
    %- NOTE: We don't need to record the relative contributions
    %   only the pulse width, so if the relative contributions are all over
    %   the place, how do we decide, especially with multiple time events
    %   ...
    %
    %   We record two thresholds for each case
    %
    %   Then we filter by cases with the same sign!
    %
    %   i.e. stim sign doesn't go with the stimulus setup, but with the
    %   data
    %
    %   have a positive data set and a negative data set ...
    %   wait - then we are back at differentiating by type
    
    properties
       stim_type          %array of types ...       
       data_linearization %cell array of data

       current_data_instance
    end
    
    properties (Constant)
       VERSION = 1 
    end
    
    methods
        function obj = stim(stim_struct)
           obj.stim_type = stim_struct.stim_type;
        end
        function populateCurrentDataInstance(sim_object)
            %Get electrodes
            %Get type
            %populate .current_data_instance ...
        end
    end
    
end

