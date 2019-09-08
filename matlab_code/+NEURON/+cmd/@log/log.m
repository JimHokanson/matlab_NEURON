classdef log < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.cmd.log
    %
    %   This class can log commands sent to NEURON, and the responses
    %   that are received back.
    %
    %   See Also
    %   --------
    %   NEURON.cmd
    %   NEURON.cmd.write
    
    properties
        commands  = {}       %cellstr
        responses = {}       %cellstr
        cur_index = 0
        command_success = []  %logical array
        execution_duration = []
    end
    
    properties (Hidden)
        h_tic
        initialized = false
        opt__default_init_size = 1000
    end
    
    properties (Dependent)
        command_history
    end
    
    methods
        function value = get.command_history(obj)
            if obj.cur_index == 0
                value = '';
            else
                newline_added_commands = cellfun(@(x) sprintf('%s\n',x),obj.commands(1:obj.cur_index),'un',0);
                value = [newline_added_commands{:}];
                value(end) = [];
            end
        end
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
            obj.execution_duration = zeros(sz,1);
            obj.initialized     = true;
            
        end
    end
    
    methods
        function initCommand(obj,command)
            if ~obj.initialized
                obj.initObject;
            end
            
            next_index = obj.cur_index + 1;
            obj.cur_index = next_index;
            
            obj.commands{next_index} = command;
            obj.h_tic = tic;
        end
        function terminateCommand(obj,response,success_flag)
            index = obj.cur_index;
            obj.responses{index} = response;
            obj.command_success(index) = success_flag;
            obj.execution_duration(index) = toc(obj.h_tic);
        end
    end
    
end

