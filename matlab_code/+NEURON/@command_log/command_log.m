classdef command_log < handle_light
    %
    %   Class:
    %       NEURON.command_log
    %
    %   This class can log commands sent to NEURON, and the responses
    %   that are received back.
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) 
    
    properties
        commands  = {}       %cellstr
        responses = {}       %cellstr
        cur_index = 0
        command_success = []  %logical array
        %        execution_start_time
        %        execution_duration
    end
    
    properties (Hidden)
        initialized = false
        opt__default_init_size = 1000
    end
    
    methods
        %         function obj = command_log
        %
        %         end
        function initObject(obj)
            sz                  = obj.opt__default_init_size;
            obj.commands        = cell(sz,1);
            obj.responses       = cell(sz,1);
            obj.command_success = false(1,sz);
            obj.initialized     = true;
        end
        function addCommand(obj,command,response,success_flag)
            if ~obj.initialized
                obj.initObject;
            end
            
            next_index    = obj.cur_index + 1;
            obj.cur_index = next_index;
            
            obj.commands{next_index}        = command;
            obj.responses{next_index}       = response;
            obj.command_success(next_index) = success_flag;
            
        end
        function createHocFile(obj)
            %TODO: Implement method
        end
    end
    
end

