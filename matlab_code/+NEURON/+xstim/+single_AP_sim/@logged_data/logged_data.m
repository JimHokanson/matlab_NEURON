classdef logged_data < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.logged_data
    %
    %
    % This class is in charge of saving/loading each data instance and
    % maintaining which predictor is being used to generate this information
    % especially useful for testing, we are going to want to insure that the
    % different predictor methods do not generate different outcomes.
    %
    %
    %   Not sure if I want to eventually merge this with the solution. I
    %   feel like right now this class will maintain solving and more
    %   functionality might be added, where as the solution class will only
    %   store the data.
    %
    %   Questions:
    %   ======================================================
    %   1) 
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Store xstim_ID with data for hash comparison ...
    %           This involves creating a save method for the ID
    %   
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.new_solution
    
    properties(Constant)
       VERSION = 1;
    end
    
    properties
       file_path %Path to mat file ...
       stim_sign
    end
    
    %Old values
    %----------------------------------------------
    properties        
       solution %Class: 
    end 

    methods
        function obj = logged_data(stim_sign,xstim_ID)
            %
            %
            %   INPUTS
            %   ===========================================================
            %   sign
            %   xstim_ID : NEURON.logger.ID
                        
            base_path = NEURON.xstim.results_path_manager.getMyBasePath(obj);
            file_name = xstim_ID.getSaveString;
            
            %Important Design Decision:
            %We'll drop sign handling here so that every function doesn't
            %have to worry about what sign we are dealing with ...
            if stim_sign > 0
                sign_folder = 'pos';
            else
                sign_folder = 'neg';
            end
            obj.file_path = sl.dir.createFolderIfNoExist(base_path,sign_folder,file_name);
            obj.stim_sign = stim_sign;
            obj.loadData(xstim_ID);
        end
        function loadData(obj,xstim_ID)            
            if exist(obj.file_path,'file')
                h = load(obj.file_path);
                s = h.s;
                if (s.VERSION ~= obj.VERSION)
                    error('Version updating not yet handled')
                end
                sol_s = s.solution;
            else
                sol_s = struct([]); 
            end
            obj.solution = NEURON.xstim.single_AP_sim.solution(sol_s);
            
            %f the new solution object has anything logged on disk
            NEURON.xstim.single_AP_sim.new_solution.getNewSolutionData(obj.stim_sign,obj,xstim_ID);
        end
        function saveData(obj)
           s.VERSION  = obj.VERSION;
           s.solution = obj.solution.getStruct();
           s.VERSION  = obj.VERSION; %#ok<STRNU>
           save(obj.file_path,'s')
        end
        function match_result = checkIfSolved(obj,new_cell_locations)
           %NOTE: We should also return a solution object 
           %
           %    INPUTS
           %    ==================================
           %    new_cell_locations : [n x 3]
           %
           %    FULL PATH:
           %    NEURON.xstim.single_AP_sim.logged_data.checkIfSolved
           
           match_result = obj.solution.findLocationMatches(new_cell_locations);
           
        end
        function addEntries(obj,solve_dates,new_locations,new_thresholds,predictor_types,ranges)
            %
            %
            %
            %   addEntries(obj,stim_sign,new_cell_locations,new_thresholds,predictor_types,ranges)

            %TODO: replace with varargin
            
            obj.solution.addToEntry(solve_dates,new_locations,new_thresholds,predictor_types,ranges);
            %TODO: Make call to save ...
        end
        
        
        %This will be in the request_handler or some other class
        %specific to handling this ...
        
% % %         function recreateStimuli(obj)
% % %             % should be called from predictor
% % %              linear_elec = obj.stim_base;
% % %              stim = [];
% % % %             %==================================================
% % % %             % part of how we might generate the stim_old
% % % %             %==================================================
% % % %             index = 1;
% % % %             len = length(linear_elec);
% % % %             while index > len
% % % %                 n_elec = linear_elec(index);
% % % %                 elec_top = index + 1;
% % % %                 elec_end = index + 3*n_elec;
% % % %                 temp = linear_elec(elec_top:elec_end);
% % % %                 xyz_all = reshape(temp,3,n_elec)';
% % % %                 stim_temp = mergeStimTimes(xyz_all); 
% % % %                 % that code ^ will need alterations...and getLogData???
% % % %                 stim = [stim stim_temp];
% % % %                 index = elec_end + 1;
% % % %             end
% % %             obj.stim_old = stim; 
% % %         end
        
        %{
        %          Not Sure Yet Where This Will Go
        %===================================================
        %    part of how we might generate the stim_base
        %===================================================
        n_electrodes = length(electrodes);
        xyz_all = [];
        
        for iElec = 1:n_electrodes
            xyz_all = [xyz_all electrodes(iElec).xyz];
        end
        elec_data = [n_electrodes xyz_all];
        obj.stim_base = [obj.stim_base elec_data];      
        %} 
        
    end

end