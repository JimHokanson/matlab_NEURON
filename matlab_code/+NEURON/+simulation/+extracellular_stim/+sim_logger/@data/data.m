classdef data < NEURON.sl.obj.handle_light
    %
    %   Class: 
    %       NEURON.simulation.extracellular_stim.sim_logger.data
    %
    %   The main method in this class is:
    %   -------------------------------------------------------------------
    %   NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds
    %
    %   Other Public Methods Include
    %   -------------------------------------------------------------------
    %   NEURON.simulation.extracellular_stim.sim_logger.data.fixRedundantOldData
    %
    %   DOCUMENTATION (see private folder)
    %   -------------------------------------------------------------------
    %   Threshold Sign
    %   Design Notes
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim.sim_logger
    
    properties
        xstim_obj   %Class: NEURON.simulation.extracellular_stim
        %NOTE: In certain cases this object will not be defined as we
        %are only working with saved data ...
        data_path   %Path of where to save this class between calls
    end
    
    properties
        current_stimulus_setup_id = 0   %index of which stimulus setup object
        %is appropriate (matches) given the extracellular_stim simulation object specified
        
        stimulus_setup_objs %Class: NEURON.simulation.extracellular_stim.sim_logger.stimulus_setup
        %These are meant to log the stimuli that led to the results
        %observed. In other words for each result we can index back into
        %this to know what stimulus led to the observed result.
        %
        %BUG: I think I don't save the tissue properties which makes this
        %incomplete for complete knowledge of how things were run
        %
        %BUG: This is also inaccurate since I need to save the simulation
        %class parameters, specifically the temperature ...
        %
        %IMPROVEMENT: Ideally we would have an extracellular_stim
        %recreation class that would instantiate an instance from a
        %previously saved version, and also a class that allows for
        %comparison ... As is the classes that exist are a bit artificial
        
        
        %.setNewAppliedStimulus()
        n_points_per_cell       = [] %This currently indicates how many
        %nodes are present, empty is used to indicate that it hasn't been
        %initialized
    end
    
    properties
        %INDIVIDUAL RESULTS
        %------------------------------------------------------------------
        applied_stimulus_matrix = []    %sims x [points by time]
        threshold_values        = []    %sims x 1
        xyz_center              = []    %sims x xyz
        creation_time           = []    %1 x sims, matlab time (double)
        %of when the entry was created
        stimulus_setup_id       = []    %Which stimulus setup generated
        %this point
        
        %NEW STIMULI
        %------------------------------------------------------------------
        %.getThresholds
        desired_threshold_sign
        new_cell_locations
        predictor_obj           %Class: NEURON.simulation.extracellular_stim.threshold_predictor
        matching_stim_obj
        
        %.setNewAppliedStimulus()
        %NOTE: These stimuli have been corrected so that the threshold
        %to be found is a positive one
        new_stimuli_matrix      = []
    end
    
    properties (Hidden)
        %.getThresholds()
        duplicate_data_warning_shown = false  %Use this to only show the
        %warning message in getThresholds once
    end
    
    properties (Constant)
        VERSION   = 1
    end
    
    %INITIALIZATION =======================================================
    methods
        function obj = data(sim_index,paths_obj,xstim_obj)
            %
            %   obj = data(sim_index,paths_obj,*xstim_obj)
            %
            %   Normally this constructor should be called by 
            %   the sim_logger class.
            %
            %   
            %
            %   INPUTS
            %   ===========================================================
            %   sim_index : Simulation index to load
            %
            %   See Also:
            %       NEURON.simulation.extracellular_stim.sim_logger
            %       NEURON.simulation.extracellular_stim.sim_logger.pathing
            
            
            obj.data_path = paths_obj.getSavedSimulationDataPath(sim_index);

            %Loading previous data
            %--------------------------------------------------------------
            loadDataFromFile(obj)
            
            %Determining Current Setup
            %--------------------------------------------------------------
            if exist('xstim_obj','var')
               obj.xstim_obj = xstim_obj;
               %TODO: Ensure that caller is sim_logger ...
               instantiateCurrentXstimProps(obj)
            end
            
           
        end
    end
    
    %Should I provide these in the sim logger class?
    %Perhaps with a GUI?
    % => goal by index is to allow merging data ...
    methods (Static)
        function obj = getObjectByIndex(index)
           %
           %
           %    FULL PATH:
           %    ===========================================================
           %    NEURON.simulation.extracellular_stim.sim_logger.data.getObjectByIndex
           
           import NEURON.simulation.extracellular_stim.sim_logger.* 
            
           %sim_logger.data
           %sim_logger.pathing
           obj = data(index,pathing);
           
           %obj = NEURON.simulation.extracellular_stim.sim_logger.data(index, 
        end
    end
    
    methods (Hidden)
        function instantiateCurrentXstimProps(obj)
            %
            %
            %   TODO: Clean this up ...
            
            %This call gets an instance of the stimulus setup, which is
            %used for knowing what caused each of the applied stimuli
            stimulus_setup_obj = NEURON.simulation.extracellular_stim.sim_logger.stimulus_setup(obj.xstim_obj);
            
            index = find(stimulus_setup_obj == obj.stimulus_setup_objs);
            
            if length(index) > 1
                error('Expecting singular or empty match')
            end
            
            if isempty(index)
                if isobject(obj.stimulus_setup_objs)
                    obj.stimulus_setup_objs(end+1) = stimulus_setup_obj;
                else
                    obj.stimulus_setup_objs = stimulus_setup_obj;
                end
                obj.current_stimulus_setup_id = length(obj.stimulus_setup_objs);
            else
                obj.current_stimulus_setup_id = index;
            end
            
        end
        function loadDataFromFile(obj)
           %loadDataFromFile
           %
           %    loadDataFromFile(obj)
           
           if exist(obj.data_path ,'file')
                h = load(obj.data_path);
                if h.VERSION ~= obj.VERSION
                    error('Unhandled version mismatch')
                end
                obj.n_points_per_cell       = h.n_points_per_cell;
                                
                obj.applied_stimulus_matrix = h.applied_stimulus_matrix;
                obj.threshold_values        = h.threshold_values;
                obj.xyz_center              = h.xyz_center;
                obj.creation_time           = h.creation_time;
                obj.stimulus_setup_id       = h.stimulus_setup_id;
                
                obj.stimulus_setup_objs     = h.stimulus_setup_objs;
            end 
        end
    end
    
    %ANALYSIS   %==========================================================
    methods
        function compareThresholds(obj,other_data_obj)
            
        end 
    end
    
    %ADDING DATA ==========================================================
    methods

        function initPredictorObj(obj)
           %
           %    ??? Who calls this????
           %
           %
           %    initPredictorObj(obj)
           %
           %    NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds
           %
           
           obj.predictor_obj = NEURON.simulation.extracellular_stim.threshold_predictor(...
                    obj.new_stimuli_matrix,...
                    obj.applied_stimulus_matrix,...
                    obj.xyz_center,....
                    obj.new_cell_locations,...
                    obj.threshold_values); 
        end
        function setNewAppliedStimulus(obj)
            %
            %   
            %
            %   setNewAppliedStimulus(obj)
            %
            %   This function computes the applied stimulus 
            %
            %   See Also:
            %      NEURON.cell.extracellular_stim_capable.getCellXYZMultipleLocations  
            %   
            %   IMPROVEMENT
            %   ===========================================================
            %   NOTE: I don't like how indirect this calling is. I would
            %   prefer that the first part of this code be handled in a
            %   class that specifically handles this.
            %
            %   Current call chain
            %      getCellXYZMultipleLocations 
            %           - get node only locations (cell_obj)
            %               (made abstract by xstim capable)
            %           - computeStimulus (xstim_obj)
            %      followed by some additional logic here
            
            %NEURON.cell.extracellular_stim_capable.getCellXYZMultipleLocations
            xyz_out = obj.xstim_obj.cell_obj.getCellXYZMultipleLocations(obj.new_cell_locations);
            
            sz = size(xyz_out);
            
            %NEURON.simulation.extracellular_stim.computeStimulus
            [t_vec,v_all] = obj.xstim_obj.computeStimulus(...
                'remove_zero_stim_option',1,...
                'xyz_use',reshape(xyz_out,[sz(1)*sz(2) sz(3)]));
            
            v_all = v_all';
            
            applied_stimulus = reshape(v_all,[sz(1) sz(2)*size(v_all,2)]);
            
            %See Threshold Sign documentation for a little bit more on this ...
            if obj.desired_threshold_sign < 0
                applied_stimulus = -1.*applied_stimulus;
            end
            
            obj.new_stimuli_matrix = applied_stimulus;
            
            
            samples_per_time = size(applied_stimulus,2)/length(t_vec);
            
            if isempty(obj.n_points_per_cell)
                obj.n_points_per_cell = samples_per_time;
            elseif obj.n_points_per_cell ~= samples_per_time
                error('Code error, change to stimulus setup detected')
            end
        end
    end
end

