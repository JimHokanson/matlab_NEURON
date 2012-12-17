classdef comm_obj < handle_light
    %
    %   Abstract class for NEURON communication ...
    %
    %   IMPLEMENTATIONS
    %   ===================================================================
    %   NEURON.comm_obj.windows_comm_obj - windows
    %   NEURON.comm_obj.java_comm_obj    - java implementation
    %
    %   Improvements:
    %   ================================================================
    %   1) Allow binary data transfer to go through these objects as well.
    %   Currently binary data transfer is handled through files. I think
    %   this is more efficient and accurate than numeric scanning (something 
    %   like fscanf), but ideally this could be done through memory
    
    methods (Abstract,Static)
        init_system_setup %Should be called once in codebase to initialize system
                          %Depending upon the system this method may not
                          %need to do anything
    end
    
    methods (Abstract)
        %NOTE: The delete method may not be abstract
        %delete(obj)       %Called upon closing of NEURON. Again, depending upon 
                          %the system this function may not need to do anything
        [success,results] = write(obj,command_str,option_structure)
    end

    %MESSAGE PARSING
    %======================================================================
    methods (Static, Access = protected)
        function str_out = cleanNeuronStr(str_in)
            %cleanNeuronStr
            %
            %   str_out = cleanNeuronStr(str_in)
            %
            %   This method removes leading oc> prompts that get shown at
            %   the beginning of the returned messages ...
            %
            %   IMPORTANT:
            %   ===========================================================
            %   An assumption is made about the removal of newlines due to
            %   the passing of data back and forth. If a newline is not
            %   always removed we will need to request that instruction
            %   from the calling function. For windows only we are fine. It
            %   is not clear for Windows and Macs.
            
            %Look for oc> at the beginning of the string
            I = regexp(str_in,'^(oc>)*','end');

            if ~isempty(I)
                str_out = str_in(I+1:end);
            else
                str_out = str_in;
            end

            %NOTE: I add back in a newline character since the .NET code
            %removes the newline when receiving the message. Depending upon
            %other implementations I might need to pass in an additional
            %argument
            str_out = [str_out char(10)];
        end
    end
    
end

