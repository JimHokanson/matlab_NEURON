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
    %   PROPERTIES 
    %   ===================================================================
    %   From NEURON.neural_cell
    %   -------------------------------------------------------------------
    %   simulation_obj %Class: NEURON.simulation or subclass
    %                       -  NEURON.simulation.extracellular_stim
    %   cmd_obj        %Class: NEURON.cmd
    %
    %   From NEURON.cell.axon
    %   -------------------------------------------------------------------
    %   -none
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
    
    properties (Hidden,Constant)
        HOC_CODE_DIRECTORY = 'MRG_Axon' %This gets used by a superclass
        %to cd to this directory, as well as to manage files written
        %back and forth between NEURON and Matlab
    end
    
    properties (SetAccess = private)
        %.moveCenter()
        xyz_center %Location of the axon center in global space
        %This is important for stimulation with electrodes
        %This is specified by the user in the constructor ...
        
        %.MRG()
        props_obj   %Class: NEURON.cell.axon.MRG.props
        
        %.
        xyz_all     %populate_xyz()
    end
    
    %INTERNAL PROPS REGARDING SIZE
    properties (SetAccess = private)
        %See populateSpatialInfo for all props below
        %-------------------------------------------------------------
        %
        %see method .populate_section_id_info()
        %------------------------------------------------
        section_ids  %ID of each created section in NEURON
        %1 - node
        %These three together are an internode
        %2 - MYSA
        %3 - FLUT
        %4 - STIN
        
        %NEURON.cell.axon.MRG.populate_section_id_info
        center_I     %index into node that is the center of the axon

        %.populate_axon_length_info()
        L_all        %length of each section ...
        
        %.createCellInNEURON()
        cell_populated_in_NEURON %used by function moveCenter()
        %to update xyz if other related props are already calculated ...
        
        spatial_info_populated = false   %see .getNodeSpacing()
        props_populated        = false   %see .populateSpatialInfo()
        %also props.populateDependentVariables
        
        %.setEventManagerObject()
        ev_man_obj   %Class: NEURON.simulation.extracellular_stim.event_manager
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
            
            if nargin == 0
                return
            end
            
            obj.xyz_center  = xyz_center;
            obj.props_obj   = NEURON.cell.axon.MRG.props(obj);
        end
    end
    
    %CHANGING METHODS =====================================================
    methods
        function setEventManagerObject(obj,ev_man_obj)
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
            %   Written For:
            %      
            
            %What a mess ...
            if ~obj.spatial_info_populated
                %NEURON.cell.axon.MRG.populateSpatialInfo
                populateSpatialInfo(obj)
            end
            
            node_indices     = find(obj.section_ids == 1);
            avg_node_spacing = obj.xyz_all(I(2),3) - obj.xyz_all(I(1),3); %NOTE: Might want to do distance instead
            %also might want to do the average diff
        end
    end
    
end

