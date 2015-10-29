classdef event_manager < NEURON.sl.obj.handle_light
    %event_manager
    %
    %   The goal of this class is to have a place that clearly lays out and keeps 
    %   track of the things needed to run an extracellular stimulation
    %   and the required order of all processes ...
    %
    %
    %   NEW GOAL:
    %   -------------------------------------------------------------------
    %   I would like to get rid of this class ...
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
        %TODO: phasing this method out ...
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
           
           %PROPER INITIALIZATION CHECK
           %===============================================================
           %Verify that all objects are linked to the simulation ...
           if ~obj.ran_init_once
              init__verifyAssignedObjects(p)

              obj.ran_init_once = true;
           end
           
           p.cell_obj.createExtracellularStimCell();
           
           p.init__create_stim_info();
           
           
           
           %TODO: return value which specifies whether or not the cell
           %thinks the applied stimulus would change, based on cell
           %properties changing ...
           
                      
% % %            if ~cell_obj.props_up_to_date_in_NEURON || ...
% % %                    ~cell_obj.spatial_props_up_to_date
% % %                
% % % %               p.cell_obj.createCellInNEURON;
% % % %               p.cell_obj.create_stim_sectionlist(cmd_obj);
% % % %               p.cell_obj.create_node_sectionlist(cmd_obj);
% % % %               NEURON.lib.sim_logging.record_membrane_voltages(...
% % % %                     cmd_obj,'xstim__node_sectionlist','xstim__node_vm_hist')
% % % %               cmd_obj.run_command('xstim__cell_setup_changed_since_last_playback_initialization = 1');
% % %            end
           
% % % %            %SETUP OF STIMULATION INFO
% % % %            %===============================================================
% % % %            if ~obj.stim_info_set || cell_stim_info_changed
% % % %               %NEURON.simulation.extracellular_stim.init__create_stim_info
% % % %               init__create_stim_info(p)
% % % %               obj.stim_info_set = true;
% % % %            end

        end
    end
    
end

