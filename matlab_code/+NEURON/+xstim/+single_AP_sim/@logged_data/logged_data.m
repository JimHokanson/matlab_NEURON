classdef logged_data < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.logged_data
    %
    %   This class is in charge of saving/loading each data instance and
    %   maintaining which predictor is being used to generate this
    %   information especially useful for testing, we are going to want to
    %   insure that the different predictor methods do not generate
    %   different outcomes.
    %
    %   Not sure if I want to eventually merge this with the solution. I
    %   feel like right now this class will maintain solving and more
    %   functionality might be added, where as the solution class will only
    %   store the data.
    %
    %   Questions:
    %   ===================================================================
    %   1)
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.new_solution
    
    properties(Constant)
        VERSION = 1;
    end
    
    properties
        system_testing = false
        file_path %Path to mat file ...
        stim_sign
        xstim_ID  %NEURON.logger.ID
    end
    
    %Old values
    %----------------------------------------------
    properties
        solution %NEURON.xstim.single_AP_sim.solution
    end
    
    methods
        function obj = logged_data(stim_sign,xstim_ID,system_testing)
            %logged_data
            %
            %   obj = logged_data(stim_sign,xstim_ID)
            %
            %   INPUTS
            %   ===========================================================
            %   stim_sign :
            %   xstim_ID  : NEURON.logger.ID
            
            obj.system_testing = system_testing;
            
            base_path = obj.getBasePath(stim_sign);
            file_name = xstim_ID.getSaveString;
            
            obj.xstim_ID  = xstim_ID;
            obj.file_path = NEURON.sl.dir.createFolderIfNoExist(true,base_path,file_name);
            obj.stim_sign = stim_sign;
            
            %Loading the data from disk ...
            %--------------------------------------------------------------
            obj.loadData(xstim_ID);
            
            %If the new solution object has anything logged on disk
            %we'll merge at this time
            NEURON.xstim.single_AP_sim.new_solution.getNewSolutionData(obj.stim_sign,obj,xstim_ID);
        end
        function changeKnownData(obj,indices_to_keep)
           %
           %    This is basically used to set training data
           %
           %    Written for the system tester
           %
           %    changeKnownData(obj,indices_to_keep)
           
           obj.solution = obj.solution.getPartialObject(indices_to_keep);
           
        end
        function loadData(obj,xstim_ID)
            %
            %
            %   loadData(obj,xstim_ID)
            
            if exist(obj.file_path,'file')
                h = load(obj.file_path);
                s = h.s;
                
                if (s.VERSION ~= obj.VERSION)
                    error('Version updating not yet handled')
                end
                
                sol_s = s.solution;
                
                old_xstim_ID = NEURON.logger.ID.fromStruct(s.xstim_ID);
                if old_xstim_ID ~= xstim_ID
                    %This suggests the data we have on file is not valid for
                    %this simulation. Hopefully we never see this :/
                    error('ID mismatch :/')
                end
            else
                sol_s = struct([]);
            end
            
            obj.solution = NEURON.xstim.single_AP_sim.solution(sol_s);
        end
        function saveData(obj)
            %
            %
            %    saveData(obj)
            
            %??? When is this called ????
            %.addEntries()
            
            if ~obj.system_testing
                s.VERSION  = obj.VERSION;
                s.solution = obj.solution.getStruct();
                s.VERSION  = obj.VERSION;
                s.xstim_ID = obj.xstim_ID.getStruct(); %#ok<STRNU>
                save(obj.file_path,'s')
            end
        end
        function match_result = checkIfSolved(obj,new_cell_locations)
            %NOTE: We should also return a solution object
            %
            %    match_result = checkIfSolved(obj,new_cell_locations)
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
            %   addEntries(obj,solve_dates,new_locations,new_thresholds,predictor_types,ranges)
            %
            %   This is basically a pass through to the solution.
            
            if ~obj.system_testing
                %NEURON.xstim.single_AP_sim.solution
                obj.solution.addToEntry(solve_dates,new_locations,new_thresholds,predictor_types,ranges);
                obj.saveData();
            end
        end
    end
    
    methods (Static,Hidden)
        function sortData(sign)
            %
            %   NEURON.xstim.single_AP_sim.logged_data.sortData(sign)
            %
            %   This sorts every saved data file so that future 
            %   requests are a lot quicker 
            %
            %   This is a hack ... :/
            
            %NOTE: I forget why I had to hack this together ...
            %I should document this ...
            %
            %I think it had something to do with the xstim_id determining
            %how the data was saved and requiring the xstim_id as an input 
            %but alas I forget and don't want to look at it right now ...
            
            base_path = NEURON.xstim.single_AP_sim.logged_data.getBasePath(sign);
            file_paths = NEURON.sl.dir.getList(base_path,'extension','.mat','output_type','paths');
            for iFile = 1:length(file_paths)
                cur_file_path = file_paths{iFile};
                h = load(cur_file_path);
                s = h.s;
                sol_obj = NEURON.xstim.single_AP_sim.solution(s.solution);
                if ~sol_obj.issorted
                    temp = sol_obj.getSortedObject;
                    s.solution = temp.getStruct();
                    save(cur_file_path,'s')
                end
            end
        end
        function base_path = getBasePath(sign)
            %
            %
            %    NEURON.xstim.single_AP_sim.logged_data.getBasePath()
            
            CLASS_NAME = 'NEURON.xstim.single_AP_sim.logged_data';
            
            if sign > 0
                sign_folder = 'pos';
            else
                sign_folder = 'neg';
            end
            
            base_path = NEURON.xstim.results_path_manager.getMyBasePath(CLASS_NAME);
            base_path = fullfile(base_path,sign_folder);
        end
    end
    
end