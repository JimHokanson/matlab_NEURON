classdef event_manager < handle
    %event_manager
    %
    %   The goal of this class is to have a place that clearly lays out and keeps 
    %   track of the things needed to run an extracellular stimulation
    %   and the required order of all processes ...
    %
    %   Class: NEURON.simulation.extracellular_stim.event_manager
    
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
    

    
    properties
       parent %(Class NEURON.simulation.extracellular_stim)
    end
    
    properties
       cell_definition_set = false
       stim_info_set       = false
       ran_init_once       = true
    end
    
    properties (Hidden)
       cell_location_changed   = false
       stim_electrodes_changed = false
       tissue_changed          = false
    end
    
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
           %initSystem
           %
           %
           %    IMPORTANT METHODS
           %    ========================================
           %    init__verifyAssignedObjects
           %    createCellInNEURON
           %    init__create_stim_info
           %
           %    NEURON.simulation.extracellular_stim.event_manager
           
           %Class: NEURON.simulation.extracellular_stim;
           p       = obj.parent;
           
           %Class: NEURON.cmd;
           cmd_obj = p.cmd_obj;
           
           
           %PROPER INITIALIZATION CHECK
           %===============================================================
           %Verify that all objects are linked to the simulation ...
           if ~obj.ran_init_once
              init__verifyAssignedObjects(p)
              
              
              %IMPROVEMENT:
              %============================================================
              %NOTE: Do we want to change to the directory and do
              %initial setups here ...
              %i.e. 
              %1) cd to model directory
              %2) load driver
              %3) load function definitions
              
              obj.ran_init_once = true;
           end
           
           %CELL DEFINITION
           %===============================================================
           %Place code here that should be run if the cell changes
           %NOTE: The analysis of whether or not each function in this
           %section is needed given any given change of the cell isn't
           %critical. In other words, if we update the fiber diamter, we
           %don't need to create a new stim section list, since the # of
           %sections didn't change, but that optimization isn't critical
           %---------------------------------------------------------------
           if ~obj.cell_definition_set
              %Create cell in NEURON
              %
              %Example: NEURON.cell.axon.MRG.createCellInNEURON
              p.cell_obj.createCellInNEURON;
              
              %NOTE: Currently this needs to follow the previous
              %statement as the previous one cds into the proper directory
              %
              %NEURON.cell.extracellular_stim_capable.create_stim_sectionlist
              p.cell_obj.create_stim_sectionlist(cmd_obj);
              
              %RECORDING STUFF ....
              %------------------------------------------------------------
              p.cell_obj.create_node_sectionlist(cmd_obj);
              
              %Record membrane potential ...
              NEURON.lib.sim_logging.record_membrane_voltages(...
                    cmd_obj,'xstim__node_sectionlist','xstim__node_vm_hist')
              
              %TODO: Could prove an optional recording hook here
              %p.cell_obj.setup_optional_recording_info(cmd_obj);
              
              obj.cell_definition_set = true;
              
              %Make the assumption that the playback vector needs to be
              %recreated ...
              cmd_obj.run_command('xstim__cell_setup_changed_since_last_playback_initialization = 1');
           end
           
           %SETUP OF STIMULATION INFO
           %===============================================================
           if ~obj.stim_info_set
              %NEURON.simulation.extracellular_stim.init__create_stim_info
              init__create_stim_info(p)
              obj.stim_info_set = true;
           end

        end
    end
    
end

