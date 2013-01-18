classdef extracellular_stim_electrode < handle_light
    %
    %   CLASS: NEURON.extracellular_stim_electrode
    %
    %   This class implements a basic extracellular stimulation electrode
    %   for which one can specify times of stimulation and the stimulus
    %   level at those times.
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim
    %
    %   DATA SETTING METHODS
    %   ===================================================================
    %   NEURON.extracellular_stim_electrode.create
    %   NEURON.extracellular_stim_electrode.moveElectrode
    %   NEURON.extracellular_stim_electrode.setStimPattern
    %
    %   METHODS IN OTHER FILES
    %   ===================================================================
    %   NEURON.extracellular_stim_electrode.getMergedStimTimes
    %   NEURON.extracellular_stim_electrode.plot
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Finish plot method
    
    properties (SetAccess = private)
        %.setStimPattern()
        %------------------------------------------------------------------
        time    = []	%Time of stimulus transitions.
        %NOTE: Currently time(1) should be zero
        
        scale   = []    %(Current, uA)
        %NOTE: Currently scale(1) should be zero
        %For more information on this variable see
        %"notes_on_stimulus_amplitude" in the private folder of this class
        
        
        %.setStimPattern() - write
        %.getMergedStimTimes() - read
        is_set = false    %Set true when time and scale have been set
        
        %.objectChanged()
        configuration = 1 %This was added on to allow querying as to whether or not
        %it had changed since last asked. This is primarily for recomputing
        %the applied stimulus to a cell.
        
        %.Constructor
        xyz     %(microns, row vector)  %Changing this during run time is not
        %yet implemented. Instead we will tend to move the cell and keep
        %the electrode at a fixed location.
        %for more info, see "notes_on_reference_frames" in the private
        %folder of this class
    end
    
    %INITIALIZATION METHODS ===============================================
    methods (Static)
        function objs = create(xyz)
            %
            %    objs = create(xyz)
            %
            %    INPUTS
            %    =============================================
            %    xyz : [n_electrodes x xyz]
            %
            %    FULL PATH:
            %    NEURON.extracellular_stim_electrode.create
            
            %STUPID BUG ..., See:
            %http://www.mathworks.com/matlabcentral/answers/51648-unable-to-clear-classes
            %http://www.mathworks.com/support/bugreports/893538
            if size(xyz,2) ~= 3
                error('xyz must be a 3 element vector')
            end
            
            nElecs = size(xyz,1);
            
            for iElec = 1:nElecs
                objs(iElec) = NEURON.extracellular_stim_electrode(xyz(iElec,:)); %#ok<AGROW>
            end
        end
    end
    
    methods (Access = private)
        %Made private to prevent bug
        %Need to call NEURON.extracellular_stim_electrode.create instead :/
        function obj = extracellular_stim_electrode(xyz)
            %extracellular_stim_electrode
            %
            %    CLASS: NEURON.extracellular_stim_electrode
            %
            %    objs = extracellular_stim_electrode(xyz)
            %
            
            obj.xyz = xyz;
        end
    end
    
    methods
        function setStimPattern(objs,start_time,phase_durations,phase_amplitudes)
            %setStimPattern
            %
            %    setStimPattern(obj,start_time,dur,amp)
            %
            %    INPUTS ======================================
            %    start_time       : start of the phases
            %    phase_durations  :
            %    phase_amplitudes :
            %
            %    IMPROVEMENTS
            %    ==========================================================
            %    1) Could make it easier to insert a train of pulses ...
            %    2) Could allow everything to start at time zero
            %
            %   NOTE: This method forces the start and the end times to be specified
            %   TODO: Document and do error checking ...
            %
            
            if start_time <= 0
                error('Currently start time must occur after time 0')
            end
            
            nElecs = length(objs);
            for iElec = 1:nElecs
                %NOTE: We ensure taking care of start times and end times
                objs(iElec).time   = [0 start_time start_time + cumsum(phase_durations)];
                objs(iElec).scale  = [0 phase_amplitudes 0]; %Start at 0, end at 0
                objs(iElec).is_set = true;
            end
            
            objectChanged(objs)
        end
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
            %   has_changed : whether or not the class has changed since
            %       last calling this function given the previous configuration 
            %   current_config_all : format subject to change, but this
            %       value should be held on to for future inputs to this
            %       function ...
            
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
    
    %FOR OTHERS
    %======================================================================
    methods
        function [log_data,zero_scales] = getLogData(objs)
            %getLogData
            %
            %   [log_data,zero_scales] = getLogData(objs)
            %
            %   OUTPUTS
            %   ===========================================================
            %   log_data : output for sim_logger. Current format is the
            %   duration of each stimulus and of each break, with the
            %   exception of the first stimulus break (if present) at time
            %   t = 0
            %   zero_scales : (logical), for each stimulus transition time
            %   this indicates whether or not
            %
            %
            %   JAH NOTE: I am going to change this ...
            %
            %
            %
            
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
    
    
    %VISUALIZATION   ======================================================
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
    
    %EVENT HANDLING =================================================
    methods (Access = private)
        function objectChanged(objs)
            for iObj = 1:length(objs)
                obj = objs(iObj);
                obj.configuration = obj.configuration + 1;
            end
        end
    end
    
    methods
        function moveElectrode(obj,xyz)
            obj.xyz = xyz;
            objectChanged(obj)
        end
    end
    
end

