function setResultAndTerminateWait(obj,ev_data,is_success)
%setResultAndTerminateWait
%
%   This is the callback for the std_out and std_err cases.
%   We use an additional property passed into the function "is_success" to
%   differentiate.
%
%   setResultAndTerminateWait(obj,ev_data,is_success)
%
%   INPUTS
%   =======================================================================
%   obj        : Reference to class object 
%   ev_data    : (Format ???)
%       .data - character data passed back as C# String, needs conversion
%       .????
%   is_success : An additional input I placed in the callback function
%                signature to specify if this came from STDOUT or STDERR
%
%   See Also:
%       NEURON.comm_obj.windows_comm_obj.init_dotnet_code

try
    str = char(ev_data.Data);
    if obj.debug
        if is_success
            fprintf('String: %s\n',str);
        else
            fprintf(2,'String: %s\n',str);
        end
    end
catch ME %#ok<NASGU>
    formattedWarning('Error, in keyboard mode, click on link')
    keyboard
end

%Check for process having quit ----------------------------------
if obj.process_obj.HasExited
    %Why do some things cause the process to exit
    %Known example - putting a ~ for not instead of ! :)
    fprintf(2,sprintf('%s\n',obj.temp_stderr_str(1:obj.temp_stderr_index)));
    %obj.temp_stdout_str(1:obj.temp_stdout_index)
    error('Exited, see code');
end

isTermString      = helper__isTermString(str);
stackdump_present = helper__detectStackDump(obj,is_success,isTermString);

if stackdump_present
    obj.process_obj.Kill;  %Process is no longer valid
    %This will happen eventually in the .NET code, but this
    %just speeds up the process ...
    obj.running_cmd = false;
    error('Stackdump detected?, see code')
end

if isTermString
    obj.termination_str_observed = str;
    setFinalString(obj);
    obj.running_cmd = false;
    return
end

%Append to current list
%----------------------------------------------------------------
if is_success && obj.temp_stderr_index == 0
    %NOTE: temp_stderr_index > 0 happens with syntax errors
    %see n.write('a=1 b=2')
    temp_index = obj.temp_stdout_index;
    str = obj.cleanNeuronStr(str);
    obj.temp_stdout_str(temp_index+1:temp_index+length(str)) = str;
    obj.temp_stdout_index = obj.temp_stdout_index + length(str);
else
    temp_index = obj.temp_stderr_index;
    str = obj.cleanNeuronStr(str);
    obj.temp_stderr_str(temp_index+1:temp_index+length(str)) = str;
    obj.temp_stderr_index = temp_index + length(str);
end

end

function flag = helper__isTermString(str)
%isTermString Identifies the terminal string
%
%   flag = isTermString(str)
%
%   This code is a bit unclear.
%
%   See Also:
%       NEURON/write

flag = length(str) >= 4 && strcmp(str(end-3:end),'<oc>');
end




function stackdump_present = helper__detectStackDump(obj,is_success,isTermString)
%STACKDUMP HANDLING =======================================================
potential_stackdump =  is_success && obj.temp_stderr_index > 0 && ~isTermString;

%To recreate a stack dump do objref node[0]

%NOTE: This fails to capture syntax errors which have this same behavior ...
stackdump_present = false;
if potential_stackdump
    
    %TODO: I don't like that this method goes to the prop directly
    %I think this could lead to errors ...
    temp_str          = obj.temp_stderr_str(1:obj.temp_stderr_index);
    stackdump_present = ~isempty(strfind(temp_str,'Dumping stack trace to'));
    
    if stackdump_present
        %On stackdump we get an error followed by
        %one success of a seemingly
        %empty string
        %This is our attempt to capture that
        %In general we would not expect an error to be followed
        %by a non-error message
        setFinalString(obj)
        %Need to check for stackdump (eventually)
        fprintf(2,'STACKDUMP ERROR MESSAGE:\n%s\n',obj.result_str);
        
        %NOTE: Eventually it would be good to parse out the following
        %from the returned string to verify stackdump
        %
        %"Dumping stack trace to nrniv.exe.stackdump"
        %
        %The message above occurs near the end of the error string. It
        %might be followed by some whitespace characters ...
        
        %Might need to do more here ...
    end
    
end
end