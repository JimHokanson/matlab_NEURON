classdef activation_volume_results < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.reproductions.Hokanson_2013.activation_volume_results
    %
    %   This is meant as an interface to the results from the activation
    %   volume in case anything changes ...
    %
    %   See Also
    %   --------
    %   NEURON.reproductions.Hokanson_2013.activation_volume_requestor
    
    
    %{
  
                    counts: [1×291 double]
       stimulus_amplitudes: [1×291 double]
        raw_abs_thresholds: [37×37×59 double]
     replicated_thresholds: [37×37×59×2 double]
          internode_length: 1150
    z_saturation_amplitude: [720×720 double]
                  xyz_used: {[1×37 double]  [1×37 double]  [1×59 double]}
                     slice: [1×1 NEURON.reproductions.Hokanson_2013.activation_volume_slice]
          replicated_slice: [1×1 NEURON.reproductions.Hokanson_2013.activation_volume_slice]
                 is_single: 1
       electrode_locations: [2×3 double]
               stim_widths: [0.2 0.4]
            fiber_diameter: 10
          phase_amplitudes: [-1 0.5]
        overlap_amplitudes: [2×2 double]
     electrode_z_locations: [-200 200]
                mean_error: 0.0257126724654645  
    
    
    %}
    
    properties
        %TODO: Include threshold results here as well ...
        %NOTE: It would be nice to hold onto the activation object
        %but this requires holding onto the simulation currently
        %
        %Much work is needed to improve the activation object
        
        counts % [1 n] double
        %# of voxels at or above threshold for given stimulus amplitude
        stimulus_amplitudes %[1 n] double
        
        %Note, all points may not be valid as results are only specified
        %up to the maximum stimulus amplitude
        raw_abs_thresholds %[x y z double]
        replicated_thresholds %[x y z 2] double
        
        internode_length %scalar
        z_saturation_amplitude %
        
        xyz_used %{1 x 3} cell
        %{x_vector, y_vector, z_vector}
        
        
        slice  %NEURON.reproductions.Hokanson_2013.activation_volume_slice         
        replicated_slice   %NEURON.reproductions.Hokanson_2013.activation_volume_slice
    end
    
    %Request properties ...
    properties
        d1 = '------------  Properties of Request ---------'
        max_stim_level
        is_single
        electrode_locations
        
        stim_widths
        fiber_diameter
        phase_amplitudes
    end
    
    %Single electrodes only ...
    properties
        d2 = '---------- Props for signle electrode only --------'
        overlap_amplitudes
        electrode_z_locations
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
    
    %     methods
    %         function overlap_amplitude = getDualOverlapAmplitudeFromSingle(dual_obj,single_obj)
    %
    %         end
    %     end
    
    %PLOTTING METHODS
    %----------------------------------------------------------------------
    methods
        
    end
    
end

