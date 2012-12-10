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
    
    
    properties
        xyz_center %Location of the axon center in global space
        props_obj %Class NEURON.cell.axon.generic.props
        xyz_all   % populate_xyz()
    end
    
    properties (Hidden)
        cell_populated_in_NEURON % .createCellInNeuron, used by moveCenter
        props_populated = false; % props.populateDependentVariables
        ev_man_obj;
        
        
        % the rest related to populateSpatialInfo and the functions it calls, taken
        % from MRG, may need fixin'
        section_ids % ID of sections, see populate_section_id_info
        center_I % index into node that is center of axon
        L_all % populate_axon_length_info
        spatial_info_populated = false % .getNodeSpacing()
    end
    
    % INITIALIZATION
    methods
        function obj = generic(xyz_center) % constructor
            % input xyz center relative to electrodes
            
            obj = obj@NEURON.cell.axon;
            
            if nargin == 0
                return
            end
            
            obj.xyz_center = xyz_center;
            obj.props_obj = NEURON.cell.axon.generic.props(obj);
        end  
    end
    
    
    % CHANGING METHODS
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
    
    % following is taken from MRG and need modification. MRG has different 
    % types of axon segments generic axons don't need.
    % INFO FOR OTHERS
    methods
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
    end
    
    
end

