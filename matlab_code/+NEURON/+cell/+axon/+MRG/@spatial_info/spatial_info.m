classdef spatial_info < handle_light
    %
    %   Class: NEURON.cell.axon.MRG.spatial_info
    %
    %
    %   Main Method:
    %   NEURON.cell.axon.MRG.spatial_info.populate_spatialInfo
    
    
    properties (SetAccess = private)
       xyz_all
    end
    
    methods 
        function value = get.xyz_all(obj)
           obj.populate_spatialInfo;
           value = obj.xyz_all;
        end
    end
    
    properties (SetAccess = private)
       %.spatial_info()   %Constructor
       %.moveCenter
       xyz_center
       
       avg_node_spacing

       section_ids
       
       center_I
       
       L_all
    end
    
    properties
       %Dirty bits
       %-------------------------------------------------------------------
       %.spatialPropsChanged() - set false
       spatial_info_up_to_date = false %When properties change, we need to
       %set this to be false 
    end
    
    properties
       props_obj %Class: NEURON.cell.axon.MRG.props
    end
    
    methods
        function obj = spatial_info(obj,xyz_center)
           obj.xyz_center = xyz_center; 
        end
        function setPropsObj(obj,props_obj)
           obj.props_obj = props_obj; 
        end
        function spatialPropsChanged(obj)
           %Method called by props_obj
           obj.cell_populated_in_Matlab = false;
        end
    end
    
end

