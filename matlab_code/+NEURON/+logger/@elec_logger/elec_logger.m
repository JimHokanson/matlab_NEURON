classdef elec_logger < logger
    %
    %
    %
    %           OLD CLASS - SHOULD BE DELETED ...
    
    properties
        current_data_instance
        data_linearization = {} %cell array of data
        prev_trials = [] %this could be renamed... to something like id_log
    end
    
    properties %I might make this abstract to be defined from logger
        trial_objs = []
    end
    
    properties
        elec_obj
        xstim_obj
    end
    
    properties (Constant)
        VERSION = 1;
        type = 1;
    end
    
    %for now we can follow the same protocol even though three i but one
    %type...
    
    %or we can have the implementation in place... but not! follow the
    %protocol...
    
    methods %(Hidden)
        %Taken from NEURON.simulation.extracellular_stim.electrode
        % if stim_struct is loaded up, we will load it when we load stuff,
        % but not in this instantiation... Hopefully we can give this the
        % same form as the other loggers...
        function obj = elec_logger(elec_obj, xstim_obj, stim_struct)
            % ===========================================================
            % log_data : output for sim_logger. Current format is the
            % duration of each stimulus and of each break, with the
            % exception of the first stimulus break (if present) at
            % time: t = 0
            % zero_scales : (logical), for each stimulus transition time
            % this indicates whether or not
            %--------------------------------------------------------------
            
            obj.elec_obj = elec_obj;
            obj.xstim_obj = xstim_obj;
            
            % taken from stim constructor...
            if nargin == 2
               %This is essentially an initialization call
               return
            end
                        
            obj.data_linearization = stim_struct.data_linearization;
               
            %--------------------------------------------------------------
            
            [t_vec,all_scales] = getMergedStimTimes(xstim_obj); %...
            
            obj.zero_scales = all(all_scales == 0,2);
            
            if ~obj.zero_scales(end)
                error('Expected no stimulation specification at the end')
            end
            %NOTE: If we stimulate until the end then
            %we need to include a term that takes into account the length
            %of the simulation
            if obj.zero_scales(1)
                obj.log_data = diff(t_vec);
            else
                obj.log_data = diff(t_vec(2:end));
            end
            obj.current_data_instance = [log_data,zero_scales];
        end
        
        
        function I = getMatchingEntries(obj,current_max_index)
%
           % NOTE: This method serves two purposes
           % 1) Population of data regarding the entry we are trying to
           % match
           % 2) Trying to find that data in a previous entry
           %
           %
           
           MAX_TIME_DIFF_ALLOWED = 1e-10; %Could probably be eps or 2*eps
           
           %NEURON.simulation.extracellular_stim.electrode.getLogData
           %VANA! DON'T FORGET TO TAKE THIS OUT OF ELECTRODES LATER...
           
           
           %Not sure if this comparision should be here ...
           if current_max_index == 0
               I = [];
               return
           end
           
           current_data_local = obj.current_data_instance;
           stored_data_local = obj.data_linearization;
                      
           %Might eventually switch to ismember if ever sorted ...
           %We can work on that later ...
           
           % returns indices in stored_data_local for where the
           % current_data_local and it are the same, yes?
           I = find(cellfun(@(x) arrayfcns.isequalfp(current_data_local,...
               x, MAX_TIME_DIFF_ALLOWED),...
               stored_data_local(1:current_max_index)));
        end
        
        
        %old way of saving. Tissue usees no struct.. but resistanct is
        %little...
        function data = getSavingStruct(obj)
           data = struct(...
                'data_linearization',{obj.data_linearization},...
                'version',obj.VERSION);
        end
        
        function addCurrentInstance(obj)
            obj.data_linearization = [obj.data_linearization,...
                                     obj.current_data_instance];
        end
        function deleteIndices(obj,indices)
            obj.data_linearization(indices) = [];
        end        
        
        function save(obj)
            stim = obj.getSavingStruct();%#ok<NASGU>
            path = getLOggerPaths(obj);
            save(path, 'stim'); 
        end
        
    end
 
end

