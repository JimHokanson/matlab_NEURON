function cmd_window_gui(varargin)
%
%   Constructor call without object output.
%
%   This poor setup allows us to not throw the class out to the command
%   window.
%
%   See Also:
%       NEURON.cmd_window_gui.cmd_window_class


    NEURON.cmd_window_gui.cmd_window_class(varargin{:});

end