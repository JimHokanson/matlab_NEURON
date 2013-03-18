classdef electrode < handle_light
    %
    %   Class:
    %       NEURON.simulation.extracellular_stim.electrode
    %
    %   This class implements a basic extracellular stimulation electrode
    %   for which one can specify times of stimulation and the stimulus
    %   level at those times.
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim
    %
    %   CONSTRUCTOR CALL:
    %   NEURON.simulation.extracellular_stim.electrode.create
    %
    %   DATA SETTING METHODS
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.electrode.moveElectrode
    %   NEURON.simulation.extracellular_stim.electrode.setStimPattern
    %
    %   METHODS IN OTHER FILES
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.electrode.getMergedStimTimes
    %   NEURON.simulation.extracellular_stim.electrode.plot
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Finish plot method
    %   2) Provide retrieval method for describing stimulus on a fixed time
    %   scale. In other words, given a dt and a scale multipler, return a
    %   matrix of all electrode channels and their stimulus amplitude over
    %   time.
    %   3) Could make it easier to insert a train of pulses ... 
    %   4) Add ability to change # of electrodes
    
    properties (SetAccess = private)
        %.Constructor
        %.moveElectrode
        xyz     %(um, row vector)  %Spatial location of the electrode
        %For more info, see "notes_on_reference_frames" in the private
        %folder of this class
        
        %.setStimPattern()
        %------------------------------------------------------------------
        stimulus_transition_times  = [0 0.1 0.3 0.7]  %(ms) Time of stimulus transitions.
        
        base_amplitudes = [0 -1 0.5 0]  %(Current, uA)
        %For more information on this variable see
        %"notes_on_stimulus_amplitude" in the private folder of this class
    end
    
    properties (SetAccess = private, Hidden)
        %.objectChanged()
        configuration = 1 %This was added on to allow querying as to whether
        %or not it had changed since last asked. This is primarily for
        %recomputing the applied stimulus to a cell.
    end
    
    %INITIALIZATION METHODS ===============================================
    methods (Static)
        function objs = create(xyz)
            %create
            %
            %    objs = NEURON.simulation.extracellular_stim.electrode.create(xyz)
            %
            %    Constructor method. This method is required due to a bug
            %    in Matlab.
            %
            %    For bug reference see:
            %    http://www.mathworks.com/matlabcentral/answers/51648-unable-to-clear-classes
            %    http://www.mathworks.com/support/bugreports/893538
            %
            %    INPUTS
            %    =============================================
            %    xyz : [n_electrodes x xyz]

            if size(xyz,2) ~= 3
                error('xyz must be a 3 element vector')
            end
            
            nElecs = size(xyz,1);
            
            for iElec = 1:nElecs
                objs(iElec) = NEURON.simulation.extracellular_stim.electrode(xyz(iElec,:)); %#ok<AGROW>
            end
        end
    end
    
    methods (Access = private)
        %Made private due to bug in Matlab.
        %Need to call NEURON.simulation.extracellular_stim.electrode.create instead :/
        function obj = electrode(xyz)
            %electrode
            %
            %   Class:
            %   NEURON.simulation.extracellular_stim.electrode
            %
            %   objs = electrode(xyz)
            
            obj.xyz = xyz;
        end
    end
    
    methods
        function [has_changed,current_config_all] = hasConfigurationChanged(objs,previous_configuration)
            %hasConfigurationChanged
            %
            %   [has_changed,current_config_all] = hasConfigurationChanged(objs,previous_configuration)
            %
            %   INPUTS
            %   ===========================================================
            %   previous_configuration : should be the previous output from this
            %       function or empty if not yet called
            %
            %   OUTPUTS
            %   ===========================================================
            %   has_changed : Whether or not the class has changed since
            %       last calling this function given the previous configuration
            %   current_config_all : Format subject to change, but this
            %       value should be held on to for future calls to this
            %       function.
            
            n_electrodes = length(objs);
            current_config_all = [objs.configuration];
            
            if isempty(previous_configuration)
                has_changed         = true;
                return
            elseif length(previous_configuration) ~= n_electrodes
                error('The # of electrodes has changed, dynamic changing of the # of electrodes is not supported')
            end
            
            current_config_all = zeros(1,n_electrodes);
            for iElec = 1:n_electrodes
                cur_config  = objs(iElec).configuration;
                has_changed = cur_config ~= previous_configuration(iElec);
                if has_changed
                    break
                end
            end
        end
    end
    
    %FOR OTHERS    %=======================================================
    methods (Hidden)
        function [log_data,zero_scales] = getLogData(objs)
            %getLogData
            %
            %   [log_data,zero_scales] = getLogData(objs)
            %
            %   OUTPUTS
            %   ===========================================================
            %   log_data    : output for sim_logger. Current format is the
            %       duration of each stimulus and of each break, with the
            %       exception of the first stimulus break (if present) at time
            %       t = 0
            %   zero_scales : (logical), for each stimulus transition time
            %   this indicates whether or not
            %
            %
            %   JAH NOTE: I would like to make this its own class
            %   In addition it will support comparison methods
            
            [t_vec,all_scales] = getMergedStimTimes(objs);
            
            zero_scales = all(all_scales == 0,2);
            
            if ~zero_scales(end)
                error('Expected no stimulation specification at the end')
            end
            %NOTE: If we stimulate until the end then
            %we need to include a term that takes into account the length
            %of the simulation
            
            if zero_scales(1)
                log_data = diff(t_vec);
            else
                log_data = diff(t_vec(2:end));
            end
            
        end
    end
    
    
    %Info Retrieval   %====================================================
    methods
        function xyz_bounds = getXYZBounds(objs)
            %getXYZBounds Returns xyz min & max for all electrodes
            %
            %   xyz_bounds = getXYZBounds(objs)
            %
            %   OUTPUTS
            %   ========================================
            %   xyz_bounds : [min,max x xyz]
            
            all_xyz         = vertcat(objs.xyz);
            xyz_bounds      = zeros(2,3);
            xyz_bounds(1,:) = min(all_xyz);
            xyz_bounds(2,:) = max(all_xyz);
        end
    end
    
    %EVENT HANDLING    %===================================================
    methods (Access = private, Hidden)
        function objectChanged(objs)
            for iObj = 1:length(objs)
                obj = objs(iObj);
                obj.configuration = obj.configuration + 1;
            end
        end
    end
    
    %PUBLIC MANIPULATON METHODS   %========================================
    methods
        function moveElectrode(obj,xyz)
            obj.xyz = xyz;
            objectChanged(obj)
        end
    end
    
end

