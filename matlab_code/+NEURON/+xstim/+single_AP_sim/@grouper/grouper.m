classdef grouper < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.grouper
    %
    %
    %   NOTE: In some grouper implementations we could
    %   
    
    
    properties
       p %Reference to predictor object
       %
       %   Needs access to:
       %   1) new solution data
       %   2) old stimuli
       %   3) new stimuli 
       opt__min_group_size = 20;
       opt__n_bins         = 20; %This is the target size. If the # of 
       %entries in a group is less than .opt__min_group_size then
       %groups are merged ...
    end
    
    properties (Hidden)
       initialized = false
       imd %Class: sci.cluster.iterative_max_distance
       cur_index   = 0
       max_index   = 0
       groups_of_indices_to_run %[1 x n]
    end
    
    methods
        function obj = grouper(p_obj)
           obj.p = p_obj;  
        end
        function indices = getNextGroup(obj)
           %Return an empty set of indices to finish ...

           if ~obj.initialized
              obj.initialize(); 
           end
           
           cur_index_local = obj.cur_index;
           if cur_index_local == obj.max_index
               indices = [];
               return
           end
           
           cur_index_local = cur_index_local + 1;
           obj.cur_index   = cur_index_local;

           indices = obj.groups_of_indices_to_run{cur_index_local};
        end
    end
    
end

