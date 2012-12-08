classdef event_manager < handle
    %
    %
    %   Goal is to have a place that clearly lays out and keeps 
    %   track of the things needed to run an extracellular stimulation
    %   and the required order of all processes ...
    %
    %
    %   Class: NEURON.simulation.extracellular_stim.event_manager
    %
    
    %STEPS
    %================================================================
    %1) Initialization setup
    %2) Definition of objects (electrodes, tissue, cell)
    %3) Cell Definition
    %   - cell creation
    %4) Stim specification
    %   - send vectors to NEURON 
    %          m: init_create_stim_info
    %   - load data into NEURON 
    %          n: xstim__load_data()
    %   - setup playing of stimulus into sections 
    %          n: xstim__setup_stim_playback
    
    %create_mrg_axon
    %xstim__apply_stimulus
    
    %NOT YET IMPLEMENTED ...
    
    properties
       parent %(Class NEURON.simulation.extracellular_stim)
       cell_definition_set = false
       stim_info_set       = false
       ran_init_once       = true
    end
    
    properties (Hidden)
       cell_location_changed   = false
       stim_electrodes_changed = false
       tissue_changed          = false
    end
    
% % %     properties (Dependent)
% % %        
% % %     end
% % %     
% % %     methods 
% % %         function value = get.stim_info_changed(obj)
% % %            value = obj.stim_electrodes_changed || obj.tissue_changed || obj.cell_location_changed || cell_definition_changed;
% % %         end
% % %     end
    
    methods
        function cellLocationChanged(obj)
           obj.stim_info_set = false; 
        end
        function stimElectrodesChanged(obj)
           obj.stim_info_set = false; 
        end
        function tissueChanged(obj)
           obj.stim_info_set = false; 
        end
        function obj = event_manager(parent_obj)
           obj.parent = parent_obj; 
        end
    end
    
    methods
        function initSystem(obj)
           %
           %
           %
           %    IMPORTANT METHODS
           %    ========================================
           %    init__verifyAssignedObjects
           %    createCellInNEURON
           %    init__create_stim_info
            
            
           NODE_MEMBRANE_VOLTAGE_RECORD_LIST = 'xstim__node_vm_hist';
           NODE_SECTION_LIST                 = 'node_list'; 
           
           p = obj.parent;
           
           if ~obj.ran_init_once
              init__verifyAssignedObjects(p)
              obj.ran_init_once = true;
           end
           
           if ~obj.cell_definition_set
              p.cell_obj.createCellInNEURON;
              NEURON.lib.sim_logging.record_node_voltages(p.cmd_obj,NODE_SECTION_LIST,NODE_MEMBRANE_VOLTAGE_RECORD_LIST)
              obj.cell_definition_set = true;
           end
           
           if ~obj.stim_info_set
              init__create_stim_info(p)
              obj.stim_info_set = true;
           end

        end
    end
    
end

