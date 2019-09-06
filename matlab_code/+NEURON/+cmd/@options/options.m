classdef options
    %
    %   Class:
    %   NEURON.cmd.options
    
    %Startup Properties     %==============================================
    properties
       d0 = '-------- startup properties ------'
       show_banner = false
    end
    
    %Peristent Properties   %==============================================
    properties
        d1 = '------------ persistent properties ---------'
        debug = false   %If true, the command sent to NEURON will be
        %printed. The response will also be printed.
        
        interactive_mode = false %If true, this tries to setup the
        %NEURON writing process so that it is like typing into NEURON.
        %The results are printed directly to the command window instead of
        %being assigned to a temporary variable.
        %
        %In the cmd code I use this to not throw errors, but rather
        %to print the errors to the command window.
        
        log_commands = false
        
        max_wait = -1      %(units ), -1 indicates no timeout, 
        
        throw_error = true
    end

end

