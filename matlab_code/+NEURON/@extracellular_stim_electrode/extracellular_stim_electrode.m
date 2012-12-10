classdef extracellular_stim_electrode < handle
    %estim_electrode - Electrical Stimulation Electrode
    %
    %  XYZ
    %  z along electrode, positive goes proximal
    %  x - medial positive
    %  y - ventral positive
    %
    %   See Also:
    %       NEURON.simulation.extracellular_stim
    %
    %   Class:
    %       NEURON.extracellular_stim_electrode
    %
    %   METHODS IN OTHER FILES
    %   =============================================
    
    properties (SetAccess = private)
        time    = []	%time of transition %See setStimPattern
        scale   = []    %Scale factor of current
        
        %NOTE: The concept of stimulation current amplitude is all
        %relative in this framework. The problem arises when referring to
        %stimulation in terms of a fixed stimulus amplitude. Even for a
        %single electrode, we almost never use a single current amplitude
        %due to biphasic stimulation, in which we might stimulate at 3 uA,
        %but what we really might mean is -3 uA followed by 3 uA for charge
        %balancing. Alternatively we might stimulate at -3 uA followed by
        %1.5 uA with twice the duration, but we report that all as 3 uA.
        %Thus the scale factor should be relative to other electrodes. The
        %solver will solve for threshold using a single factor which is
        %multiplied by all scales for the electrodes before they are
        %applied.
        %Example: Represent a typical -3 followed by 1.5 uA current
        %
        %  scale = [1 -0.5], solve for negative current threshold
        
        xyz     %um  %Changing this during run time is not yet implemented ...
                %format, row vector
    end
    
    properties (Hidden)
        ev_man_obj %(Class NEURON.simulation.extracellular_stim.event_manager)
    end
    
    %INITIALIZATION METHODS =========================================
    methods
        function obj = extracellular_stim_electrode(xyz)
            %extracellular_stim_electrode
            %
            %    CLASS: NEURON.extracellular_stim_electrode
            %
            %    objs = extracellular_stim_electrode(xyz)
            %
            %    INPUTS
            %    =============================================
            %    xyz : [n_electrodes x xyz]
            
            if nargin == 0
                return
            end
            
            if size(xyz,2) ~= 3
                error('xyz must be a 3 element vector')
            end
            
            nElecs = size(xyz,1);
            obj(nElecs) = NEURON.extracellular_stim_electrode;
            for iElec = 1:nElecs
                obj(iElec).xyz     = xyz(iElec,:);
            end
        end
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
            %    =============================================
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
                objs(iElec).time  = [0 start_time start_time + cumsum(phase_durations)];
                objs(iElec).scale = [0 phase_amplitudes 0]; %Start at 0, end at 0
            end
            
            objectChanged(objs)
        end
    end
    
    %VISUALIZATION
    %================================================================
    %methods in NEURON.simulation.extracellular_stim
    
    methods
        function xyz_bounds = getXYZBounds(objs)
           %getXYZBounds
           %    
           %    xyz_bounds = getXYZBounds(objs)
           %
           all_xyz    = vertcat(objs.xyz);
           xyz_bounds = zeros(2,3);
           xyz_bounds(1,:) = min(all_xyz);
           xyz_bounds(2,:) = max(all_xyz);
        end
    end
    
    %EVENT HANDLING =================================================
    methods
        function objectChanged(objs)
            for iObj = 1:length(objs)
                obj = objs(iObj);
                if isobject(obj.ev_man_obj)
                    stimElectrodesChanged(obj.ev_man_obj)
                end 
            end
        end
        
        function setEventManagerObject(objs,ev_man_obj)
            for iObj = 1:length(objs)
                objs(iObj).ev_man_obj = ev_man_obj;
            end
        end
        function moveElectrode(obj,xyz)
            obj.xyz = xyz;
            objectChanged(obj)
        end
    end
    
end

