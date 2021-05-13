classdef new_solution < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_sim.new_solution
    %
    %   This class is meant to hold new data from simulations.
    %   All results will be initialized on startup but will not be valid
    %   until the simulations have been run.
    %
    %   Design
    %   ------
    %   When solving for new solutions, they will go here. We will have the
    %   option of saving the data to disk. It will get saved separately
    %   from the old data to try and reduce merges between new and old data
    %   while solving. In other words, we periodically make save points
    %   and rather than constantly saving with the potentially larger old
    %   data, we save in our own file and merge later.
    %
    %   When loading the object from disk, it will only be used for a merge
    %   with the old data. It is not valid to load this from disk for later
    %   usage. This object should normally be created by the request
    %   handler.
    %
    %
    %   Status
    %   ------
    %   We still need to figure out how to implement the solve later
    %   methods
    %
    %   Questions
    %   ---------
    %   1) How should this interact with the logged data ?????
    %
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.request_handler
    %   NEURON.xstim.single_AP_sim.predictor
    %   NEURON.xstim.single_AP_sim.logged_data
    
    %Set by solver on a cell to setSystemTester
    properties
       system_testing = false;
    end
    
    properties
        file_save_path
    end
    
    properties
        solved %[1 x n], This should be set if values are learned or
        %predicted. In this case threshold values should be available.
        
    end
    
    properties
        d2 = '----  Fine to access directly for now ----'
       	cell_locations  %[n x 3]
        tested_scales   %[1 x n]
        success  	%[1 x n]
        tissue_fried    %[1 x n]
        initial_stim_time   %[1 x n]
        final_stim_time     %[1 x n]
        membrane_potential  %{1 x n}
        ap_propagated   %[1 x n]
        solve_dates 	%[1 x n]

    end
        
    methods
        function obj = new_solution(xstim_ID,cell_locations,scales)
            %
            %
            %   This constructor is currently called in two different
            %   situations.
            %
            %   1) To create a new instance
            %   2) To reload from disk to merge with logged data ...
            %   NEURON.xstim.single_AP_sim.new_solution.createFromDisk
            
            %NOTE: From the static method createFromDisk we will allow
            %empty cell locations ...
            obj.file_save_path = obj.getSavePath(xstim_ID);
            
            if ~isempty(cell_locations)
                obj.cell_locations = cell_locations;
                obj.tested_scales = scales;
                
                n_elements = size(cell_locations,1);
                
                obj.success = false(1,n_elements);
                obj.tissue_fried = false(1,n_elements);
                obj.initial_stim_time = NaN(1,n_elements);
                obj.final_stim_time = NaN(1,n_elements);
                obj.membrane_potential = cell(1,n_elements);
                obj.ap_propagated = false(1,n_elements);
                obj.solve_dates = NaN(1,n_elements);
                
                obj.solved = false(1,n_elements);
            end
        end
    end
    
    %Predictor interface methods ==========================================
    methods
        function appplied_stim_obj = getAppliedStimulusObject(obj,xstim_obj)
            %
            %    appplied_stim_obj = getAppliedStimulusObject(obj,xstim_obj)
            %
            %    This in general only needs to be called by the
            %    predictor ...
            %
            %    OUTPUTS
            %    -------
            %    appplied_stim_obj : Class: NEURON.xstim.single_AP_sim.applied_stimuli
            
            appplied_stim_obj = NEURON.xstim.single_AP_sim.applied_stimuli(xstim_obj,obj.cell_locations);
        end
    end
    
    
    %Interface Methods ====================================================
    methods
        %Will solve later methods explained:
        %
        %   1) A class calls addWillSolveLaterIndices() to register
        %   a callback
        %   2) On finishing, the predictor will call:
        %   applyWillSolveLaterMethods
        %   3) That method calls each callback, which adds its data
        %   to this class ...
        %
        %
        function addWillSolveLaterIndices(obj,indices,fh)
            %
            %
            %   
            
            keyboard
            
           obj.will_solve_later(indices) = true;
           obj.will_solve_later_fh = [obj.will_solve_later_fh {fh}];
        end
        function applyWillSolveLaterMethods(obj)
            
            
            keyboard
            
            %NOTE: We could also check if everything is done ...
            %This isn't critical but in general will need to be true ...
            fh_cell_array = obj.will_solve_later_fh;
            n_methods = length(fh_cell_array);
            for iMethod = 1:n_methods
               feval(fh_cell_array{iMethod}) 
            end
        end
    end
    
    methods
        function indices = getIndicesOfUniqueStimuliWithKnownThresholds(obj)
           %NEURON.xstim.single_AP_sim.new_solution.getIndicesOfUniqueStimuliWithKnownThresholds
           indices = find(obj.solved_and_unique); 
        end
        function copySolutions(obj,source_indices,redundant_indices)
            %
            %
            %   NOTE: This method will generally be called from methods
            %   which the method .applyWillSolveLaterMethods() calls
            %   using registered callbacks given to the method
            %   .addWillSolveLaterIndices()
            %
            %   
            %
            %
            %   See Also:
            %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher.applyStimulusMatches
            
            keyboard
            
            if ~all(obj.solved(source_indices))
                error('Not all source indices have been solved')
            end
    
            t  = obj.thresholds(source_indices);
            t2 = obj.prediction_types(source_indices);
            r  = obj.ranges(source_indices,:);
            
            obj.updateSolutions(redundant_indices,t,t2,r,false);
            
        end
        function updateSolutions(obj,indices,thresholds,type_or_types,range_data,is_unique)
            %
            %
            %    updateSolutions(obj,indices,thresholds,type,range_data)
            %
            %    This method should update the properties and save the
            %    results to disk ...
            %
            %    FULL PATH:
            %    NEURON.xstim.single_AP_sim.new_solution.updateSolutions

            keyboard
            
            if any(obj.solved(indices))
                %This will eventually be allowed by not yet and perhaps
                %not by this method ...
                error('We are trying to set thresholds for values that are already solved')
            end
            
            obj.solved(indices)           = true;
            obj.solved_and_unique(indices) = is_unique;
            obj.thresholds(indices)       = thresholds;
            obj.solved_dates(indices)     = now;
            obj.prediction_types(indices) = type_or_types;
            obj.ranges(indices,:)         = range_data;
            
            %This needs to be here, not above
            if obj.system_testing
               return 
            end
            
            obj.saveToDisk();
        end
        function saveToDisk(obj)
            
            if obj.system_testing
               return 
            end
            
            s = NEURON.sl.obj.toStruct(obj);  %#ok<NASGU>
            %NOTE: We will only reload from disk for merging with old data.
            
            save(obj.file_save_path,'s');
        end
        function [solved_indices, thresholds] = getSolvedIndicesAndThresholds(obj)
            %This might be useful for learning algorithms ...
            %
            %
            %   NOTE: We have two types of solved values:
            %   1) solved, threshold available
            %   2) solvable - thresholds unavailable, once we learn 
            %       other values we will know these values ...

            solved_indices = find(obj.solved);
            thresholds     = obj.thresholds(obj.solved);
        end
        
        function save_path = getSavePath(obj,xstim_ID)
            %
            %
            %   save_path = getSavePath(obj,stim_sign,xstim_ID)
            %
            %
            %   NOTE: This is very similar to code in:
            %   NEURON.xstim.single_AP_sim.logged_data
            %
            %   We might want to make a static method somewhere that both
            %   use ...
            
            base_path = NEURON.xstim.results_path_manager.getMyBasePath(obj);
            file_name = xstim_ID.getSaveString;
            
            save_path = NEURON.sl.dir.createFolderIfNoExist(true,base_path,file_name);
        end
        function mergeResultsWithOld(obj,logged_data_obj)
            %
            %
            %
            
            if obj.system_testing
               return 
            end
            
            logged_data_obj.addEntries(obj)
            
            delete(obj.file_save_path);
        end
    end
    
    methods (Static,Hidden)
        function loadAndMergeNewData(logged_data_obj,xstim_ID)
            %
            %
            %    loadAndMergeNewData(stim_sign,logged_data_obj,xstim_ID)
            %
            %    This is a request from the object:
            %    NEURON.xstim.single_AP_sim.logged_data
            %
            %    It allows taking data that was saved (learned) and merging
            %    the results with the logged data.
            %
            %    INPUTS
            %    ------
            %    logged_data : Class: NEURON.xstim.single_AP_sim.logged_data
            %    stim_sign :
            %    xstim_ID  :
            %
            %
            %    See Also:
            %    NEURON.xstim.single_AP_sim.logged_data.loadData
            
            [obj,file_exists] = NEURON.xstim.single_sim.new_solution.createFromDisk(xstim_ID);
            
            if file_exists
                obj.mergeResultsWithOld(logged_data_obj);
            end
        end
        function [obj,file_exists] = createFromDisk(xstim_ID)
            %createFromDisk
            %
            %    [obj,file_exists] = createFromDisk(stim_sign,xstim_ID)
            %
            %    FULL PATH:
            %    NEURON.xstim.single_AP_sim.new_solution.createFromDisk
            
            obj = NEURON.xstim.single_sim.new_solution(xstim_ID,[]);
            
            file_exists = exist(obj.file_save_path,'file');
            
            if file_exists
                h = load(obj.file_save_path);
                s = h.s;
                %The file_save_path is already loaded ...
                NEURON.sl.struct.toObject(obj,s,'fields_ignore','file_save_path');
            end
        end
        
    end
    
end

