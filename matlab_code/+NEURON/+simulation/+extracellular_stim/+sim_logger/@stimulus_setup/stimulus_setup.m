classdef stimulus_setup
    %
    %   Class that logs enough information to recreate stimulus setup if
    %   necessary
    %
    %
    
    properties
       all_stim_times
       all_stim_scales
       electrode_locations
       
       tissue_resistivity
    end
    
    methods
        function obj = stimulus_setup(xstim_obj)
           elec_objs  = xstim_obj.elec_objs;
           
           tissue_obj = xstim_obj.tissue_obj;
           
           %TODO: Eventually clean this up and encapsulate more
           
           obj.tissue_resistivity = tissue_obj.resistivity;
           
           obj.electrode_locations = vertcat(elec_objs.xyz);
           
           [obj.all_stim_times,obj.all_stim_scales] = getMergedStimTimes(elec_objs);
           
        end
        function flag = eq(obj,objs)
           if isempty(objs)
               flag = false;
           else
               n_objs = length(objs);
               flag = true(1,length(objs));
               for iObj = 1:n_objs
                  cur_obj = objs(iObj);
                  flag(iObj) = isequal(obj.all_stim_times,cur_obj.all_stim_times) && ...
                      isequal(obj.all_stim_scales,cur_obj.all_stim_scales) && ...
                      isequal(obj.electrode_locations,cur_obj.electrode_locations) && ...
                      isequal(obj.tissue_resistivity,cur_obj.tissue_resistivity);
               end
           end
        end
    end
    
end

