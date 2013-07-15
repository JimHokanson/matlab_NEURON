classdef request_handler
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.request_handler
    %
    %   This is responsbile for carrying out determination of the
    %   thresholds. It is meant as the top level interface object with the
    %   user when determining multiple thresholds ...
    %
    %   
    %   NEURON.simulation.extracellular_stim.??/
    %
    %   Main subclass:
    %   NEURON.xstim.single_AP_sim.solver
    %
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.solver
    %   NEURON.xstim.single_AP_sim.logged_data
    %   NEURON.xstim.single_AP_sim.solution
    %   NEURON.xstim.single_AP_sim.applied_stimuli
    %   NEURON.xstim.single_AP_sim.solver
    %   NEURON.xstim.single_AP_sim.solution.match_result
    
    properties
        xstim      %Class: NEURON.xstim
        xstim_ID   %Class: NEURON.logger.ID;
    end
    
    properties
% % %         cell_locations_input   %[n x 3] or {1 x 3}, we need to save this
% % %         %value in case we want to reshape the output back to a 3d matrix
% % %         xyz_of_cell_locations  %[n x 3] these are the locations we will
% % %         %solve for ...
        default_stim_sign
    end
    
    %OUTPUT ===============================================================
    properties
        solution    %Class: NEURON.xstim.single_AP_sim.solution
        solution_found = false
    end
    
    properties
        solver  %SC: NEURON.xstim.single_AP_sim.solver
    end
    
    methods
        function obj = request_handler(xstim,default_stim_sign,varargin)
            %
            %
            %   obj = request_handler(parent,stim_sign,cell_locations)
            %
            %   See Also:
            %   NEURON.simulation.extracellular_stim.get...???
            
            DEFAULT_TIME = 1.2; %NOTE: We expect the auto changer (not 
            %sure of the class) to change to a valid time
            %We also will force auto-changing ...
            
            in.solver = 'default'; %Name of the predictor to use, only
            %the default option is currently supported ...
            in = sl.in.processVarargin(in,varargin);
            
            obj.xstim     = xstim;
            obj.default_stim_sign = default_stim_sign;
            
            %Retrieval of instance id
            %--------------------------------------------------------------
            %HACK FOR LOGGER COMPARISON ...
            xstim.cell_obj.moveCenter([0 0 0]);
            xstim.props.changeProps('tstop',DEFAULT_TIME)
            %TODO: Check this value before setting, throw warning
            %if not true ...
            xstim.options.autochange_run_time = true;
            
            xstim_logger = xstim.getLogger;
            obj.xstim_ID = xstim_logger.getInstanceID(); %This is a critical
            %line that associates the data we will create with the current
            %simulation
            
            %Make a nicer display function
            fprintf(2,'Save string: %s\n',obj.xstim_ID.getSaveString);
            
            %Initialization of the solver ...
            
            obj.solver = NEURON.xstim.single_AP_sim.solver.create(in.solver,xstim);
            
            
        end
        function [solution,predictor_info] = getSolution(obj,cell_locations,varargin)
            %
            %
            %    [solution,predictor_info] = getSolution(obj)
            %
            %    OUTPUTS
            %    ===========================================================
            %    solution: NEURON.xstim.single_AP_sim.solution
            %    predictor_info: Output depends on the solver ...
            
            
            %Local variables:
            %-------------------------------------------------
            %cell_locations_input
            %logged_data
            
            in.stim_sign = obj.default_stim_sign;
            in = sl.in.processVarargin(in,varargin);
            
            stim_sign = in.stim_sign;
            
            predictor_info = [];
            
            cell_locations_input = cell_locations;

            %XYZ Handling ...
            %--------------------------------------------------------------
            if iscell(cell_locations)
                xyz = sl.xyz.cellToMatrix(cell_locations);
            else
                assert(size(cell_locations,2) == 3,'# of columns for cell locations must be 3')
                xyz = cell_locations;
            end
            
            logged_data = NEURON.xstim.single_AP_sim.logged_data(in.stim_sign,obj.xstim_ID);
            
            
            %This line checks to see if the requested locations were
            %previously request and solved ...
            match_result = logged_data.checkIfSolved(xyz);
            %NEURON.xstim.single_AP_sim.solution.match_result
            
            if match_result.is_complete_match
                solution = match_result.getFullSolution();
                return
            end
            
            %If not, create objects for possible user manipulation
            %--------------------------------------------------------------
            %   NOTE: We only do object construction here. We later will
            %   make a call to solve the objects.
            
            new_cell_locations = match_result.getUnmatchedLocations();            
            
            new_data = NEURON.xstim.single_AP_sim.new_solution(stim_sign,obj.xstim_ID,new_cell_locations);
            
            %NEURON.xstim.single_AP_sim.solver.initializeSuperProps
            s = obj.solver;
            s.initializeSuperProps(logged_data,new_data,stim_sign);
            s.initializeSubclassProps();
            
            %Things are missing, call solver ...
            %--------------------------------------------------------------
            predictor_info = s.getThresholdSolutions();
            
            match_result = obj.logged_data.checkIfSolved(xyz);
            %NEURON.xstim.single_AP_sim.solution.match_result
            
            if match_result.is_complete_match
                obj.solution       = match_result.getFullSolution();
                obj.solution_found = true;
                solution = obj.solution;
                return
            else
                error('The predictor failed to populate all solutions')
            end
            
            
        end
    end
end

