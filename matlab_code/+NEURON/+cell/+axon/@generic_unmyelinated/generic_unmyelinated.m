classdef generic_unmyelinated < NEURON.cell.axon & NEURON.cell.extracellular_stim_capable
    %
    % Generic unmyelinated axon
    
    % TODO:
    % This is considered an abstract class because getXYZnodes and
    % getAverageNodeSpacing are missing. These aren't relevant to
    % unmyelinated axons, but they can be defined regardless.
    
    properties (Hidden,Constant)
        HOC_CODE_DIRECTORY = 'axon_models';
    end
    
    properties (SetAccess = private)
        props_obj %Class NEURON.cell.axon.generic_unmyelinated.props
        %threshold_info_obj %Class: NEURON.cell.threshold_info
        spatial_info_obj %Class: NEURON.cell.axon.generic_unmyelinated.spatial_info
        
        xstim_event_manager_obj
        xyz_all   % populate_xyz()
        
    end
    
    properties (Hidden)
        ran_init_code_once = false
        
        cell_populated_in_NEURON % .createCellInNeuron
        props_populated = false; % props.populateDependentVariables
        
        section_ids % ID of sections, see populate_section_id_info
        center_I % index into node that is center of axon
        L_all % populate_axon_length_info
        spatial_info_populated = false
    end
    
    
    properties
       threshold_info_obj %Class: NEURON.cell.threshold_info
    end
    
    methods
        function value = get.xyz_all(obj)
            value = obj.spatial_info_obj.get__xyz_all;
        end
    end
    
    % INITIALIZATION
    methods
        function obj = generic_unmyelinated(xyz_center,varargin) % constructor
            % input xyz center relative to electrodes
            
            obj = obj@NEURON.cell.axon;
            
            in.v_ap_threshold       = 0;
            in = NEURON.sl.in.processVarargin(in,varargin);
            obj.threshold_info_obj = NEURON.cell.threshold_info;
            obj.threshold_info_obj.v_ap_threshold = in.v_ap_threshold;
            
            
            obj.spatial_info_obj = NEURON.cell.axon.generic_unmyelinated.spatial_info(obj,xyz_center);
            obj.props_obj = NEURON.cell.axon.generic_unmyelinated.props(obj,obj.spatial_info_obj);
            obj.spatial_info_obj.setPropsObj(obj.props_obj);
            
            %Overriding Superclass (extracellular_stim_capable) defaults
            %------------------------------------------------------------
            obj.opt__first_section_access_string     = 'access axon';
            obj.opt__use_local_node_sectionlist_code = true;
            
        end
    end
    
    % CHANGING METHODS
    methods
        function setEventManagerObject(obj,ev_man_obj)
            obj.xstim_event_manager_obj = ev_man_obj;
        end
        function moveCenter(obj, newCenter)
            obj.spatial_info_obj.moveCenter(newCenter);
        end
    end
    
    % INFO FOR OTHERS
    methods
        % nodes aren't really relevant to a myelinated cell, but these
        % methods are required by base class
        function xyz_nodes = getXYZnodes(obj)
            xyz_nodes = obj.xyz_all;
        end
        function avg_node_spacing = getAverageNodeSpacing(obj)
            avg_node_spacing = obj.spatial_info_obj.get__avg_node_spacing;
        end
        
        function threshold_info_obj = getThresholdInfo(obj)
            threshold_info_obj = obj.threshold_info_obj;
        end
        function cell_log_data_obj = getXstimLogData(obj)
            %NEURON.cell.axon.generic_unmyelinated.props.getPropertyValuePairing
            [pv,pv_version] = obj.props_obj.getPropertyValuePairing(true);
            cell_log_data_obj = NEURON.simulation.extracellular_stim.sim_logger.cell_log_data(...
                obj,[pv_version pv]);
        end
        
    end
    
end