classdef DRG_AD < NEURON.neural_cell & NEURON.cell.extracellular_stim_capable
    %
    %   axon < NEURON.neural_cell
    %
    %   NOTE: NEURON.cell.extracellular_stim_capable ensures that the
    %   methods and properties needed for extracellular stim are in place
    %   ...
    %  
    %
    %   IMPROVEMENTS
    %   ==============================================================
    %
    %   METHODS IN OTHER FILES 
    %   ============================================
    %   NEURON.cell.axon.MRG.createCellInNEURON   (main NEURON interface method)
    %   NEURON.cell.axon.MRG.populateSpatialInfo
    %   NEURON.cell.axon.MRG.getOtherScale
    %   NEURON.cell.axon.MRG.populate_xyz
    %
    %   OUTLINE:
    %   ============================================================
    %   1) createCellInNEURON is the primary NEURON access method
    
    properties (Hidden,Constant)
        HOC_CODE_DIRECTORY = 'Amir_Devor_2003'
    end
    
    properties (SetAccess = private)
        xyz_center %Location of the axon center in global space
        %This is important for stimulation with electrodes
        %This is specified by the user in the constructor ...
        %Use method .moveCenter() to move location
        
        props_obj   %(Class NEURON.cell.axon.MRG.props)
        xyz_all     %populate_xyz()
    end
    
    %INTERNAL PROPS REGARDING SIZE
    properties (Hidden) 
        %See populateSpatialInfo for all props below
        %-------------------------------------------------------------
        %
        %see method .populate_section_id_info()
        %------------------------------------------------
        section_ids  %ID of each created section in NEURON
            %1 - node
            %2 - MYSA
            %3 - FLUT
            %4 - STIN
        center_I     %index into node that is the center of the axon
                     %see method .populate_section_id_info()
                     
                     
        L_all        %populate_axon_length_info
        
        cell_populated_in_NEURON %used by function moveCenter
                                 %to update xyz if other related props are already
                                 %calculated ...
        
        spatial_info_populated = false   %see .getNodeSpacing()
        props_populated        = false    %see .populateSpatialInfo()
                                 %also props.populateDependentVariables
                                 
        ev_man_obj   %(Class NEURON.simulation.extracellular_stim.event_manager)
    end

    %INITIALIZATION ====================================================
    methods
        function obj = DRG_AD(xyz_center)
            %
            %   MRG_Axon(xyz_center)
            %
            %   INPUTS
            %   ========================================================
            %   xyz_center - center in xyz, relative to electrodes ...
            
            obj = obj@NEURON.neural_cell;
            
            if nargin == 0
                return
            end

            obj.xyz_center  = xyz_center;
            %obj.props_obj   = NEURON.cell.axon.MRG.props(obj);
        end
    end
    
    %CHANGING METHODS =====================================================
    methods
        function setEventManagerObject(obj,ev_man_obj)
           obj.ev_man_obj = ev_man_obj;
        end
        function moveCenter(obj, newCenter)
            obj.xyz_center = newCenter;
            if isobject(obj.ev_man_obj)
               cellLocationChanged(obj.ev_man_obj)
            end
            if obj.cell_populated_in_NEURON
                populate_xyz(obj)
            end
        end
    end

    %INFO FOR OTHERS   ====================================================
    methods
        function node_spacing = getNodeSpacing(obj)
           %What a mess ...
           if ~obj.spatial_info_populated
               populateSpatialInfo(obj)
           end
            
           I = find(obj.section_ids == 1);
           node_spacing = obj.xyz_all(I(2),3) - obj.xyz_all(I(1),3); %NOTE: Might want to do distance instead
           %also might want to do the average diff
        end
    end
    
end

