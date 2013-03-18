function init_dotnet_code(obj)
%init_dotnet_code Initializes ipc btwn Neuron and Matlab
%
%   init_dotnet_code(obj)
%
%   This launches the NEURON process and sets it up so that stdout and
%   stderr are directed to Matlab.
%
%   FULL PATH:
%   NEURON.comm_obj.windows_comm_obj.init_dotnet_code

%IMPORTANT:
%https://www.neuron.yale.edu/phpBB/viewtopic.php?f=8&t=2185

%.NET documentation (starting point)
%googled System Process .NET
%http://msdn.microsoft.com/en-us/library/system.diagnostics.process.aspx

%=============================================
%PROCESS HANDLE
try
    p = System.Diagnostics.Process;
catch ME
    error('Creation of .NET systems diagnostic failed, make sure to initialize the .NET assembly, see NEURON.initDotNet')
end

%Initialize System.Diagnostics.Process.StartInfo
%------------------------------------------------------
initStartupInfo(obj,p)

%Run the processs
%-------------------------------------------------------
p.Start();

%NEURON.comm_obj.hideWindow_dotnet
hideWindow_dotnet(obj,p)

%Begin Asynchronous Processing
%--------------------------------------------------------------------------
%NOTE: The process must be asynchronous otherwise the code will not run
%until the process is completed and terminated. Since we want to go back
%and forth with the process, the communication must be asynchronous.
beginAsyncOps(p)

%Assigment of local properties
%--------------------------------------------------------------------------
obj.process_obj = p;
obj.std_in_obj  = p.StandardInput;

end


function beginAsyncOps(p)
%Allows asynchronous processing of output and error streams
%(I think), otherwise the program may wait until it terminates
%before it ends. We want a back and forth process between
%Matlab and Neuron, so we wants this asynchronous back
%and forth to occur
p.BeginOutputReadLine; %NOTE: This only returns an event after a line has been written
p.BeginErrorReadLine;

end

function initStartupInfo(obj,p)
%
%   initStartupInfo(obj,p)
%
%   
%

%DOCUMENTATION
%-----------------------------------------------
%http://msdn.microsoft.com/en-us/library/system.diagnostics.processstartinfo.aspx
%-----------------------------------------------

p.StartInfo.FileName  = obj.paths.exe_path;

obj.lh_out = addlistener(p,'OutputDataReceived',@(~,ev_data) setResultAndTerminateWait(obj,ev_data,true));
obj.lh_err = addlistener(p,'ErrorDataReceived',@(~,ev_data) setResultAndTerminateWait(obj,ev_data,false));

%NOTE: We could add a listener to the process exiting. This is not
%currently handled
%obj.lh_exited = addlistener(p,'Exited',@(~,ev_data) setResultAndTerminateWait(obj,ev_data,false));
% ^^^ if we ever do want to use this function we probably want to rename 
% the variable: obj.lh_ext perhaps? 
% this was probably buggy before because we renamed something already in
% existance

%addlistener(c, 'Exited', @NEURON.process_exitFunc); %added
%Called on exiting the program

%Arguments are specific to Neuron
%see https://www.neuron.yale.edu/phpBB/viewtopip.php?f=8&t=862
p.StartInfo.Arguments       = '-nobanner -nogui -isatty';
%p.StartInfo.Arguments      = '-nobanner -nogui -notatty';

%Must be set false in order to redirect iostreams
p.StartInfo.UseShellExecute = false;

%If these streams are not redirected, Matlab will not be able to see them
p.StartInfo.RedirectStandardInput  = true;
p.StartInfo.RedirectStandardError  = true;
p.StartInfo.RedirectStandardOutput = true;

%We don't want to see the system command window
%For some reason I couldn't do this in .NET, I thought the following
%would help. NOTE: These might be necessary, but these are not sufficient.
p.StartInfo.CreateNoWindow  = true;

%NOTE: This requires UseShellExecute to be set to false as well
p.StartInfo.WindowStyle     = System.Diagnostics.ProcessWindowStyle.Hidden;
end