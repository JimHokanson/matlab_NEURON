classdef log < NEURON.sl.obj.handle_light
    %
    %   Class:
    %       NEURON.cmd.log
    %
    %   This class can log commands sent to NEURON, and the responses
    %   that are received back.
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Finish createHocFile method
    
    properties
        commands  = {}       %cellstr
        responses = {}       %cellstr
        cur_index = 0
        command_success = []  %logical array
        %        execution_start_time
        %        execution_duration
    end
    
    properties (Hidden)
        initialized            = false
        opt__default_init_size = 1000
    end
    
    methods (Hidden)
        function initObject(obj)
            %initObject
            %
            %   initObject(obj)
            %
            %   This method was created to delay initialization of varibles
            %   until the class is actually used. This makes the class a
            %   bit more light weight during creation and prevents the
            %   caller from having to keep track of whether or not its
            %   reference to the class is an instance or just empty.
            
            sz                  = obj.opt__default_init_size;
            obj.commands        = cell(sz,1);
            obj.responses       = cell(sz,1);
            obj.command_success = false(1,sz);
            obj.initialized     = true;
        end
    end
    
    methods
        function addCommand(obj,command,response,success_flag)
            %addCommand
            %   
            %   addCommand(obj,command,response,success_flag)
            %
            %   INPUTS
            %   ===========================================================
            
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
            %The goal of this method was to allow creation of a hoc
            %file which one could run to rerun the commands that were
            %previously run
            %
            %   This method may be insufficient in cases where binary data
            %   transfer occurs between Matlab and NEURON.
            %
            %   Thought was to provide either file_path or a prompt
            
        end
    end
    
end

