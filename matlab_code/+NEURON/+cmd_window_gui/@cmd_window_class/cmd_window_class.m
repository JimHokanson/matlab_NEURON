classdef (Hidden) cmd_window_class < NEURON.sl.obj.handle_light
    %
    %   Class:
    %       NEURON.cmd_window_gui.cmd_window_class
    %
    %   Implementation Note:
    %   -------------------------------------------------------------------
    %   We've hidden the class so that the user doesn't see it with
    %   tab-complete
    
    %Delete - don't allow delete past oc>
    
    
    properties
        cmd_obj      %Class: NEURON.cmd
        fig_handle   %Figure handle referenec
        h            %Reference to all handles in GUI
        %KNOWN HANDLES
        %   .edit__cmd_window
        %   .static__busy_status  %Indicates busy or not ...
        last_edit_box_value
    end
    
    properties
       current_text_box_string
       current_min_index = 3 %Index beyond which one can not delete ...
    end
    
%     properties 
%        
%     end
%     
%     properties (Dependent)
%        cur_edit_box_value 
%     end
%     
%     methods 
%         function value = get.cur_edit_box_value(obj)
%            value = get(obj.h.edit__cmd_window,'String'); 
%         end
%         function set.cur_edit_box_value(obj,value)
%            set(obj.h.edit__cmd_window,'String',value)
%         end
%     end
    
    methods
        function obj = cmd_window_class(cmd_obj)
            %
            %
            %    obj = cmd_window_gui(*cmd_obj)
            %
            %    OPTIONAL INPUTS
            %    ==================================================
            %    cmd_obj : Class: NEURON.cmd, If not passed in one will be
            %        created
            
            if ~exist('cmd_obj','var')
                N = NEURON;
                obj.cmd_obj = N.cmd_obj;
            else
                obj.cmd_obj = cmd_obj;
            end
            
            %Load gui and initialize
            obj.fig_handle = hgload(obj.getFigPath);
            obj.h = guihandles(obj.fig_handle);
            setappdata(obj.fig_handle,'obj',obj);
            
            %Initialize edit box
            set(obj.h.edit__cmd_window,'KeyPressFcn',@obj.CB__key_press)
            set(obj.h.edit__cmd_window,'ButtonDownFcn',@obj.CB__button_down)
            
            
            resetPrompt(obj)
            
            set(obj.h.static__busy_status,'String','')
            
        end
    end
    
    methods
        function resetPrompt(obj)
            %This function should reset everything ...
            obj.current_min_index = 3;
            obj.current_text_box_string = 'oc>';
            obj.setCurrentGUIString;
            %set(obj.h.edit__cmd_window,'String','oc>')
        end
        function printPrompt(obj)
           %Get string, add on new string
           obj.current_text_box_string = [obj.current_text_box_string char(10) 'oc>'];
           obj.current_min_index = length(obj.current_text_box_string);
           obj.setCurrentGUIString;
        end
        function evaluateCommand(obj)
            
            %1) Get latest command
            %----------------------------------------------
            next_command = obj.getNextCommand;
            
            %2) Handle edge cases
            %----------------------------------------------
            if isempty(next_command)
                obj.printPrompt;
                return
            elseif strcmp(next_command,'asdfasdf')
                %What is clear command for hoc?
               
                
                return
            end
            
            
            
            %NOT YET FINISHED
            
%             c = obj.cmd_obj;
%             
%             
%             
          fprintf('Next Command: %s\n',next_command)  
            set(obj.h.static__busy_status,'String','Busy')

            c = obj.cmd_obj;
            
            %debug
            %max_wait
            %throw_error
            [flag,results] = c.run_command(next_command);
            
            %:/ => can't color partial text ...
            
            if ~isempty(results)
            obj.current_text_box_string = sprintf('%s\n%s',...
                    obj.current_text_box_string,results);
            end
            
            %pause(2)
            
%             %set(obj.
%             
%             %1) Run command
%             %2) Print result
%             %3) Print prompt
%             
%             
%             
            set(obj.h.static__busy_status,'String','')
              obj.printPrompt;
        end
        function next_command = getNextCommand(obj)
            %NOTE: On return, return isn't yet placed in string ...
            next_command = strtrim(obj.current_text_box_string(obj.current_min_index+1:end));
        end
        function handleDeletion(obj,string_before_deletion)
            %TODO: Handle deletion before and after current min index
            %
            
            %1) Assume single character, and handle case
            %2) How to handle detection of where 
        end
        function getCurrentStringFromGUI(obj)
            uicontrol(obj.h.static__busy_status)
            uicontrol(obj.h.edit__cmd_window) 
            obj.current_text_box_string = get(obj.h.edit__cmd_window,'String');
        end
        function setCurrentGUIString(obj,value)
            if nargin == 1
                set(obj.h.edit__cmd_window,'String',obj.current_text_box_string) 
            else
                set(obj.h.edit__cmd_window,'String',value) 
            end
        end
    end
    
    methods (Static)
        function fig_path = getFigPath()
            class_path = getMyPath;
            fig_path   = fullfile(class_path,'cmd_window.fig');
        end
    end
    
    %CALLBACKS    %========================================================
    methods (Static)
        function CB__key_press(~,char_info)
            %(a,b)
            %a
            %    handle to edit box
            %b
            %    Character: ''
            %              Modifier: {'shift'}
            %                   Key: 'shift'
            %
            %   Modifier Keys: Alt,Ctrl,Shift
            %   Modifiers effect character, but not the key
            
            
            %NOT YET SUPPORTED - {} for multi line entries ...
            
            %NOTES
            %==============================================================
            %1) Pressing a key does not update the string, the string only
            %updates on a multi-line box for alt-enter or gaining focus.
            %Documentation on this can be found under uicontrol->String ,
            %not under keyPressFcn
            %2) Detecting highlighting
            %no left click unless inactive:
            %http://www.mathworks.com/support/solutions/en/data/1-158CEG/index.html?product=SL&solution=1-158CEG
            %
            %http://www.mathworks.com/matlabcentral/answers/8921-pull-string-out-of-edit-text-without-user-hitting-enter
            
            
            %NOTE: The String property does not update as you type
            %in the edit box ...
            
            %keyboard
            
            %1) Decide if evaluation needed
            %2) Determine if deleting, if so restore
            %3) Log string in case of following delete
            
            %disp(char_info)
            
            obj = getappdata(gcbf,'obj');

            if strcmp(char_info.Key,'backspace')
               previous_string = obj.current_text_box_string;
               obj.getCurrentStringFromGUI;
               obj.handleDeletion(previous_string)
               return 
            end
            
            obj.getCurrentStringFromGUI;
            disp(obj.current_text_box_string)

            switch char_info.Character
                case char(13)
                    obj.evaluateCommand;
                case char(12)
                    %NOTE: key l, modifier - control
                    %ctrl+l
                    obj.resetPrompt;
                otherwise
                    %disp(double(char_info.Character))
                    %Do nothing
            end
            
        end
    end
    
end

