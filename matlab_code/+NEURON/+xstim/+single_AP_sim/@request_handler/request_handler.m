classdef request_handler
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.request_handler
    %
    %   This is responsbile for carrying out determination of the
    %   thresholds.
    
    properties
        parent      %Class: NEURON.xstim
        xstim_ID    %Class: NEURON.logger.ID;
        logged_data %Class: NEURON.xstim.single_AP_sim.logged_data
    end
    
    properties
        cell_locations
        stim_sign
        solution
        solution_found = false;
    end
    
% %     properties
% %         options
% %     end
% % 
% %     properties
% %         stim_sign
% %         requested_locations
% %         unknown_mask
% %         
% %         final_thresholds
% %     end
    
    methods
        function obj = request_handler(parent,stim_sign,cell_locations)
            % get previously logged data
            % we may or may not want to repopulate our known locations just
            % yet...
            obj.parent   = parent;
            obj.cell_locations = cell_locations;
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
            
            match_result = checkIfSolved(obj,xyz);
            %NEURON.xstim.single_AP_sim.solution.match_result
            
            if match_result.is_complete_match
               obj.solution = match_result.getFullSolution();
               obj.solution_found = true;
               return
            end
            
            %If not, create objects for possible user manipulation
            %--------------------------------------------------------------
            %TODO: Flush this out ...
            %
            %1) Prediction mechanism (solver)
            %2) Algorithm for determining next things to solve (make a
            %class)
            %3) Full solution solver
            %
            %   Other classes:
            %   -----------------------------------
            %   1) Results class
            %
            %
            
            %IMPORTANT: The goal here is to instantiate basic options
            %and then to allow the user to manipulate them by returning
            %the object before calling getSolution()
            
            keyboard            
        end        
        function solution = getSolution(obj)
           
            %1) Check if solution is found, if so return
            %NOTE: We will allow the user to do this too
            
            %2) If not found, ask solver to get it
            
            
        end
        
% % % %         function [unknown, index] = determine_unknown_indices(obj, cell_locations)
% % % %             % call: logged_data function to get old data
% % % %             % from the values its got and the requested locations, it
% % % %             % determines which indices into the requested_locations have
% % % %             % already been solved.           
% % % %             if isempty(obj.logged_data.cell_locations_old)
% % % %                 obj.logged_data.load_data();
% % % %             end
% % % %             old_locations = obj.logged_data.cell_locations_old;
% % % %             [match, index] = ismember(cell_locations, old_locations, 'rows');
% % % %             unknown = find(~match);
% % % %         end        
% % % %         function thresholds = getThresholds(obj, cell_locations, predictor)            
% % % %             %cell_locations passed in as a cell array needs reformatting...
% % % %             [unknown, known_indices] = obj.determine_unknown_indices(obj, cell_locations);
% % % %             if isempty(unknown)
% % % %                 thresholds = sign.*obj.logged_data.old_thresolds(known_indices);
% % % %                 return
% % % %             end
% % % %             solver(predictor, obj); %I don't want this to be created 
% % % %             % until we know we need it. might have to pass in predictor 
% % % %             % type from xstim, and then actully generate the predictor 
% % % %             % object here
% % % %             thresholds = solver.predictThresholds(known_indices, sign, ...
% % % %                                                   cell_locations);
% % % %         end     
    end
end

