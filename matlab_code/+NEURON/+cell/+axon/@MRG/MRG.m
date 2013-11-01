classdef MRG < NEURON.cell.axon & NEURON.cell.extracellular_stim_capable
    %MRG
    %
    %   INHERITANCE NOTES
    %   ===================================================================
    %   axon < NEURON.neural_cell
    %
    %   NEURON.cell.extracellular_stim_capable
    %   Ensures that the methods and properties needed for extracellular
    %   stimulation are in place ...
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %
    %   METHODS IN OTHER FILES
    %   ===================================================================
    %   NEURON.cell.axon.MRG.createCellInNEURON   (main NEURON interface method)
    %   NEURON.cell.axon.MRG.populateSpatialInfo
    %   NEURON.cell.axon.MRG.getOtherScale
    %   NEURON.cell.axon.MRG.populate_xyz
    %
    %   NOTES:
    %   ===================================================================
    %   1) createCellInNEURON is the primary NEURON access method
    %
    %   MODEL CITATION
    %   ===================================================================
    %   McIntyre CC, Richardson AG, Grill WM (2002) Modeling the
    %   excitability of mammalian nerve fibers: influence of
    %   afterpotentials on the recovery cycle. Journal of neurophysiology
    %   87:995–1006.
    %
    %   See Also:
    %   ===================================================================
    %   NEURON.cell.axon.MRG.props
    
    %directory
    properties (Hidden,Constant)
        HOC_CODE_DIRECTORY = 'MRG_Axon' %This gets used by a superclass
        %to cd to this directory, as well as to manage files written
        %back and forth between NEURON and Matlab
    end

    properties
        %%(SetAccess = private)
        %For right now we'll go with just don't do anything stupid ...
        %Not sure of reason for difference in value vs handle behavior
        %http://www.mathworks.com/help/matlab/matlab_oop/properties-containing-objects.html
        
        %.MRG()
        props_obj           %Class: NEURON.cell.axon.MRG.props
        threshold_info_obj  %Class: NEURON.cell.threshold_info
        spatial_info_obj    %Class: NEURON.cell.axon.MRG.spatial_info
    end
    
    properties (SetAccess = private)
        xyz_all
        xyz_center
    end
    
    methods
        function value = get.xyz_all(obj)
            value = obj.spatial_info_obj.get__xyz_all;
        end
        function value = get.xyz_center(obj)
            value = obj.spatial_info_obj.xyz_center;
        end
    end
    
    properties (SetAccess = private,Hidden)
        %NEURON.cell.axon.MRG.createCellInNEURON
        cell_initialized_in_neuron_at_least_once = false; %This currently
        %is used to limit the amount of code we run when we need to recreate
        %the cell in NEURON.
        
        %Other sub properties:
        %    props_obj.props_up_to_date_in_NEURON
        %    spatial_info_obj.spatial_props_up_to_date
    end
    
    
    
    %INITIALIZATION ====================================================
    methods
        function obj = MRG(xyz_center)
            %
            %   MRG_Axon(xyz_center)
            %
            %   INPUTS
            %   ========================================================
            %   xyz_center - center in xyz, relative to electrodes ...
            
            obj = obj@NEURON.cell.axon;
            
            %see method:
            %   NEURON.cell.axon.MRG.getThresholdInfo()
            obj.threshold_info_obj = NEURON.cell.threshold_info;
            obj.spatial_info_obj   = NEURON.cell.axon.MRG.spatial_info(obj,xyz_center);
            obj.props_obj          = NEURON.cell.axon.MRG.props(obj,obj.spatial_info_obj);
            obj.spatial_info_obj.setPropsObj(obj.props_obj);
        end
    end
    
    %CHANGING METHODS =====================================================
    methods
        function moveCenter(obj, newCenter)
            % moveCenter
            %
            %    moveCenter(obj, newCenter)
            
            obj.spatial_info_obj.moveCenter(newCenter);
        end
    end
    
    %INFO FOR OTHERS     %=================================================
    %Some are required methods and others have defaults implemented by:
    %   NEURON.cell.extracellular_stim_capable
    methods
        function [hasChanged,new_config] = hasSpatialInformationChanged(obj,previous_config)
            %
            %
            %   [hasChanged,new_config] = hasSpatialInformationChanged(obj,previous_config)
            %
            %   See Also:
            %       NEURON.cell.axon.MRG.spatial_info.hasSpatialInformationChanged
            
            [hasChanged,new_config] = obj.spatial_info_obj.hasConfigurationChanged(previous_config);
        end
        function xyz_nodes = getXYZnodes(obj)
            %getXYZnodes
            %
            %    xyz_nodes = getXYZnodes(obj)
            %
            %    See Also:
            %        NEURON.cell.axon.MRG.spatial_info.get__XYZnodes
            
            xyz_nodes = obj.spatial_info_obj.get__XYZnodes();
        end
        function avg_node_spacing = getAverageNodeSpacing(obj)
            %getAverageNodeSpacing
            %
            %   avg_node_spacing = getAverageNodeSpacing(obj)
            %
            %   See Also:
            %       NEURON.cell.axon.MRG.spatial_info.get__avg_node_spacing
            
            avg_node_spacing = obj.spatial_info_obj.get__avg_node_spacing;
            
        end
        function threshold_info_obj = getThresholdInfo(obj)
            %threshold_info_obj
            %
            %    threshold_info_obj = getThresholdInfo(obj)
            
            threshold_info_obj = obj.threshold_info_obj;
        end
        
        %NOTE: The design of this is going to change ...
        function cell_log_data_obj = getXstimLogData(obj)
            %NEURON.cell.axon.MRG.props.getPropertyValuePairing
            [pv,pv_version] = obj.props_obj.getPropertyValuePairing(true);
            cell_log_data_obj = NEURON.simulation.extracellular_stim.sim_logger.cell_log_data(...
                obj,[pv_version pv]);
        end
    end
    
    %Logging functionality  %==============================================
    methods
        function logger = getLogger(obj)
            logger = NEURON.cell.axon.MRG.logger.getInstance(obj.props_obj,obj);
        end
    end
    
end

