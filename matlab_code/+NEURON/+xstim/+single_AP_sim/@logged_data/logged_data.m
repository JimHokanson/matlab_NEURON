classdef logged_data < sl.obj.handle_light
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
       xstim_ID
    end
    
    %Old values
    %----------------------------------------------
    properties        
       solution %Class: xstim.single_AP_sim.solution 
    end 

    methods
        function obj = logged_data(stim_sign,xstim_ID)
            %logged_data
            %
            %   obj = logged_data(stim_sign,xstim_ID)
            %
            %   INPUTS
            %   ===========================================================
            %   stim_sign :
            %   xstim_ID  : NEURON.logger.ID
                        
            base_path = NEURON.xstim.results_path_manager.getMyBasePath(obj);
            file_name = xstim_ID.getSaveString;

            if stim_sign > 0
                sign_folder = 'pos';
            else
                sign_folder = 'neg';
            end
            obj.xstim_ID  = xstim_ID;
            obj.file_path = sl.dir.createFolderIfNoExist(true,base_path,sign_folder,file_name);
            obj.stim_sign = stim_sign;
            obj.loadData(xstim_ID);
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
            
            %f the new solution object has anything logged on disk
            NEURON.xstim.single_AP_sim.new_solution.getNewSolutionData(obj.stim_sign,obj,xstim_ID);
        end
        function saveData(obj)
           %
           %
           %    saveData(obj)    
           
           s.VERSION  = obj.VERSION;
           s.solution = obj.solution.getStruct();
           s.VERSION  = obj.VERSION; 
           s.xstim_ID = obj.xstim_ID.getStruct(); %#ok<STRNU>
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
            %   addEntries(obj,stim_sign,new_cell_locations,new_thresholds,predictor_types,ranges)
            %
            %   This is basically a pass through to the solution.

            %TODO: replace with varargin
            
            obj.solution.addToEntry(solve_dates,new_locations,new_thresholds,predictor_types,ranges);
            obj.saveData();
        end
        
        

        
    end

end