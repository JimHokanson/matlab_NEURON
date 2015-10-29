classdef spatial_info < NEURON.sl.obj.handle_light
    %
    %   Class: NEURON.cell.axon.MRG.spatial_info
    %
    %
    %   Main Method:
    %   NEURON.cell.axon.MRG.spatial_info.populate_spatialInfo
    
    
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
    
    %DATA RETRIEVAL METHODS    %===========================================
    methods
        function xyz_all = get__xyz_all(obj)
            obj.populate_spatialInfo();
            xyz_all = obj.xyz_all; 
        end
        function avg_node_spacing = get__avg_node_spacing(obj)
           
           %NEURON.cell.axon.MRG.spatial_info.populate_spatialInfo
           obj.populate_spatialInfo();
           
           %populated by above method 
           avg_node_spacing = obj.avg_node_spacing; 
        end
        function xyz_nodes = get__XYZnodes(obj)
           xyz_all = obj.get__xyz_all(); %#ok<PROP>
           xyz_nodes = xyz_all(obj.section_ids == 1,:); %#ok<PROP>
        end
    end
    
    %======================================================================
    %IMPORTANT: The following properties were made private to respect 
    %the property: .spatial_info_up_to_date
    %

    properties (SetAccess = private)
        %.spatial_info()   %i.e. Constructor
        %.moveCenter
        xyz_center
    end
    
    methods 
        function value = get__xyz_center(obj)
            value = obj.xyz_center;
        end
    end
    
    %In general these properties are never accessed directly, unless 
    %in the method: .populate_spatialInfo()
    
    properties (Access = private)
        %.populate_spatialInfo()
        %------------------------------------------------------------------
        xyz_before_shift %Temporary variable, allows us to compute
        %xyz_all quicker when moving to a different center.
        
        %.populate_sectionIdInfo()
        %------------------------------------------------------------------
        section_ids  %numeric array, value indicates section type
        %ID of each created section in NEURON
        % 1 - node
        % These three together are an internode
        % 2 - MYSA
        % 3 - FLUT
        % 4 - STIN
        
        center_I     %index into section_ids, L_all, etc that is
        %the "center" of the axon, this currently indexes into
        %the center most node
        
        L_all        %length of each section ...
    end
    
    properties
        %This needs to be changed ...
        
        %Things that could change with respect to spatial information:
        %------------------------------------------------------------------
        %1) sections 
        %       - need new section lists
        %       - need to recompute xyz
        %       - need to recompute applied stimulus
        %2) # segments, lengths of any section, position of cell in 3d 
        %       - need to recompute xyz
        %       - need to recompute applied stimulus
        
        
        %METHODS
        %--------------------------------------------
        %.spatialPropsChanged() - set false
        %.moveCenter()
        
        spatial_info_up_to_date = false %When properties change, we need to
        %set this to be false. This indicates that the spatial properties
        %need to be recomputed. Any access to variables should first query
        %this before returning values.
        
        %.hasConfigurationChanged()
        spatial_configuration = 1;  %This property can be used by the code
        %that determines
    end
    
    properties
        props_obj %Class: NEURON.cell.axon.MRG.props
        %Reference to props object for retrieving information needed to 
        %handle spatial properties ...
    end
    
    %Constructor and Initialization
    %----------------------------------------------------------------------
    methods
        function obj = spatial_info(parent,xyz_center)
            obj.parent     = parent;
            obj.xyz_center = xyz_center;
        end
        function setPropsObj(obj,props_obj)
            obj.props_obj = props_obj;
        end
    end
    
    %Configuration/Dirty Status    %=======================================
    methods (Hidden)
        function [hasChanged,current_config] = hasConfigurationChanged(obj,previous_config)
           current_config = obj.spatial_configuration;
           if isempty(previous_config)
               hasChanged = true;
           else
               hasChanged = current_config ~= previous_config;
           end
        end
        function spatialPropsChanged(obj)
            %Method called by props_obj
            obj.spatial_info_up_to_date = false;
            
            %NOTE: For now we'll update this here.
            %The value doesn't hold much meaning, otehr than being
            %different
            obj.spatial_configuration = obj.spatial_configuration + 1;
        end
        function moveCenter(obj,newCenter)
            %moveCenter
            %
            %   moveCenter(obj,newCenter)
            %
            %   Normally one should access the moveCenter method in the
            %   parent.
            %
            
            obj.xyz_center = newCenter;
            if obj.spatial_info_up_to_date
                obj.xyz_all = bsxfun(@plus,obj.xyz_before_shift,newCenter);
                obj.spatial_configuration = ...
                    obj.spatial_configuration + 1;
            end
        end
    end
    
end

