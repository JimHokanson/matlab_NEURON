classdef MRG < NEURON.cell.axon & NEURON.cell.extracellular_stim_capable
    %MRG
    %
    %   INHERITANCE NOTES
    %   ===================================================================
    %   axon < NEURON.neural_cell
    %
    %   NEURON.cell.extracellular_stim_capable ensures that the
    %   methods and properties needed for extracellular stim are in place
    %   ...
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
    
    
%     %TEMPORARY SPATIAL INFO ===============================================
%     properties (SetAccess = private)
%         %
%         %   TODO: Would be better to place in class ...
%         %   .spatial_obj   
%         
%         %MAIN METHOD:
%         %   NEURON.cell.axon.MRG.populateSpatialInfo
%         %------------------------------------------------------------------
%         %.populate_section_id_info()
%         section_ids  %ID of each created section in NEURON
%         %               1 - node
%         %               These three together are an internode
%         %               2 - MYSA
%         %               3 - FLUT
%         %               4 - STIN
%         
%         %.populate_section_id_info()
%         center_I     %index into section_ids, L_all, etc that is
%         %the "center" of the axon, this currently indexes into
%         %the center most node
%         
%         %.populate_axon_length_info()
%         L_all        %length of each section ...
%     end
    
%     properties (SetAccess = private)
%         %.populate_xyz()
%         xyz_all     %populate_xyz()
%         
%         avg_node_spacing
%         
%         %.createCellInNEURON()
%         cell_populated_in_NEURON %used by function moveCenter()
%         %to update xyz if other related props are already calculated ...
%         
%         spatial_info_populated = false   %see .getNodeSpacing()
%         
%         %.setEventManagerObject()
%         ev_man_obj   %Class: NEURON.simulation.extracellular_stim.event_manager
%         %IMPORTANT: On changing anything that changes the way the NEURON
%         %simulation would run, the event manager should be told of the
%         %change ...
%         %NOTE: Perhaps we just use a listener instead??????
%     end
    
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
            
            obj.props_obj        = NEURON.cell.axon.MRG.props(obj);
            obj.spatial_info_obj = NEURON.cell.axon.MRG.spatial_info(obj,xyz_center);
            obj.props_obj.populateSpatialInfoObj(obj.spatial_info_obj);
            obj.spatial_info_obj.setPropsObj(obj.props_obj);
        end
    end
    
    %CHANGING METHODS =====================================================
    methods
        function setEventManagerObject(obj,ev_man_obj)
            %
            %   ev_man_obj : Class: NEURON.simulation.extracellular_stim.event_manager
            obj.ev_man_obj = ev_man_obj;
        end
        function moveCenter(obj, newCenter)
            %moveCenter
            %
            %   This method can be used to move the location of the cell in
            %   the tissue.
            %
            %   moveCenter(obj, newCenter)
            
            obj.xyz_center = newCenter;
            %NOTE: This might need to change if we allow more types of
            %simulation than just extracellular stim ...
            if isobject(obj.ev_man_obj)
                cellLocationChanged(obj.ev_man_obj)
            end
            
            %NOTE: This check could be removed. It is really just trying to
            %save some time in that if the cell is not populated in NEURON,
            %the method createCellInNeuron will call this method anyways at
            %a later point (before the information is actually needed)
            if obj.cell_populated_in_NEURON
                %NEURON.cell.axon.MRG.populate_xyz
                populate_xyz(obj)
            end
        end
    end
    
    %INFO FOR OTHERS ======================================================
    methods
        function avg_node_spacing = getAverageNodeSpacing(obj)
            %getAverageNodeSpacing
            %
            %   Written For ...

            if ~obj.spatial_info_populated
                %NEURON.cell.axon.MRG.populateSpatialInfo
                populateSpatialInfo(obj)
            end
            
            avg_node_spacing = obj.avg_node_spacing;

        end
        function threshold_info_obj = getThresholdInfo(obj)
           %TODO: Document
           %
           %    NOTE: I might want to change things ...
           
           threshold_info_obj = obj.threshold_info_obj;
        end
    end
    
end

