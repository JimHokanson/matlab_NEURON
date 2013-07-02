classdef new_solution < sl.obj.handle_light
    %
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.new_solution
    %
    %   This class is meant to hold new threhsold data from simulations.
    %   All results will be initialized on startup but will not be valid
    %   until thresholds have been assigned by the predictor/solver.
    %
    %
    %   Questions
    %   ===================================================================
    %   1) How should this interact with the logged data ?????
    %
    %
    %   See Also:
    %   
    
    properties
       file_save_path
       stim_sign
    end
    
    properties
       solved           %(logical, [1 x n]) 
       cell_locations   %(numeric, [n x 3])
       thresholds       %(numeric, [1 x n])
       solved_dates     %(numeric, [1 x n]), Matlab time
       prediction_types %(numeric, [1 x n])
       ranges           %(numeric, [n x 2])
    end
    
    properties
       all_done %Make this a dependent property ... 
    end
    
    methods
        function value = get.all_done(obj)
           value = all(obj.solved); 
        end
    end
    
    methods
        function obj = new_solution(stim_sign,xstim_ID,cell_locations)
            %
            %
            %   This constructor is currently called in two different 
            %   situations.
            %
            %   1) To create a new instance
            %   2) To reload from disk to merge with logged data ...
            
            %NOTE: From the static method createFromDisk we will allow
            %empty cell locations ...
            obj.file_save_path = obj.getSavePath(stim_sign,xstim_ID);
            
            if ~isempty(cell_locations)
               obj.cell_locations = cell_locations;
               
               n_elements = size(cell_locations,1);
               obj.solved           = false(1,n_elements);
               obj.thresholds       = NaN(1,n_elements);
               obj.solved_dates     = NaN(1,n_elements);
               obj.prediction_types = NaN(1,n_elements);
               obj.ranges           = NaN(n_elements,2);
            end
        end
        function updateSolutions(obj,mask,thresholds,type,range_data)
           %
           %
           %    This method should update the properties and save the
           %    results to disk ...
           
            
            %TODO: 
            %1) Update properties above
            %2) Create log entry ...
            
            
            
            
            obj.saveToDisk();
            
        end
        function saveToDisk(obj)
           s = sl.obj.toStruct(obj);
           save(obj.file_save_path,'s');
        end
        function [solved_indices, thresholds] = getSolvedIndicesAndThresholds(obj)
            %This might be useful for learning algorithms ...
        end
        function appplied_stim_obj = getAppliedStimulusObject(obj)
           %
           %
           %    
           %    OUTPUTS
           %    ===========================================================
           %    appplied_stim_obj : Class: NEURON.xstim.single_AP_sim.applied_stimuli
        end
        function save_path = getSavePath(obj,stim_sign,xstim_ID)
            %
            %
            %   save_path = getSavePath(obj,stim_sign,xstim_ID)
            %
            %
            %   NOTE: This is very similar to code in:
            %   NEURON.xstim.single_AP_sim.new_solution
            %
            %   We might want to make a static method somewhere that both
            %   use ...
                        
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
            save_path = sl.dir.createFolderIfNoExist(base_path,sign_folder,file_name); 
        end
    end
    
    methods (Static,Hidden)
        function getNewSolutionData(stim_sign,logged_data_obj,xstim_ID)
           %
           %
           %    getNewSolutionData(stim_sign,logged_data_obj,xstim_ID)
           %
           %    This is a request from the object:
           %    NEURON.xstim.single_AP_sim.logged_data
           %    
           %    It allows taking data that was saved (learned) and merging
           %    the results with the logged data.
           %    
           %    INPUTS
           %    ===========================================================
           %    logged_data : Class: NEURON.xstim.single_AP_sim.logged_data
           %    stim_sign :
           %    xstim_ID  :  
           %
           %
           %    See Also:
           %    NEURON.xstim.single_AP_sim.logged_data.loadData
           
               [obj,file_exists] = NEURON.xstim.single_AP_sim.new_solution.createFromDisk(stim_sign,xstim_ID);
               
               if file_exists
                  mask = obj.solved;  %Only pass in solved entries ...
                  
                  %TODO: Pass in properties from object to method below
                  %UNFINISHED           UNFINISHED 
                  logged_data_obj.addEntries(obj.solved_dates(mask),obj.cell_locations(mask,:)) 
                  
                  delete(obj.file_save_path);
               end
        end
        function [obj,file_exists] = createFromDisk(stim_sign,xstim_ID)
           %createFromDisk
           %
           %    [obj,file_exists] = createFromDisk(stim_sign,xstim_ID)
           %
           %    FULL PATH:
           %    NEURON.xstim.single_AP_sim.new_solution.createFromDisk
           
           obj = NEURON.xstim.single_AP_sim.new_solution(stim_sign,xstim_ID,[]);
           
           file_exists = exist(obj.file_save_path,'file');

           if file_exists
              h = load(obj.file_save_path);
              s = h.s;
              %The file_save_path is already loaded ...
              sl.struct.toObject(obj,s,'fields_ignore','file_save_path');
           end
        end

    end
    
end

