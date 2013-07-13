function edit

%NOTE: Could just do this one instead
%How does this change with Matlab versions?
%
%    identifier: 'MATLAB:dispatcher:pathWarning'
%          state: 'off'


   %guide tries to add my path, wtf ????
   w = warning('off','all');
   guide(NEURON.cmd_window_gui.cmd_window_class.getFigPath)
   warning(w)
   
end
