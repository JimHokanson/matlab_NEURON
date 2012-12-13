classdef user32 < handle
    %win32
    %
    %JAH TODO: document class
    
    properties
        
    end
    
    methods (Access = private)
        function obj = user32
            
        end
    end
    
    methods (Static)
        function init(forceReload)
            if ~exist('forceReload','var')
                forceReload = false;
            end 
            
            if libisloaded('user32')
                if forceReload
                    unloadlibrary('user32')
                    loadlibrary('user32.dll','user32.h')
                end
            else
                loadlibrary('user32.dll','user32.h')
            end
        end
        
        function processID = getProcessID(hwnd)
            %win32_getProcessID
            %
            %   NOTE: I think this function may be useless
            processID = calllib('user32','GetWindowThreadProcessId',hwnd);
            
        end
        
        function hwnd = getWindowHandleByName(name_str)
            %getWindowHandleByName
            %
            %NOTE: There are actually three usages here
            %I have only implemented 1, maybe 2
            %
            %   JAH TODO: Finish documentation
            
            %The 0 indicates null, meaning not to filter by class
            hwnd = calllib('user32','FindWindowA',0,name_str);
        end
        
        function flag = giveWindowFocus(hwnd)
            %Useful for typing into a window
            flag = calllib('user32','SetForegroundWindow',hwnd);
            
        end
        
        showWindow(hwnd,option)
        
    end
    
    methods
        %Needs to be made static ...
        function methods
            %JAH TODO: Finish function
        end
    end
end

