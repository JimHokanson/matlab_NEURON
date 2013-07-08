classdef request_handler
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.request_handler
    %
    %   This is responsbile for carrying out determination of the
    %   thresholds. It is meant as the top level interface object with the
    %   user when determining multiple thresholds ...
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.logged_data
    %   NEURON.xstim.single_AP_sim.solution
    %   NEURON.xstim.single_AP_sim.applied_stimuli
    %   NEURON.xstim.single_AP_sim.predictor
    %   NEURON.xstim.single_AP_sim.solution.match_resul
    
    properties
        parent      %Class: NEURON.xstim
        xstim_ID    %Class: NEURON.logger.ID;
        logged_data %Class: NEURON.xstim.single_AP_sim.logged_data
    end
    
    properties
        cell_locations_input   %[n x 3] or {1 x 3}, we need to save this
        %value in case we want to reshape the output back to a 3d matrix
        xyz_of_cell_locations  %[n x 3] these are the locations we will
        %solve for ...
        stim_sign
    end
    
    %OUTPUT ===============================================================
    properties
        solution    %Class: NEURON.xstim.single_AP_sim.solution
        solution_found = false
    end
    
    properties
        predictor  %Subclass of: NEURON.xstim.single_AP_sim.predictor
    end
    
    methods
        function obj = request_handler(parent,stim_sign,cell_locations,varargin)
            %
            %
            %   obj = request_handler(parent,stim_sign,cell_locations)
            %
            
            in.predictor = 'default'; %Name of the predictor to use
            in = sl.in.processVarargin(in,varargin);
            
            %Do we want to use this approach where we allow passing
            %in of the predictor to use ?????
            %
            %   I think so ...
            %             in.predictor = 'default'
            %             in = sl.in.processVarargin(in,varargin);
            
            obj.parent   = parent;
            obj.cell_locations_input = cell_locations;
            obj.stim_sign = stim_sign;
            
            xstim_logger = parent.getLogger;
            
            obj.xstim_ID = xstim_logger.getInstanceID();
            
            obj.logged_data = NEURON.xstim.single_AP_sim.logged_data(stim_sign,obj.xstim_ID);
            %NEURON.xstim.single_AP_sim.logged_data
            
            %Check if we're done
            %--------------------------------------------------------------
            if iscell(cell_locations)
                xyz = sl.xyz.cellToMatrix(cell_locations);
            else
                %TODO: Check for n x 3
                xyz = cell_locations;
            end
            
            obj.xyz_of_cell_locations = xyz;
            
            match_result = obj.logged_data.checkIfSolved(xyz);
            %NEURON.xstim.single_AP_sim.solution.match_result
            
            if match_result.is_complete_match
                obj.solution       = match_result.getFullSolution();
                obj.solution_found = true;
                return
            end
            
            %If not, create objects for possible user manipulation
            %--------------------------------------------------------------
            %
            %   NOTE: We only do object construction here. We later will
            %   make a call to solve the objects. Between these calls the
            %   user can change options ..., they could even change
            %   the predictor object itself ...
            
            %??? switch on in.predictor????
            %
            %   i.e. switch in.predictor
            %           case 'default'
            %           case ...
            %        end
            
            new_cell_locations = match_result.getUnmatchedLocations();
            
            p = NEURON.xstim.single_AP_sim.predictor.create(in.predictor);
            
            
            new_data = NEURON.xstim.single_AP_sim.new_solution(stim_sign,obj.xstim_ID,new_cell_locations);
            
            %NEURON.xstim.single_AP_sim.predictor.initializeSuperProps
            p.initializeSuperProps(obj.logged_data,new_data,parent);
            p.initializeSubclassProps();
            
            obj.predictor = p;
        end
        function [solution,predictor_info] = getSolution(obj)
            %
            %
            %    [solution,predictor_info] = getSolution(obj)
            %
            %    OUTPUTS
            %    ===========================================================
            %    solution: NEURON.xstim.single_AP_sim.solution
            %    predictor_info: Output depends on the predictor ...
            %
            
            %Check if solution is found - if so, return early
            %--------------------------------------------------------------
            %The solution would be found if we have already requested the
            %same values as before. This would be done in the constructor.
            %
            %NOTE: The user could check this too by looking at the
            %properties after the constructor call, but this method call
            %is fine too.
            if obj.solution_found
                solution = obj.solution;
                predictor_info = [];
                return
            end
            
            %Things are missing, call predictor ...
            %--------------------------------------------------------------
            predictor_info = obj.predictor.getThresholdSolutions();
            
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

