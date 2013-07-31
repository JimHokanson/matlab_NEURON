classdef gridPredictor < sl.obj.handle_light

    properties
        s
        old_locations
        new_locations
        old_thresholds
        new_low_d_stimulus
        old_low_d_stimulus
        method 
    end
    
    properties
        initialized
    end
    
    properties
       cur_index   = 0
       max_index   = 0
       groups_of_indices_to_run %{1 x max_index]
    end
    
    
    methods
        function new_indices = getNextGroup(obj)
            %
            %
            %   indices = getNextGroup(obj)
            %
            %   
           %Return an empty set of indices to finish ...

           if ~obj.initialized
              obj.initialize(); 
           end
           
           cur_index_local = obj.cur_index;
           if cur_index_local == obj.max_index
               new_indices = [];
               return
           end
           
           cur_index_local = cur_index_local + 1;
           obj.cur_index   = cur_index_local;

           new_indices = obj.groups_of_indices_to_run{cur_index_local};
        end
    end
    
    
    methods
        function obj  = gridPredictor(s_obj)
            obj.s      = s_obj;
            obj.method = 'linear';
        end
        
        %We should prolly make this a call to a super class
        function reset(obj) 
            obj.initialized = false;
        end
        
        function initialize(obj)            
            stim_manager   = obj.s.stimulus_manager;
            old_data_local = obj.s.old_data;
            
            [old_stim,obj.new_low_d_stimulus] = stim_manager.getLowDStimulusInfo();
            
            if isempty(old_stim)
                obj.old_low_d_stimulus = [];
                obj.old_thresholds     = [];
                obj.old_locatioans     = [];
            else
                unique_old_indices      = stim_manager.getUniqueOldIndices;
                obj.old_low_d_stimulus  = old_stim(unique_old_indices,:);
                obj.old_thresholds      = old_data_local.thresholds(unique_old_indices);
                obj.old_locations       = old_data_local.cell_locations(unique_old_indices,:);
            end
            
            new_data_obj = obj.s.new_data;
            solved_mask = new_data_obj.solution_available;
            
            obj.groups_of_indices_to_run = {find(~solved_mask)};
            obj.max_index = length(obj.groups_of_indices_to_run);
            obj.cur_index = 0;
            obj.initialized = true;
        end
        
        %this code would not need call the grouper. In theory after certain
        %groups were learned, you would just call this to learn the rest.
        function predicted_thresholds = predictThresholds(obj, new_indices)
            
            if ~obj.initialized
                obj.initialize(); 
            end
            obj.new_locations  = obj.s.new_data.cell_locations(new_indices,:); % can we be sure these are ordered?
            
            %What you really want, is the given grid when you first request
            %to predict thresholds. but this might do...  :P
            [xloc_new, ~, xi] = unique(obj.new_locations(:,1));
            [yloc_new, ~, yi] = unique(obj.new_locations(:,2));            
            [zloc_new, ~, zi] = unique(obj.new_locations(:,3));
            
%             % From our old_data and our recently solved values we dont want
%             % to use any point that is not within the range of the above 
%             % values...
%             solved_ind = obj.s.new_data.solved();
%             solved_locs_new = obj.s.new_data.cell_locations(solved_ind); %Fix me too!
%             solved_thrs_new = obj.s.new_data.thresholds(solved_ind);
%             solved_locs = obj.s.old_data.cell_locations;
%             solved_thrs = obj.s.old_data.thresholds; %logic?
%             
%             %hmmmmmm :P
%             solved_locs = [solved_locs; solved_locs_new];
%             solved_thrs = [solved_thrs; solved_thrs_new];
%            
%             
%             trainer = solved_locs(ind);  %FIX ME!!!!!
            
               
            %tic;      
            new_thresholds = gridN(obj.old_locations(:,1), obj.old_locations(:,2), obj.old_locations(:,3),...
                                   obj.old_thresholds, xloc_new, yloc_new, zloc_new);
            %toc;
            %don't replace/repeat known values!
%             xi = obj.new_locations(:,1);
%             yi = obj.new_locations(:,2);
%             zi = obj.new_locations(:,3);
            nx = length(xloc_new);
            ny = length(yloc_new);
            reformed_indices = xi + nx*(yi-1) + nx*ny*(zi-1);
            predicted_thresholds = new_thresholds(reformed_indices);
            
        end
    
    
    
    
    function [learned_low_d_stimuli,known_thresholds] = getLearnedLowDStimuliAndThresholds(obj)
            %This is a merger of the old stimuli
            %along with new stimuli for which we have threshold values

            new_data_local      = obj.s.new_data;
            %
            learned_new_indices = new_data_local.getIndicesOfUniqueStimuliWithKnownThresholds();
            
            if isempty(learned_new_indices) && isempty(obj.old_thresholds)
                learned_low_d_stimuli = [];
                known_thresholds            = [];
            elseif isempty(learned_new_indices)
                learned_low_d_stimuli = obj.old_low_d_stimulus;
                known_thresholds            = obj.old_thresholds;
            elseif isempty(obj.old_thresholds)
                learned_low_d_stimuli = obj.new_low_d_stimulus(learned_new_indices,:);
                known_thresholds            = new_data_local.thresholds(learned_new_indices);
            else
                learned_low_d_stimuli = [obj.old_low_d_stimulus; ...
                        obj.new_low_d_stimulus(learned_new_indices,:)];
                known_thresholds            = [obj.old_thresholds ...
                    new_data_local.thresholds(learned_new_indices)];
            end
        end
end
end
