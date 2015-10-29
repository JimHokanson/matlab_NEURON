classdef spatial_info < NEURON.sl.obj.handle_light
    %
    %   Class: NEURON.cell.axon.generic.spatial_info
    %
    %
    %   Main Method:
    %   NEURON.cell.axon.generic.spatial_info.populate_spatialInfo
    
    
    properties (Hidden)
        parent
        xstim_event_manager_obj
    end
    
    methods
        function value = get.xstim_event_manager_obj(obj)
            value = obj.parent.xstim_event_manager_obj;
        end
    end
    
    %PUBLIC PROPERTIES  ===================================================
    %and access methods
    %NOTE: These properties should all have access methods
    %which makes sure they are up to date before returning their values
    properties (Access = private)
        xyz_all
        avg_node_spacing
    end
    
    methods
        function xyz_all = get__xyz_all(obj)
            obj.populate_spatialInfo(); % NEURON.cell.axon.generic.spatial_info.populate_spatialInfo
            xyz_all = obj.xyz_all; 
        end
        function avg_node_spacing = get__avg_node_spacing(obj)
           obj.populate_spatialInfo();
            avg_node_spacing = obj.avg_node_spacing; 
        end
        function xyz_nodes = get__XYZnodes(obj)
           xyz_all = obj.get__xyz_all(); %#ok<PROP>
           xyz_nodes = xyz_all(obj.section_ids == 1,:); %#ok<PROP>
        end
    end
    
    %======================================================================
    
    %IMPORTANT: These were made private to respect the property:
    %spatial_info_up_to_date
    %
    %In general these are never accessed directly, unless in the method
    %populate_spatialInfo()
    properties (Access = private)
        %.spatial_info()   %Constructor
        %.moveCenter
        xyz_center
        
        xyz_before_shift %Temporary variable, allows us to compute
        %xyz quicker when moving
        
        %.populate_sectionIdInfo()
        %------------------------------------------------------------------
        section_ids  %numeric array, value indicates section type
        %ID of each created section in NEURON
        % 1 - node
        % 2 - myelin
        center_I     %index into section_ids, L_all, etc that is
        %the "center" of the axon, this currently indexes into
        %the center most node
        
        L_all        %length of each section ...
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
        props_obj %Class: NEURON.cell.axon.generic.props
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

