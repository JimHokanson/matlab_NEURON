function hideWindow(obj,old_process_array)
%hideWindow
%
%   hideWindow(obj,old_process_array)
%
%   PC only function for hiding the window that pops up when launching
%   NEURON.
%
%   FULL PATH:
%   NEURON.comm_obj.java_comm_obj.hideWindow

if ispc
    process_array = System.Diagnostics.Process.GetProcessesByName('nrniv');
    
    % % %                 %TODO: I need to fix this.
    % % %                 %The problem is knowing which windows process corresponds
    % % %                 %to the process that the java object is communicating with
    % % %                 if process_array.Length ~= 1
    % % %                    %NOTE: Eventually this might be more than 2 ...
    % % %                    error('Expecting singular process match')
    % % %                 end
    
    %NOTE: This could hide visible NEURON windows
    %but that should be fine
    
    %NOTE: I first ran into this problem when running
    %simulations in a loop, the first object was not being
    %cleared before the second one was being created, thus
    %causing two processes to be running "at the same time"
    
    %Whoops, apparently the time of deletion is unclear
    %at least based on a very little but of testing I did
    %Let's hide only the latest ...
    
    %matlab_process = System.Diagnostics.Process.GetProcessById(feature('GetPid'))
    
    
    %nrniv - if only one instance
    %for multiple instances 2nd index is nrniv#1, 3rd is nrniv#2
    %Not sure how slow this is but it is the way to do it
    %without using dll calls,
    
    
    %NEARLY FINAL CODE
    %NOTE: This doesn't handle multiple processes for a single
    %Matlab sessions, but then we would need a better sim hash
    %
    %NOTE: Unfortunately we also have to deal with multiple
    %processes for a single session that are in memory
    %due to the unclear nature of when a process is deleted
    %NOTE: This may really be an effect of not having a
    %blocking call to the destroy call on the process. In other
    %words Matlab asks for the process to be deleted, then
    %runs this code and sometime during this code execution the
    %proecess is actually destroyed
    %pc = System.Diagnostics.PerformanceCounter('Process','Creating Process Id','nrniv')
    %pc.RawValue == feature('GetPid')
    
    process_index_use = 1;
    
    %NOTE: This is a temporary fix and wouldn't work
    %with multiple environments
    if process_array.Length > 1
        old_ids = zeros(1,old_process_array.Length);
        new_ids = zeros(1,process_array.Length);
        
        for iOld = 1:length(old_ids)
            old_ids(iOld) = old_process_array(iOld).Id;
        end
        for iNew = 1:length(new_ids)
            new_ids(iNew) = process_array(iNew).Id;
        end
        process_index_use = find(~ismember(new_ids,old_ids));
        if length(process_index_use) ~= 1
            error('Unable to find singular match')
        end
    end
    
    p = process_array(process_index_use);
    hideWindow_dotnet(obj,p);
end
end