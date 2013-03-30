classdef pathing
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.sim_logger.pathing
    %
    %   This class is meant to handle pathing related operations and
    %   properties for the sim_logger set of classes.
    %
    %   FILE PATHING VERSION 1
    %   ===================================================================
    %   Version 1:
    %       single table file
    %       individual files for each simulation ...
    %
    %   The current setup has a single mat file which keeps track of
    %   simulation details, such as what stimulus was used, what cell type,
    %   and the properties associated with the cell. This is tracked for
    %   all simulations for which the logger has been asked to track this
    %   data.
    %
    %   For each unique simulation, a separate file exists for tracking the
    %   results of finding thresholds for data.
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) If the user options file is not specified provide link to
    %   executable code which will create it.
    %
    %
    %   See Also:
    %   NEURON.simulation.extracellular_stim.sim_logger
    %   NEURON.simulation.extracellular_stim.sim_logger.matcher
    %   NEURON.simulation.extracellular_stim.sim_logger.data
    
    properties
        root_data_path   %Directory where sim logging data is saved. This
        %property is important for the class:
        %       NEURON.simulation.extracellular_stim.sim_logger.data
        main_table_path  %Path to the details for all simulations. This
        %property is important for the class:
        %       NEURON.simulation.extracellular_stim.sim_logger.matcher
    end
    
    methods
        function obj = pathing(preferred_base_path)
            %
            %   obj = pathing(*preferred_base_path)
            %   
            %   OPTIONAL INPUTS
            %   ===========================================================
            %   preferred_base_path : (default ''), If empty the base path
            %       for logging simulation data is obtained from the user's
            %       options file, see NEURON.user_options
            %
            %   See Also:
            %   NEURON.simulation.extracellular_stim.sim_logger
            %   NEURON.user_options
            %   
            %   FULL PATH:
            %   NEURON.simulation.extracellular_stim.sim_logger.pathing
            
            if ~exist('preferred_base_path','var') || isempty(preferred_base_path)
                user_options = NEURON.user_options.getInstance;
                obj.root_data_path = user_options.sim_logger_root_path;
            else
                obj.root_data_path = preferred_base_path;
            end
            
            if isempty(obj.root_data_path)
                error(['Please add and define the following variable in' ...
                    ' your user options file: sim_logger_root_path'])
            end
            
            if ~exist(obj.root_data_path,'dir')
                success = mkdir(obj.root_data_path);
                if ~success
                    error(['Unable to create root data path for logging simulations:' ... 
                        '\nGoal Path:\n%s'],obj.root_data_path)
                end
            end
            
            obj.main_table_path = fullfile(obj.root_data_path,'sim_table.mat');
        end
        function data_path = getSavedSimulationDataPath(obj,simulation_number)
            %getSavedSimulationDataPath
            %
            %   data_path = getSavedSimulationDataPath(obj,simulation_number)
            
            data_path = fullfile(obj.root_data_path,sprintf('Sim_%03d.mat',simulation_number));
        end
    end
    
end

