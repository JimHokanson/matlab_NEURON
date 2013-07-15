classdef activation_volume_results < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.reproductions.Hokanson_2013.activation_volume_results
    %
    %   This is meant as an interface to the results from the activation
    %   volume in case anything changes ...
    
    properties
        %TODO: Include threshold results here as well ...
        %NOTE: It would be nice to hold onto the activation object
        %but this requires holding onto the simulation currently
        %
        %Much work is needed to improve the activation object
        
        counts
        stimulus_amplitudes
        raw_abs_thresholds
        internode_length
        z_saturation_amplitude
        xyz_used
        
        
        slice_thresholds
        slice_xyz
        slice_labels
        slice_dim
        slice_value
    end
    
    %Request properties ...
    properties
        is_single
        electrode_locations
        
        stim_widths
        fiber_diameter
        phase_amplitudes
    end
    
    %Single electrodes only ...
    properties
       overlap_amplitudes
       mean_error
    end
    
    methods
        %------------------------------------------------------------------
        %Constructed by:
        %NEURON.reproductions.Hokanson_2013.activation_volume_requestor
        %------------------------------------------------------------------
        % function obj = activation_volume_results
        % end
    end
    
    methods
    end
    
    %PLOTTING METHODS
    %----------------------------------------------------------------------
    methods
        
    end
    
end
