classdef stim < NEURON.sl.obj.handle_light
    %
    %   Class: NEURON.simulation.extracellular_stim.sim_logger.matcher.stim
    %

    properties
       data_linearization = {} %cell array of data

       %.getMatchingEntries()
       current_data_instance
    end
    
    properties (Constant)
       VERSION = 1 
    end
    
    methods
        function obj = stim(stim_struct)
           %
           %
           %    ??? - when do I call this without inputs????
            
           if nargin == 0
               %This is essentially an initialization call
               return
           end
           obj.data_linearization = stim_struct.data_linearization;
        end
        function I = getMatchingEntries(obj,xstim_obj,current_max_index)
           %
           %    NOTE: This method serves two purposes
           %    1) Population of data regarding the entry we are trying to
           %    match
           %    2) Trying to find that data in a previous entry 
           %
           %
           
           MAX_TIME_DIFF_ALLOWED = 1e-10; %Really could probably be eps or 2*eps
           
           %NEURON.simulation.extracellular_stim.electrode.getLogData
           obj.current_data_instance = xstim_obj.elec_objs.getLogData();
           
           %Not sure if this comparision should be here ...
           if current_max_index == 0
               I = [];
               return
           end
           
           current_data_local = obj.current_data_instance;
           stored_data_local  = obj.data_linearization;
                      
           %Might eventually switch to ismember if ever sorted ...
           %We can work on that later ...
           
           I = find(cellfun(@(x) arrayfcns.isequalfp(current_data_local,x,...
               MAX_TIME_DIFF_ALLOWED),stored_data_local(1:current_max_index)));           
        end
        function addCurrentInstance(obj)
           obj.data_linearization = [obj.data_linearization obj.current_data_instance]; 
        end
        function deleteIndices(obj,indices)
           obj.data_linearization(indices) = []; 
        end
        function data = getSavingStruct(obj)
           data = struct(...
                'data_linearization',{obj.data_linearization},...
                'version',obj.VERSION);
        end
    end
    
end

