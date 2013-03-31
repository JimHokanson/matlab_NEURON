classdef axon < NEURON.neural_cell
    %
    %   Class:
    %       NEURON.cell.axon
    %
    %
    %
    
%These get into NEURON.cell.extracellular_stim_capable ...
%Discuss with Matt how to address
%     properties (Abstract)
%         threshold_info_obj
%     end
%     properties (Abstract,SetAccess = private)
%         %threshold_info_obj
%         xyz_all
%     end
    
    methods
        function obj = axon()
			obj = obj@NEURON.neural_cell; 
        end
        
        function adjustPropagationIndex(obj,center_offset)
            %adjustPropagationIndex
            %
            %   adjustPropagationIndex(obj,centerOffset)
            %
            %   INPUTS
            %   ===========================================================
            % center_offset (um): +/- distance off of center to set the
            % propagation index. This method will calculate the appropriate
            % index from this distance and set the propagation index
            % accordingly.
            
           Z = obj.xyz_all(:,3);
           
           centerZ      = mean([Z(1),Z(end)]); % the center of the axon
           propagationZ = centerZ + center_offset;
           
           [~,propagationIndex] = min(abs(Z-propagationZ));
           
           
           obj.threshold_info_obj.v_ap_propagation_index = propagationIndex;
        end

    end
 
end

