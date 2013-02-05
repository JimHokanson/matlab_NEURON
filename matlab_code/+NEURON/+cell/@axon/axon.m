classdef axon < NEURON.neural_cell
    %
    %
    %
    %
    %
    
    properties (Abstract)
        threshold_info_obj
    end
    properties (Abstract,SetAccess = private)
        %threshold_info_obj
        xyz_all
    end
    
    methods
        function obj = axon()
			obj = obj@NEURON.neural_cell; 
        end
        
        function adjustPropagationIndex(obj,centerOffset)
            % axonObj.adjustPropagationIndex(centerOffset)
            % center offset is +/- distance off of center to set the
            % propagation index. This method will calculate the appropriate
            % index from this distance and set the propagation index
            % accordingly.
            
           Z = obj.xyz_all(:,3);
           centerZ = mean([Z(1),Z(end)]); % the center of the axon
           propagationZ = centerZ + centerOffset;
           [~,propagationIndex] = min(abs(Z-propagationZ));
           obj.threshold_info_obj.v_ap_propogation_index = propagationIndex;
        end

    end
 
end

