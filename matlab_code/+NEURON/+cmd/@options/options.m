classdef options
    %
    %   Class:
    %       NEURON.cmd.options
    
    %Startup Properties     %==============================================
    properties
       
    end
    
    %Peristent Properties   %==============================================
    properties
        debug       = false   %If true, the command sent to NEURON will be
        %printed. The response will also be printed.
        
        interactive_mode = false %If true, this tries to setup the
        %NEURON writing process so that it is like typing into NEURON.
        %The results are printed directly to the command window instead of
        %being assigned to a temporary variable.
        
        log_commands     = false
        
        max_wait    = -1      %(units ), -1 indicates no timeout, 
        
        throw_error = true
    end

end

