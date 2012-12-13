function showWindow(hwnd,option)
            
            %
            %http://msdn.microsoft.com/en-us/library/windows/desktop/ms633548(v=vs.85).aspx
            
            %0 - hide
            %1 - show normal - activates and displays the window, for first time call
            %JAH TODO: add more
            %3 - maxmize
            %6 - minmize
            %
            
%SW_FORCEMINIMIZE
% 11
% Minimizes a window, even if the thread that owns the window is not responding. This flag should only be used when minimizing windows from a different thread.

% SW_HIDE
% 0
% Hides the window and activates another window.

% SW_MAXIMIZE
% 3
% Maximizes the specified window.

% SW_MINIMIZE
% 6
% Minimizes the specified window and activates the next top-level window in the Z order.

% SW_RESTORE
% 9
% Activates and displays the window. If the window is minimized or maximized, the system restores it to its original size and position. An application should specify this flag when restoring a minimized window.

% SW_SHOW
% 5
% Activates the window and displays it in its current size and position.

% SW_SHOWDEFAULT
% 10
% Sets the show state based on the SW_ value specified in the STARTUPINFO structure passed to the CreateProcess function by the program that started the application.

% SW_SHOWMAXIMIZED
% 3
% Activates the window and displays it as a maximized window.

% SW_SHOWMINIMIZED
% 2
% Activates the window and displays it as a minimized window.

% SW_SHOWMINNOACTIVE
% 7
% Displays the window as a minimized window. This value is similar to SW_SHOWMINIMIZED, except the window is not activated.

% SW_SHOWNA
% 8
% Displays the window in its current size and position. This value is similar to SW_SHOW, except that the window is not activated.

% SW_SHOWNOACTIVATE
% 4
% Displays a window in its most recent size and position. This value is similar to SW_SHOWNORMAL, except that the window is not activated.

% SW_SHOWNORMAL
% 1
% Activates and displays a window. If the window is minimized or maximized, the system restores it to its original size and position. An application should specify this flag when displaying the window for the first time.
%             
            option = int32(option);
            
            calllib('user32','ShowWindow',hwnd,option);
        end