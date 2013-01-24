classdef generic < NEURON.cell.axon & NEURON.cell.extracellular_stim_capable
    %
    %
    %   Specification of a "Generic" Axon
    %   ===================================================================
    %   A generic axon will be modeled by nodes and myelin. Usually the
    %   nodes will have channel dynamics applied to them and the myelin
    %   will be passive. Support for non-passive myelin could be
    %   implemented at a later point. Sometimes in the specification of the
    %   nodes and myelin the morphological parameters may change. Default
    %   settings or hooks can be used to initialize the model to a certain
    %   papers specifications. These will go in a class that is currently
    %   roughly titled as:
    %       NEURON.cell.axon.generic.settings - this isn't the best name
    %       and could change
    %   The idea is that you might say.
    %       settings_obj.init_to_Brill_1977 or something like that
    %
    %
    %
    %   Should be like : NEURON.cell.axon.MRG
    %
    %   BASIC OUTLINE
    %   ==================================
    %   1) Initialize NEURON
    %   2) Create cell in NEURON - this code needs to run NEURON code which
    %       accomplishes that goal
    %   3) Create stimulus - code needs to know spatial information about
    %   the cell, this class will tell the extracellular_stimulation code
    %   the 3d info
    %   4) Extracellular Stim runs simulation
    %
    %   COMPILE MECHANISMS BEFORE RUNNING CODE
    %   ================================================
    %   C:\respositories\matlabToolboxes\NEURON\HOC_CODE\models\axon_models\mod_files
    %   NEURON.compile(path_above)
    %
    %   SUMMARY OF TODOS
    %   ======================================================
    %   1) Define hoc file for creating axon in NEURON, replace constants
    %   with variables that are populated via Matlab class
    %   2) Define Matlab class that will
    %       - create cell - i.e. run hoc code
    %       - know spatial info about the cell
    %   3) Implement this for fh model
    %   4) Recreate figure from Rattay
    %
    %   FH dynamics - use .mod file, which is the NMODL language
    %   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/nmodl/nmodl.html#NMODL
    
    properties (Hidden,Constant)
        HOC_CODE_DIRECTORY = 'axon_models';
    end
    
    properties (SetAccess = private)
        %xyz_center %Location of the axon center in global space (moved to
        %spatial_info
        props_obj %Class NEURON.cell.axon.generic.props
        threshold_info_obj %Class: NEURON.cell.threshold_info
        spatial_info_obj %Class: NEURON.cell.axon.generic.spatial_info
        
        xstim_event_manager_obj
        xyz_all   % populate_xyz()
    end
    
    properties (Hidden)
        
        ran_init_code_once = false
        
        cell_populated_in_NEURON % .createCellInNeuron, used by moveCenter
        props_populated = false; % props.populateDependentVariables
        %ev_man_obj;
        
        section_ids % ID of sections, see populate_section_id_info
        center_I % index into node that is center of axon
        L_all % populate_axon_length_info
        spatial_info_populated = false % .getNodeSpacing()
    end
    
    methods
        function value = get.xyz_all(obj)
            value = obj.spatial_info_obj.get__xyz_all;
        end
    end
    
    % INITIALIZATION
    methods
        function obj = generic(xyz_center,varargin) % constructor
            % input xyz center relative to electrodes
            
            obj = obj@NEURON.cell.axon;
            
            % may need to add method getThresholdInfo() (included in MRG
            % class)
            % Implement a way to change these values according to paper? or
            % props? atleast for v_rest?
            in.v_rest               = -80;
            in.v_rough_threshold    = -50;
            in.v_ap_threshold       = 0;
            in = processVarargin(in,varargin);
            obj.threshold_info_obj = NEURON.cell.threshold_info;
            obj.threshold_info_obj.v_rest = in.v_rest;
            obj.threshold_info_obj.v_rough_threshold = in.v_rough_threshold;
            obj.threshold_info_obj.v_ap_threshold = in.v_ap_threshold;
            

            obj.spatial_info_obj = NEURON.cell.axon.generic.spatial_info(obj,xyz_center);
            obj.props_obj = NEURON.cell.axon.generic.props(obj,obj.spatial_info_obj);
            obj.spatial_info_obj.setPropsObj(obj.props_obj);
        end  
    end
    
    
    % CHANGING METHODS
    methods
       function setEventManagerObject(obj,ev_man_obj)
           obj.xstim_event_manager_obj = ev_man_obj;
        end
        function moveCenter(obj, newCenter)
            
            obj.spatial_info_obj.moveCenter(newCenter);
            
%             obj.xyz_center = newCenter;
%             if isobject(obj.ev_man_obj)
%                cellLocationChanged(obj.ev_man_obj)
%             end
%             if obj.cell_populated_in_NEURON
%                 populate_xyz(obj)
%             end
        end   
    end
    
    % INFO FOR OTHERS
    methods
        %{
        function node_spacing = getNodeSpacing(obj)
           %What a mess ...
           if ~obj.spatial_info_populated
               %NEURON.cell.axon.generic.populateSpatialInfo
               populateSpatialInfo(obj)
           end
            
           I = find(obj.section_ids == 1);
           node_spacing = obj.xyz_all(I(2),3) - obj.xyz_all(I(1),3); %NOTE: Might want to do distance instead
           %also might want to do the average diff
        end
        %}
        
        %%%%%%%%%%%%%%%%%%%%%%%%%
        function xyz_nodes = getXYZnodes(obj)
           xyz_nodes = obj.spatial_info_obj.get__XYZnodes();
        end
        function avg_node_spacing = getAverageNodeSpacing(obj)
            %getAverageNodeSpacing
            %
            %   Written For ...
            
            avg_node_spacing = obj.spatial_info_obj.get__avg_node_spacing;

        end
        function threshold_info_obj = getThresholdInfo(obj)
           %TODO: Document
           %
           %    NOTE: I might want to change things ...
           
           threshold_info_obj = obj.threshold_info_obj;
        end
        function cell_log_data_obj = getXstimLogData(obj)
           %NEURON.cell.axon.generic.props.getPropertyValuePairing
           [pv,pv_version] = obj.props_obj.getPropertyValuePairing(true);
           cell_log_data_obj = NEURON.simulation.extracellular_stim.sim_logger.cell_log_data(...
               obj,[pv_version pv]);
        end
        
        
    end
    
    
end

