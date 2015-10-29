classdef applied_stimuli < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.applied_stimuli
    %
    %   This is a simple wrapper for holding onto the stimulus information
    %   for a set of cell locations.
    %
    %   MAIN METHODS
    %   ===================================================================
    %   initializeReducedDimStimulus
    %   getLowDStimulus
    %
    %   See Also:
    %   NEURON.xstim.single_AP_sim.applied_stimulus_manager
    
    properties
        xstim %Reference to simulation object to compute applied stimulus ...
    end
    
    
    %Public Properties ====================================================
    properties
        n                %Shortcut for getting size. This is equivalent to
        %size(cell_locations,1).
        cell_locations   %[n x 3], center locations of the cell. Using the
        %xstim reference we can compute the applied stimulus.
        stimulus         %[n x nodes interleaved]
    end
    
    properties (Hidden)
        low_d_stimulus   %[n x d] This was made hidden so that display
        %wouldn't cause an error. This property can be accessed via:
        %getLowDStimulus()
    end
    
    %Retrieval methods ====================================================
    methods
        function value = get.low_d_stimulus(obj)
            if isempty(obj.low_d_stimulus) && obj.n ~= 0
                error('The low dimensional representation must first be initialized with initializeReduceDimStimulus')
            end
            value = obj.low_d_stimulus;
        end
        function value = get.stimulus(obj)
            if isempty(obj.stimulus) && obj.n ~= 0
                obj.populateStimulusValues();
            end
            value = obj.stimulus;
        end
    end
    
    
    %Constructor ==========================================================
    methods
        function obj = applied_stimuli(xstim,cell_locations)
            obj.xstim          = xstim;
            obj.cell_locations = cell_locations;
            obj.n              = size(cell_locations,1);
            
            %NOTE: We might not actually use this class for prediction so
            %we won't compute the stimulus until we have a request for it ...
        end
    end
    
    %Public Methods  ======================================================
    methods
        %initializeReducedDimStimulus
        function value = getLowDStimulus(obj)
            %
            %   See comment on method by property on why I have a silly
            %   method for accessing this property ...
            
            value = obj.low_d_stimulus;
        end
    end
    
    methods
        function populateStimulusValues(obj)
            %
            %   populateStimulusValues(obj)
            %
            %   This method is called lazily by the get method of the
            %   property 'stimulus'
            %
            %   This is a bit messier than I would like due the to
            %   dimensionality shifting ...
            %
            %   I might be able to create a class which handles this a bit
            %   better ..., or perhaps functions in the xyz package ...
            
            if obj.n == 0
                return
            end
            
            %Call to:
            %NEURON.cell.extracellular_stim_capable.getCellXYZMultipleLocations
            xyz_out = obj.xstim.cell_obj.getCellXYZMultipleLocations(obj.cell_locations);
            
            %xyz_out: (cell_centers x space x xyz)
            %
            %We want to change this to [n x 3] for the computation
            %
            %We'll later translate this back to:
            %
            %   n x (space,time)
            
            sz = size(xyz_out);
            
            %NEURON.simulation.extracellular_stim.computeStimulus
            [~,v_all] = obj.xstim.computeStimulus(...
                'remove_zero_stim_option',1,...
                'xyz_use',reshape(xyz_out,[sz(1)*sz(2) sz(3)]));
            
            v_all = v_all';
            
            obj.stimulus = reshape(v_all,[sz(1) sz(2)*size(v_all,2)]);
        end
    end
    
    
    
end

