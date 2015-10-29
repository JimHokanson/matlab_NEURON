classdef grouper < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.grouper
    %
    %   The goal of this class is to determine the order in which points 
    %   are solved. The first approach uses the distance between the
    %   applied stimuli. Although this has it problems, it works ok and
    %   other methods can always be implemented for improvement.
    %
    %   IMPORTANT DESIGN DECISION
    %   ===================================================================
    %   This class is exposed as a generator object. This means that
    %   the caller iterates over the next set of indices returned until
    %   nothing is returned. IMPORTANTLY, this class reserves the right
    %   to change the groups as more threshold information is generated.
    %
    %   MAIN METHODS
    %   ========================================================
    %   NEURON.xstim.single_AP_sim.grouper.getNextGroup
    %   NEURON.xstim.single_AP_sim.grouper.initialize
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   The algorithm being used in this class could be improved
    %   significantly. I'm not sure if it is better to implement subclasses
    %   or switches on the grouping method ...
    
    
    properties
       s %Reference to solver object
       %
       %   Needs access to:
       %   1) stimulus_manager
       %   2) new_data - only work with unsolved points (non-redundant)
       %    Anything else????
       opt__max_non_rand_size = 10000 %Maximum # of points before
       %just using random points ...
       opt__min_group_size  = 20
       opt__n_bins          = 20  %This is the target size. If the # of 
       %entries in a group is less than .opt__min_group_size then
       %groups are merged ...
    end
    
    properties
       %NOTE: What we want are private properties that are shown
       %in the display but not accessible unless we are in a "debug mode"
       d1 = '---- Don''t Change, Access via .getNextGroup() ----'
       initialized = false
       imd %Class: sci.cluster.iterative_max_distance
       cur_index   = 0
       max_index   = 0
       groups_of_indices_to_run %{1 x max_index]
    end
    
    methods
        function obj = grouper(s_obj)
           obj.s = s_obj;  
        end
        function reset(obj)
           obj.initialized = false; 
        end
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
    
end

