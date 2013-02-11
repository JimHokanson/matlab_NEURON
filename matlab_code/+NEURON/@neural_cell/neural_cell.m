classdef neural_cell < handle
    %neural_cell
    %
    %   Generic class for inheriting cells from ...
    %
    %   KNOWN CELLS:
    %   =================================================
    %   NEURON.cell.axon.MRG
    %   
    
    properties
       simulation_obj   %(class NEURON.simulation or subclass)
       cmd_obj          %(class NEURON.cmd)
    end
    
    properties (Abstract,Hidden,Constant)
       HOC_CODE_DIRECTORY %Location of the cell
    end
    
    properties (Dependent)
       model_directory 
    end
        
    methods 
        function value = get.model_directory(obj)
           value = fullfile(obj.simulation_obj.path_obj.hoc_code_model_root,obj.HOC_CODE_DIRECTORY);
        end
    end
    
    methods
        function root_path = getModelRootDirectory(obj)
           root_path = obj.model_directory; 
        end
        %I don't like this. Too much work to remember ...
        function setSimObjects(obj,cmd_obj,simulation_obj)
        %NOTE: This function should be called when the object is attached
        %to the simulation environment
        
           obj.simulation_obj = simulation_obj;
           obj.cmd_obj        = cmd_obj;
        end
    end
    
    methods (Abstract)
       %created_status - indicates that the cell was defined (or redefined) in NEURON 
       created_status = createCellInNEURON(obj)
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

