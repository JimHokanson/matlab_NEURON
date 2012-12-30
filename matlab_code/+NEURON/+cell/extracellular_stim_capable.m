classdef extracellular_stim_capable < handle
    %
    %   Put in cells to enforce support for extracellular_stim simulations
    %
    %
    %   REQUIRED LOCAL NEURON METHODS
    %   ===================================================================
    %
    %
    %   OPTIONAL NEURON METHODS
    %   ===================================================================
    %   create_stim_sectionlist.hoc
    %
    %
    %   IMPROVEMENTS:
    %   ===================================================================
    %   1) Write method that verifies that all of the NEURON related code
    %   is setup
    %   2)
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim
    %
    %   Class: NEURON.cell.extracellular_stim_capable
    
    properties (Abstract,SetAccess = private)
        xyz_all %NOTE: This is a [n x 3] vector which should match the 
        %spatial layout of the section list defined in the method
        %.create_stim_sectionlist()
    end
    
    properties
        %.create_stim_sectionlist()
        %----------------------------------------------------------------
        opt__use_local_stim_sectionlist_code = false; %If true code should
        %implement create_stim_sectionlist. If false the default will be
        %used
        opt__first_section_access_string = 'access node[0]'; %This is the 
        %access statement used when using the default creation of the section list ...
        
        %.create_node_sectionlist
        %-----------------------------------------------------------------
        opt__use_local_node_sectionlist_code = false; 
    end
    
    methods (Abstract)
        %Should return an object of the class:
        %
        cell_log_data_obj = getXstimLogData(obj)
        
        getAverageNodeSpacing(obj) %Needed for methods that determine
        %activation volume that take into account redundancy via node
        %repetitions in the longitudinal direction ...
        %NOTE: I don't like this because of the assumptions it makes ...
        
        moveCenter(obj, newCenter) %Needed for getCurrentDistanceCurve
        
        %createCellInNEURON - abstract of neural_cell, not needed here but
        %recorded here just so it is clear we are relying on this method
        
        threshold_info_obj = getThresholdInfo(obj)  %See class: NEURON.cell.threshold_info
        %This method should return an object of the class threshold_info
    end
    
    methods
        function create_stim_sectionlist(obj,cmd_obj)
            %create_stim_sectionlist
            %   
            %   create_stim_sectionlist(obj,cmd_obj)
            %
            %   NEURON.cell.extracellular_stim_capable.create_stim_sectionlist
            
            if obj.opt__use_local_stim_sectionlist_code
                %This command defines the function ...
                %NOTE: It is assumed that the current directory is the model directory ...
                cmd_obj.load_file('create_stim_sectionlist.hoc');
                %This command executes the function ...
                cmd_obj.run_command('create_stim_sectionlist(xstim__all_sectionlist)');
            else
                cmd_obj.run_command(obj.opt__first_section_access_string);
                cmd_obj.run_command('xstim__create_stim_sectionlist(xstim__all_sectionlist)');
            end
        end
        function create_node_sectionlist(obj,cmd_obj)
            %create_node_sectionlist
            %
            %   create_node_sectionlist(obj,cmd_obj)
            %
            %   NEURON.cell.extracellular_stim_capable.create_node_sectionlist
            
            if obj.opt__use_local_node_sectionlist_code
                %This command defines the function ...
                %NOTE: It is assumed that the current directory is the model directory ...
                cmd_obj.load_file('create_node_sectionlist.hoc');
                %This command executes the function ...
                cmd_obj.run_command('create_node_sectionlist(xstim__node_sectionlist)');
            else
                cmd_obj.run_command('xstim__create_node_sectionlist(xstim__node_sectionlist)');
            end 
        end
    end
    
end

