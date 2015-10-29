classdef spatial_info < NEURON.sl.obj.handle_light
    
     %   Class: NEURON.cell.axon.generic_unmyelinated.spatial_info
     
     properties (Hidden)
         parent
         xstim_event_manager_obj
     end
     
     methods 
         function value = get.xstim_event_manager_obj(obj)
             value = obj.parent.xstim_event_manager_obj;
         end
     end
     
    properties (Access = private)
        xyz_all
        avg_node_spacing
    end
    
    methods
        function xyz_all = get__xyz_all(obj)
            obj.populate_spatialInfo(); % NEURON.cell.axon.generic_unmyelinated.spatial_info.populate_spatialInfo
            xyz_all = obj.xyz_all; 
        end
        
        function avg_node_spacing = get__avg_node_spacing(obj)
           obj.populate_spatialInfo();
            avg_node_spacing = obj.avg_node_spacing; 
        end

        
    end
    
    properties (Access = private)
        %.spatial_info()   %Constructor
        %.moveCenter
        xyz_center
        
        xyz_before_shift %Temporary variable, allows us to compute
        %xyz quicker when moving
        
        %.populate_sectionIdInfo()
        %------------------------------------------------------------------
        section_ids  %numeric array, value indicates section type
        % should be a list of 1s 
        center_I     %index into section_ids, L_all, etc that is
        %the "center" of the axon, this currently indexes into
        %the center most node
        
        L_all        %length of each section
    end
    
    properties
        %Dirty bits
        %-------------------------------------------------------------------
        %.spatialPropsChanged() - set false
        spatial_info_up_to_date = false %When properties change, we need to
        %set this to be false. This indicates that the spatial properties
        %need to be recomputed. Any access to variables should first query
        %this before returning values.
    end
    
    properties
        props_obj %Class: NEURON.cell.axon.generic_unmyelinated.props
    end
    
    methods
        function obj = spatial_info(parent,xyz_center)
            obj.parent     = parent;
            obj.xyz_center = xyz_center;
        end
        function setPropsObj(obj,props_obj)
            obj.props_obj = props_obj;
        end
        function spatialPropsChanged(obj)
            %Method called by props_obj
            obj.spatial_info_up_to_date = false;
        end
        function moveCenter(obj,newCenter)
            
            obj.xyz_center = newCenter;
            
            if isobject(obj.xstim_event_manager_obj)
                obj.xstim_event_manager_obj.cellLocationChanged();
            end
            
            if obj.spatial_info_up_to_date
                obj.xyz_all = obj.xyz_before_shift + newCenter;
            end
        end
    end
    
end