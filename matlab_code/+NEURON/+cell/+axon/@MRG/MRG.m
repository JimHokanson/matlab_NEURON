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
    
    
    %   PROPERTIES
    %   ===================================================================
    %   From NEURON.neural_cell
    %   -------------------------------------------------------------------
    %   simulation_obj %Class: NEURON.simulation or subclass
    %                       -  NEURON.simulation.extracellular_stim
    %   cmd_obj        %Class: NEURON.cmd
    
    properties (Hidden,Constant)
        HOC_CODE_DIRECTORY = 'MRG_Axon' %This gets used by a superclass
        %to cd to this directory, as well as to manage files written
        %back and forth between NEURON and Matlab
    end
    
    properties (SetAccess = private)
        %.moveCenter(), .MRG()
        xyz_center %User specified, location of the axon center in global space
        %This is important for stimulation with electrodes.
        %This is specified by the user in the constructor ...
        
        %.MRG()
        props_obj           %Class: NEURON.cell.axon.MRG.props
        threshold_info_obj  %Class: NEURON.cell.threshold_info
        spatial_info_obj    %Class: NEURON.cell.axon.MRG.spatial_info
    end
    
    properties (SetAccess = private)
       xstim_event_manager_obj 
       xyz_all 
    end
    
    methods
        function value = get.xyz_all(obj)
           value = obj.spatial_info_obj.get__xyz_all; 
        end
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
            
            %see method: getThresholdInfo()
            obj.threshold_info_obj = NEURON.cell.threshold_info;
            obj.threshold_info_obj.v_rest            = -80; %Can I get this from props?
            obj.threshold_info_obj.v_rough_threshold = -50;
            obj.threshold_info_obj.v_ap_threshold    = 0;
            
            
            obj.spatial_info_obj = NEURON.cell.axon.MRG.spatial_info(obj,xyz_center);
            obj.props_obj        = NEURON.cell.axon.MRG.props(obj,obj.spatial_info_obj);
            obj.spatial_info_obj.setPropsObj(obj.props_obj);
        end
    end
    
    %CHANGING METHODS =====================================================
    methods
        function setEventManagerObject(obj,ev_man_obj)
            %
            %   ev_man_obj : Class: NEURON.simulation.extracellular_stim.event_manager
            
            %TODO: Could add switch here if we have multiple types ...
            obj.xstim_event_manager_obj = ev_man_obj;
        end
        function moveCenter(obj, newCenter)
           obj.spatial_info_obj.moveCenter(newCenter);
        end
    end
    
    %INFO FOR OTHERS ======================================================
    methods
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
           %NEURON.cell.axon.MRG.props.getPropertyValuePairing
           [pv,pv_version] = obj.props_obj.getPropertyValuePairing(true);
           cell_log_data_obj = NEURON.simulation.extracellular_stim.sim_logger.cell_log_data(...
               obj,[pv_version pv]);
        end
    end
    
end

