function [success,result_str] = waitForFinish(obj,max_wait)
%waitForFinish
%
%   [success,result_str] = waitForFinish(obj,max_wait)
%
%   NEURON.write sends a message to the NEURON process. When NEURON is
%   running it sends messages back, which are caught by an assigned listener.
%   The listener has a reference to this object. It updates a message
%   queue. When finished, the listener updates the running_cmd to let this
%   function know the results are ready.
%
%   INPUTS
%   ==============================================================
%   max_wait     : Max wait time in seconds. If a value of -1 is used, then       
%
%   See Also:
%       NEURON/write

%NOTE: At one point I had considered setting up a waitfor command and
%updating a hidden figure property specifying that the process should
%continue. In order to check on having exited I would need to implement the
%exited callback, which is available in the process. The one thing missing
%is setting up a wait timer. I am still considering displaying warnings
%every 30 seconds or so if the process hasn't finished.

ti = tic;
while obj.running_cmd
    pause(0.0001) %Some small wait so that the system doesn't lock up
    if obj.process_obj.HasExited
        %Generally (always?) indicates a stack up ...
        obj.running_cmd = false;
        formattedWarning('Process exited during code execution')
    end
    t = toc(ti);
    if t > max_wait && max_wait ~= -1
        error(['The max wait time of %d has been exceeded'...
            ' when executing the following command:\n%s\n'],max_wait,obj.last_cmd_str)
    end
end

result_str = obj.result_str;
success    = obj.success;


end