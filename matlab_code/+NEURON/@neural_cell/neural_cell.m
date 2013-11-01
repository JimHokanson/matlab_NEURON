classdef neural_cell < handle
    %neural_cell
    %
    %   Generic class for inheriting cells from ...
    %
    %   KNOWN CELL CLASSES
    %   =================================================
    %   NEURON.cell.axon.MRG
    
    properties
       path_obj   %Class: NEURON.paths
       cmd_obj    %Class: NEURON.cmd
    end
    
    properties (Abstract,Hidden,Constant)
       HOC_CODE_DIRECTORY %Location of the cell
    end
    
    properties (Dependent,Access = private)
       model_directory 
    end
        
    %MAIN CONSTRUCTOR METHOD   %===========================================
    methods (Static)
        function obj = create_cell(sim_obj,cell_type,cell_location)
           %
           %    NEURON.neural_cell.create_cell(sim_obj,cell_type,cell_location)
           %
           %    INPUTS
           %    ===========================================================
           %    sim_obj       : Class: NEURON.simulation or derived
           %    cell_type     : (string), valid types include:
           %        - 'MRG'
           %        - 'generic'
           %        - 'generic_unmyelinated'
           %    cell_location : [x,y,z], location of the cell.
           %        Interpretation of this value is up to the cell. Most
           %        often it is the center of the cell.
           
           switch lower(cell_type)
               case 'mrg'
                  obj = NEURON.cell.axon.MRG(cell_location);
               case 'generic'
                  obj = NEURON.cell.axon.generic(cell_location);
               case 'generic_unmyelinated'
                  obj = NEURON.cell.axon.generic_unmyelinated(cell_location);
               case 'drg_ad'
                  obj = NEURON.cell.DRG_AD(cell_location);
               otherwise
                  error('Unrecognized cell type: %s',cell_type)
           end
           
           obj.path_obj = sim_obj.path_obj;
           obj.cmd_obj  = sim_obj.cmd_obj;
        end
    end
    
    methods 
        function value = get.model_directory(obj)
           value = fullfile(obj.path_obj.hoc_code_model_root,obj.HOC_CODE_DIRECTORY);
        end
        
        function root_path = getModelRootDirectory(obj)
           root_path = obj.model_directory; 
        end
    end
    
    methods (Abstract)
       %created_status - indicates that the cell was defined (or redefined) in NEURON 
       created_status = createCellInNEURON(obj) %This method should define 
       %the cell in NEURON
       %created_status
       %    0 - not created
       %    1 - created, initialized all code
       %    2 - recreated cell
       %    3 - always created or recreated cell
    end
    
    methods
        function cdToModelDirectory(obj)
           %cdToModelDirectory
           %
           %    Changes current directory in NEURON to the model directory
           %
           %    NEURON.neural_cell.cdToModelDirectory
           
           obj.cmd_obj.cd_set(obj.model_directory);
        end 
    end
end

