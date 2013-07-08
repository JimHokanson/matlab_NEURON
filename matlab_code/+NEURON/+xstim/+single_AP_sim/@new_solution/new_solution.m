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
    %   Design
    %   ===================================================================
    %   When solving for new solutions, they will go here. We will have the
    %   option of saving the data to disk. It will get saved separately
    %   from the old data to try and reduce merges between new and old data
    %   while solving.
    %
    %   When loading the object from disk, it will only be used for a merge
    %   with the old data. It is not valid to load this from disk for later
    %   usage. This object should normally be created by the request
    %   handler.
    %
    %
    %   Status
    %   ===================================================================
    %   We still need to figure out how to implement the solve later
    %   methods
    %
    %   Questions
    %   ===================================================================
    %   1) How should this interact with the logged data ?????
    %
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.request_handler
    %   NEURON.xstim.single_AP_sim.predictor
    
    properties
        file_save_path
        stim_sign
    end
    
    properties
        solved %[1 x n], This should be set if values are learned or
        %predicted. In this case threshold values should be available.
        
        %The idea with these properties is to allow handling
        %of thresholds that will be dependent on other thresholds
        %I have yet to determine how we will call this code at the end
        %to finally apply the solutions ...
        will_solve_later %(logical, [1 x n]) These should be set
        %by stimulus matchers or other classes which will know 
        %the solution once other values have been solved. In general
        %we will not worry too much about updating these values during the
        %prediction phase as they should contribute little to helping with
        %the prediction step. The predictor will call a method to finalize 
        %these values 
        will_solve_later_fh = {}
        %   Hold callback functions, nothing will be passed, the redundant
        %   data will be held by the object implementing the callback ...
        %
        %   Known interfacing classes:
        %   -----------------------------------------------
        %    1) NEURON.xstim.single_AP_sim.applied_stimulus_matcher
        %    2)
        
        
        cell_locations   %(numeric, [n x 3])
        thresholds       %(numeric, [1 x n])
        solved_dates     %(numeric, [1 x n]), Matlab time
        prediction_types %(numeric, [1 x n])
        ranges           %(numeric, [n x 2])
    end
    
    properties (Dependent)
        solution_available  %(logical, [1 x n])
        all_done %
    end
    
    methods
        function value = get.all_done(obj)
            value = all(obj.solution_available);
        end
        function value = get.solution_available(obj)
           value = obj.solved | obj.will_solve_later; 
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
            %   NEURON.xstim.single_AP_sim.new_solution.createFromDisk
            
            %NOTE: From the static method createFromDisk we will allow
            %empty cell locations ...
            obj.file_save_path = obj.getSavePath(stim_sign,xstim_ID);
            
            if ~isempty(cell_locations)
                obj.cell_locations = cell_locations;
                
                n_elements = size(cell_locations,1);
                obj.solved           = false(1,n_elements);
                obj.will_solve_later = false(1,n_elements);
                obj.thresholds       = NaN(1,n_elements);
                obj.solved_dates     = NaN(1,n_elements);
                obj.prediction_types = NaN(1,n_elements);
                obj.ranges           = NaN(n_elements,2);
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
            %    ===========================================================
            %    appplied_stim_obj : Class: NEURON.xstim.single_AP_sim.applied_stimuli
            
            appplied_stim_obj = NEURON.xstim.single_AP_sim.applied_stimuli(xstim_obj,obj.cell_locations);
        end
    end
    
    
    %Interface Methods ====================================================
    methods
        function addWillSolveLaterIndices(obj,indices,fh)
            %
            %
            %   
           obj.will_solve_later(indices) = true;
           obj.will_solve_later_fh = [obj.will_solve_later_fh {fh}];
        end
        function applyWillSolveLaterMethods(obj)
            
            %NOTE: We could also check if everything is done ...
            %This isn't critical but in general will need to be true ...
            fh_cell_array = obj.will_solve_later_fh;
            n_methods = length(fh_cell_array);
            for iMethod = 1:n_methods
               feval(fh_cell_array{iMethod}) 
            end
        end
    
        function copySolutions(obj,source_indices,redundant_indices)
            %
            %
            %   NOTE: This method will generally be called from methods
            %   which applyWillSolveLaterMethods() calls
            %
            %   See Also:
            %   NEURON.xstim.single_AP_sim.applied_stimulus_matcher.applyStimulusMatches
            
            if ~all(obj.solved(source_indices))
                error('Not all source indices have been solved')
            end
    
            t  = obj.thresholds(source_indices);
            t2 = obj.prediction_types(source_indices);
            r  = obj.ranges(source_indices,:);
            
            obj.updateSolutions(redundant_indices,t,t2,r);
            
        end
        function updateSolutions(obj,indices,thresholds,type_or_types,range_data)
            %
            %
            %    updateSolutions(obj,indices,thresholds,type,range_data)
            %
            %    This method should update the properties and save the
            %    results to disk ...
            %
            %    FULL PATH:
            %    NEURON.xstim.single_AP_sim.new_solution.updateSolutions
            
            if any(obj.solved(indices))
                %This will eventually be allowed by not yet and perhaps
                %not by this method ...
                error('We are trying to set thresholds for values that are already solved')
            end
            
            obj.solved(indices)           = true;
            obj.thresholds(indices)       = thresholds;
            obj.solved_dates(indices)     = now;
            obj.prediction_types(indices) = type_or_types;
            obj.ranges(indices,:)         = range_data;
            
            obj.saveToDisk();
        end
        function saveToDisk(obj)
            
            s = sl.obj.toStruct(obj); 
            
            s.will_solve_later(:) = false;
            s.will_solve_later_setter = [];
            %NOTE: If recreating from disk we don't want to
            %solve the solutions later ...
            %
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
        
        function save_path = getSavePath(obj,stim_sign,xstim_ID)
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
            
            if stim_sign > 0
                sign_folder = 'pos';
            else
                sign_folder = 'neg';
            end
            save_path = sl.dir.createFolderIfNoExist(true,base_path,sign_folder,file_name);
        end
        function mergeResultsWithOld(obj,logged_data_obj)
            mask = obj.solved;  %Only pass in solved entries ...
            
            %TODO: Pass in properties from object to method below
            %UNFINISHED           UNFINISHED
            keyboard
            logged_data_obj.addEntries(obj.solved_dates(mask),obj.cell_locations(mask,:))
            
            delete(obj.file_save_path);
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
                obj.mergeResultsWithOld(logged_data_obj);
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

