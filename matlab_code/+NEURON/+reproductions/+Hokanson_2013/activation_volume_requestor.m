classdef activation_volume_requestor < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.reproductions.Hokanson_2013.activation_volume_requestor
    %
    %
    
    properties 
       main %Class: NEURON.reproductions.Hokanson_2013
    end
    
    properties
       stim_resolution  = 0.1
       slice_dim = 2
       slice_value = 0
    end
    
    properties
       custom_setup_function %This should be called if there are addditional
       %steps to 
       stim_widths      = [0.2 0.4] %TODO: Describe formats ...
       fiber_diameter   = 10
       stim_start_time  = 0.1
       phase_amplitudes = [-1 0.5]
    end
    
    methods
        function obj = activation_volume_requestor(main_obj)
            %
            %   INPUTS
            %   ===========================================================
            %   main_obj : NEURON.reproductions.Hokanson_2013
            %
            obj.main = main_obj;
        end
        function result_objs = makeRequest(obj,electrode_locations,max_stim_level,varargin)
           %
           % 
           %    OUTPUTS
           %    ===========================================================
           %    result_objs: 
           %
           %
           %    OPTIONAL INPUTS
           %    ===========================================================
           %    single_with_replication : (default false), if true
           %        replicates a single electrode 
            
           in.single_with_replication = false;
           in = sl.in.processVarargin(in,varargin);
           
           electrode_locations_in = electrode_locations;
           
           if in.single_with_replication
               
               all_replication_sets = electrode_locations;
               if ~iscell(all_replication_sets)
                  all_replication_sets = {all_replication_sets};
               end
               electrode_locations = [0 0 0];
           else
               all_replication_sets = {[]};
           end
                 
           xstim = obj.main.instantiateXstim(electrode_locations); 
           
           xstim.cell_obj.props_obj.changeFiberDiameter(obj.fiber_diameter);

           xstim.elec_objs.setStimPattern(obj.stim_start_time,obj.stim_widths,obj.phase_amplitudes);

           
           if ~isempty(obj.custom_setup_function)
              obj.custom_setup_function(obj) 
           end

           internode_length = xstim.cell_obj.getAverageNodeSpacing;

           %NEURON.simulation.extracellular_stim.sim__getActivationVolume
           %NEURON.simulation.extracellular_stim.results.activation_volume
           act_obj   = xstim.sim__getActivationVolume();
           
           
           %Actual Testing
           %---------------------------------------------------------------
           n_sets = length(all_replication_sets);
           
           result_objs = cell(1,n_sets);
           for iSet = 1:n_sets
               replication_points = all_replication_sets{iSet};
               
               [stim_level_counts,extras] = act_obj.getVolumeCounts(max_stim_level,...
                   'replication_points',replication_points,...
                   'stim_resolution',obj.stim_resolution);

               [slice_thresholds,slice_xyz] = ... 
                    act_obj.getSliceThresholds(max_stim_level,obj.slice_dim,obj.slice_value);

               %Population of result
               %---------------------------------------------------------------
               r = NEURON.reproductions.Hokanson_2013.activation_volume_results;

               r.counts = stim_level_counts;
               r.stimulus_amplitudes    = extras.stim_amplitudes;
               r.raw_abs_thresholds     = extras.raw_abs_thresholds;
               
               r.internode_length       = internode_length;
               r.z_saturation_amplitude = extras.z_saturation_threshold;
               r.xyz_used               = extras.xyz_cell;
               
               
               r.slice_thresholds       = squeeze(slice_thresholds);
               r.slice_xyz              = slice_xyz(1:3 ~= obj.slice_dim);
               labels_temp = 'xyz';
               r.slice_labels           = labels_temp(1:3 ~= obj.slice_dim);
               r.slice_dim              = obj.slice_dim;
               r.slice_value            = obj.slice_value;

               r.is_single              = in.single_with_replication;
               if r.is_single
                  r.electrode_locations = replication_points;
               else
                  r.electrode_locations    = electrode_locations_in;
               end
               r.stim_widths            = obj.stim_widths;
               r.fiber_diameter         = obj.fiber_diameter;
               r.phase_amplitudes       = obj.phase_amplitudes;
               
               rep_extras = extras.threshold_extras.replication_extras;
               
               r.overlap_amplitudes     = rep_extras.electrode_interaction_thresholds;
               r.mean_error             = rep_extras.mean_rep_error;
               
               result_objs{iSet} = r;
           end
           keyboard
        end
    end
    
end

