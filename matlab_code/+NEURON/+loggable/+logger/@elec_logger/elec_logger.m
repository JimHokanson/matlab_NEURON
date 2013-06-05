classdef elec_logger < logger
    
    properties
        log_data
        zero_scales
        xstim_obj
        data_linearization = {} %cell array of data
    end
    
    properties
        elec_obj
    end
    
    properties
        VERSION = 1;
    end
    
    
    methods %(Hidden)
        %Taken from NEURON.simulation.extracellular_stim.electrode
        % getLogData()
        %I'm not sure that a stim_struct is really something we want handed
        %around directly... :P No it is dervived from the information that
        %we know have direct access too! FIX THIS, please ma'am.
        function obj = elec_logger(elec_obj, xstim_obj, stim_struct)
            %getLogData
            %
            %   [log_data,zero_scales] = getLogData(objs)
            %
            %   OUTPUTS
            %   ===========================================================
            %   log_data    : output for sim_logger. Current format is the
            %       duration of each stimulus and of each break, with the
            %       exception of the first stimulus break (if present) at 
            %       time: t = 0
            %   zero_scales : (logical), for each stimulus transition time
            %   this indicates whether or not
            %
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
            
            [t_vec,all_scales] = getMergedStimTimes(xstim_obj);
            
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
            
        end
        
        %with this function here can we assimilate everything from stim()?
        
        %taken/modified from stim:
        %NEURON.simulation.extracellular_stim.sim_logger.matcher.stim
        function I = getMatchingEntries(obj,current_max_index)
           %
           %    NOTE: This method serves two purposes
           %    1) Population of data regarding the entry we are trying to
           %    match
           %    2) Trying to find that data in a previous entry 
           %
           %
           
           MAX_TIME_DIFF_ALLOWED = 1e-10; %Could probably be eps or 2*eps
           
           %NEURON.simulation.extracellular_stim.electrode.getLogData
           %obj.current_data_instance = obj.xstim_obj.elec_objs.getLogData();
           %VANA! DON'T FORGET TO TAKE THIS OUT OF ELECTRODES LATER...
           
           
           %Not sure if this comparision should be here ...
           if current_max_index == 0
               I = [];
               return
           end
           
           current_data_local = [obj.log_data, obj.zero_scales];
           stored_data_local  = obj.data_linearization;
                      
           %Might eventually switch to ismember if ever sorted ...
           %We can work on that later ...
           
           I = find(cellfun(@(x) arrayfcns.isequalfp(current_data_local,x,...
               MAX_TIME_DIFF_ALLOWED),stored_data_local(1:current_max_index)));           
        end
        
        %Taken from stim class.. we could just save it though right?
        % If we tell the thing to just save itself.. is that a sensible
        % design plan? Then no aspect of the logging inner workings are
        % available to the prediction side. They can retrieve the saved
        % info... ask for the new thing to be saved?
        %Should determining if somethign ought to be saved be handled
        %entirely through this class??? Is there ever a case when the
        %prediction end might want to/ need to specify whether or not
        %something ought to be saved?
        function data = getSavingStruct(obj)
        %function save(obj) %Functionality and stuff may be changed
        %later...
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
        %QUESTION: When we attempt to compare components of the electrode 
        %what do we compare and where is this currently occuring?
        %ANSWER: above in gME... ok....
        
    end
 
end




















