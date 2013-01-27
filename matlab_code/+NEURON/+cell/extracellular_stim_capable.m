classdef extracellular_stim_capable < handle
    %
    %   Class:
    %       NEURON.cell.extracellular_stim_capable
    %
    %   Place this class in cells to ensure that the cell is capable of
    %   being involved in an extracellular stimulation sim.
    %
    %
    %   REQUIRED LOCAL NEURON METHODS
    %   ===================================================================
    %
    %
    %   OPTIONAL NEURON METHODS
    %   ===================================================================
    %   create_stim_sectionlist.hoc
    %   create_node_sectionlist.hoc
    %
    %   IMPROVEMENTS:
    %   ===================================================================
    %   1) Write method that verifies that all of the NEURON related code
    %      is setup
    %           TODO: add specifics of what this would entail ...
    %
    %
    %   2)
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim
    %
    %   Class: NEURON.cell.extracellular_stim_capable
    
    properties (Abstract,SetAccess = private)
        xyz_all %NOTE: This is a [n x 3] vector which specifies the centers
        %of each segment in the NEURON model. These points are where the
        %stimulus is applied to.
        %
        %   For more informaton on how this relates to the stimulus and the
        %   spatial layout of the cell see:
        %       Spatial Layout Stimulus - NEURON correspondance
        %   in the private folder under the extracellular_stim class
    end
    
    %.create_stim_sectionlist() -------------------------------------------
    properties
        opt__use_local_stim_sectionlist_code = false; %If true code should
        %implement create_stim_sectionlist.hoc. If false the default method
        %will be used. The default is usually sufficient for cases with no
        %cell branching (e.g. axons)
        
        opt__first_section_access_string = 'access node[0]'; %This is the
        %access statement used when using the default creation method
        %of the section list. This in general should be a pointer to the
        %first section ...
    end
    
    %.create_node_sectionlist() -------------------------------------------
    properties
        opt__use_local_node_sectionlist_code = false;
    end
    
    methods (Abstract)
        %createCellInNEURON - abstract of neural_cell, not needed here but
        %recorded here just so it is clear we are relying on this method
        
        
        %------------------------------------------------------------------
        %JAH TODO: Change this method. I want to instead for recreation
        %methods that allow recreating a cell from a saved file. The class
        %should also be responsible for comparison.
        %   Parts:
        %       1) Get info for saving
        %       2) Write comparison methods
        %       3) Eventually write reloading functionality
        
        %Should return an object of the class:
        %NEURON.simulation.extracellular_stim.sim_logger.cell_log_data
        cell_log_data_obj = getXstimLogData(obj)
        %------------------------------------------------------------------
        
        getAverageNodeSpacing(obj) %Needed for methods that determine
        %activation volume that take into account redundancy via node
        %repetitions in the longitudinal direction ...
        %NOTE: I don't like this because of the assumptions it makes
        %regarding an axon type cell.
        
        
        moveCenter(obj, newCenter) %This is needed by a few simulation methods.
        %Changing the center should change the definition of xyz_all
        
        
        threshold_info_obj = getThresholdInfo(obj)  %See Class:
        %       NEURON.cell.threshold_info
        %This method should return an object of the class threshold_info.
        %Who uses this??????
        
        xyz_nodes = getXYZnodes(obj) %Written for sim logger where
        %I want to look at the stimulus applied to the nodes, adding
        %internodes adds considerable size and is hopefully not
        %necessary ..
        %
        %   NOTE: In the event of multiple segments per node section, or
        %   even multiple sections per nodes, this should only return a
        %   single representative sample.
        
    end
    
    %Standard Shared Methods ==============================================
    methods
        function [hasChanged,new_config] = hasSpatialInformationChanged(obj,previous_config)
            %
            %   [hasChanged,new_config] = hasSpatialInformationChanged(obj,previous_config)
            %
            %   This method is used by extracellular_stim to determine if
            %   it should recalculate the stimulus parameters between
            %   simulation runs. The default behavior is to indicate that a
            %   change IS necessary. The cell class may choose to redefine
            %   this method to be more accurate.
            %
            %   Only morphological changes should results in spatial
            %   information changing. If the axial resistance of the cell
            %   changes, there is no need to recalculate the applied
            %   stimulus.
            
            hasChanged = true;
            new_config = [];
        end
        function create_stim_sectionlist(obj,cmd_obj)
            %create_stim_sectionlist
            %
            %   create_stim_sectionlist(obj,cmd_obj)
            %
            %   This is the default method for creating a section list that
            %   is transversed for stimulation. When applying stimulaton
            %   this list is traversed. For each section in the list, all
            %   segments are traversed. For each segment an index is
            %   incremented and the next value in the applied extracellular
            %   potential is applied.
            %
            %   NEURON.cell.extracellular_stim_capable.create_stim_sectionlist
            
            if obj.opt__use_local_stim_sectionlist_code
                %This command defines the function ...
                %NOTE: It is assumed that the current directory is the model directory ...
                cmd_obj.load_file('create_stim_sectionlist.hoc');
                %This command executes the function ...
                cmd_obj.run_command('create_stim_sectionlist(xstim__all_sectionlist)');
            else
                
                %This accesses the head section and uses transverses the
                %connections from this section.
                cmd_obj.run_command(obj.opt__first_section_access_string);
                cmd_obj.run_command('xstim__create_stim_sectionlist(xstim__all_sectionlist)');
            end
        end
        function create_node_sectionlist(obj,cmd_obj)
            %create_node_sectionlist
            %
            %   create_node_sectionlist(obj,cmd_obj)
            %
            %   This is a default method for creating a list of sections
            %   that correspond to nodes in the model. This section list is
            %   traversed in NEURON to tell NEURON to record the membrane
            %   potential at these nodes during the simulation. The
            %   membrane potential results are used to determine threshold
            %   information.
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
        function xyz_out = getCellXYZMultipleLocations(obj,cell_centers)
            %   getCellXYZMultipleLocations
            %
            %   xyz_out = getCellXYZMultipleLocations(obj,cell_centers)
            %
            %   Created for use with the sim_logger. Specifically this file
            %   is the first in a set of steps towards computing the
            %   applied stimulus to multiple cells all at once, instead of
            %   one at a time.
            %
            %   INPUTS
            %   ===========================================================
            %   cell_centers : (cell or samples x xyz), if in cell format,
            %       the cell should be of length 3, with the entries
            %       containing the x,y, & z spatial variations to use, such
            %       as {-10:10 -10:10 -50:50}
            %
            %   OUTPUTS
            %   ===========================================================
            %   xyz_out: (cell_centers x space x xyz) space corresponds
            %   to each node location, given the cell centers
            %
            %   IMPORTANT NOTES
            %   ===========================================================
            %   1) This method currently moves the cell back to zero.
            %
            %   IMPROVEMENTS
            %   ===========================================================
            %   1) We should allow getting the center position and then
            %   moving the cell back to its original position.
            %   2) Allow for returning the complete set of spatial stimuli,
            %   rather than just at the nodes.
            %
            %   See Also:
            %       NEURON.cell.axon.MRG.getXYZnodes
            
            if iscell(cell_centers)
                [X,Y,Z] = meshgrid(cell_centers{:});
                xyz_cell_centers = [X(:) Y(:) Z(:)];
            else
                xyz_cell_centers = cell_centers;
            end
            
            obj.moveCenter([0 0 0]);
            
            xyz_cell = obj.getXYZnodes();
            %xyz_cell - space x xyz
            
            xyz_out = bsxfun(@plus,permute(xyz_cell_centers,[1 3 2]),permute(xyz_cell,[3 1 2]));
        end
        function runDefaultXstimSetup(obj,cmd_obj)
            %runDefaultXstimSetup
            %
            %
            %NOTE: current directory should point to cell
            %TODO: Add on check mechanism that ensures this ...
            %simulation property - current_neuron_directory
            %   cmd obj - query this before changing
            
            %NEURON.cell.extracellular_stim_capable.create_stim_sectionlist
            obj.create_stim_sectionlist(cmd_obj);
            
            obj.create_node_sectionlist(cmd_obj);
            
            NEURON.lib.sim_logging.record_membrane_voltages(...
                cmd_obj,'xstim__node_sectionlist','xstim__node_vm_hist')
            
            %Not needed right now, default to recreating, might reoptimize
            %later
            %cmd_obj.run_command('xstim__cell_setup_changed_since_last_playback_initialization = 1');
            
        end
        
        function createExtracellularStimCell(obj)
            %
            %
            %
            %   TODO: FIX THIS CLASS
            
            
            
            %This method is currently not required by 
            %this class, not sure how I am supposed to clean this up ...
            %
            %   TODO: Ask Matt about this ...
            %
            
            %   KNOWN IMPLEMENTATIONS:
            %       NEURON.cell.axon.MRG.createCellInNEURON
            cell_defined = obj.createCellInNEURON();
            
            %??? How do we know if we need to reinitialize the spatial info????
            
            %NOTE: I think we currently have a potential error case
            %If we recompute the xstim setup, but we don't change
            %the spatial info, then we might not recompute the stimlus
            %even though our vectors have been redefined in NEURON
            %
            %TODO: Fix this ...
            %
            %For now, link to neuron creation ...
            
            %The cmd_obj is also something that only the cell
            %has, it isn't clear how this class would know about that ...
            if cell_defined
                cmd_obj = obj.cmd_obj;
                %NEURON.cell.extracellular_stim_capable.runDefaultXstimSetup
                obj.runDefaultXstimSetup(cmd_obj);
            end
        end
    end
    
end

