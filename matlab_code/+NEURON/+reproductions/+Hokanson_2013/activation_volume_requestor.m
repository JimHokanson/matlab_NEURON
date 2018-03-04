classdef activation_volume_requestor < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.reproductions.Hokanson_2013.activation_volume_requestor
    %
    %   This class needs to be documented ...
    
    properties
        main %Class: NEURON.reproductions.Hokanson_2013
    end
    
    properties
        stim_resolution  = 0.1
        slice_dims     = 'xz' %x by z %This should be two elements long
        slice_value    = 0
        quick_test     = false %If true we get junk results on the integration
        %which can be useful for testing the workflow
        merge_solvers  = false
        use_new_solver = false
    end
    
    properties
        custom_setup_function %This should be called if there are addditional
        %steps between initializing the xstim object
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
            %   result_objs = makeRequest(obj,electrode_locations,max_stim_level,varargin)
            %
            %   The only thing this function can currently vary over is
            %   different electrode locations ...
            %
            %   Inputs
            %   -------
            %   electrode_locations : (cell),
            %       
            %   Outputs
            %   -------
            %   result_objs: NEURON.reproductions.Hokanson_2013.activation_volume_results
            %
            %
            %   Optional Inputs
            %   ---------------
            %   single_with_replication : (default false)
            %       If true replicates results to all input electrode
            %       locations.
            %   single_output : (default true)
            %       If only one electrode location is requested the output
            %       is an object, not a cell array of objects.
            
            in.single_with_replication = false;
            in.single_output = true;
            in = NEURON.sl.in.processVarargin(in,varargin);
            
            if ~iscell(electrode_locations)
                electrode_locations = {electrode_locations};
            end
            
            n_sets = length(electrode_locations);
            
            if in.single_with_replication
                all_replication_sets = electrode_locations;
                electrode_locations = repmat({[0 0 0]},[1 n_sets]);
            else
                all_replication_sets = {[]};
            end
            
            xyz_info  = NEURON.sl.xyz.str.parsed(obj.slice_dims);
            slice_dim = find(xyz_info.missing_mask);
            
            %Loop over all locations ...
            result_objs = cell(1,n_sets);
            for iSet = 1:n_sets
                cur_elec_loc = electrode_locations{iSet};
                
                if iSet == 1 || ~in.single_with_replication
                    %NEURON.simulation.extracellular_stim
                    xstim = obj.main.instantiateXstim(cur_elec_loc);
                    
                    xstim.cell_obj.props_obj.changeFiberDiameter(obj.fiber_diameter);
                    
                    xstim.elec_objs.setStimPattern(obj.stim_start_time,obj.stim_widths,obj.phase_amplitudes);
                    
                    if ~isempty(obj.custom_setup_function)
                        obj.custom_setup_function(obj,xstim)
                    end
                    
                    internode_length = xstim.cell_obj.getAverageNodeSpacing;
                    
                    %NEURON.simulation.extracellular_stim.sim__getActivationVolume
                    %NEURON.simulation.extracellular_stim.results.activation_volume
                    
                    if obj.use_new_solver
                        %r: NEURON.xstim.single_AP_sim.request_handler
                        %act_obj: NEURON.simulation.extracellular_stim.results.activation_volume
                        %r = xstim.sim__getSingleAPSolver('solver','from_old_solver');
                        r = xstim.sim__getSingleAPSolver('solver','default');
                        act_obj   = xstim.sim__getActivationVolume('request_handler',r);
                    else
                        act_obj   = xstim.sim__getActivationVolume();
                    end
                end
                
                %Actual Testing
                %---------------------------------------------------------------
                %NEURON.simulation.extracellular_stim.results.activation_volume.getVolumeCounts
                if in.single_with_replication
                    replication_points = all_replication_sets{iSet};
                    [stim_level_counts,extras] = act_obj.getVolumeCounts(max_stim_level,...
                        'replication_points',   replication_points,...
                        'stim_resolution',      obj.stim_resolution,...
                        'quick_test',           obj.quick_test);
                else
                    [stim_level_counts,extras] = act_obj.getVolumeCounts(max_stim_level,...
                        'stim_resolution',      obj.stim_resolution,...
                        'quick_test',           obj.quick_test);
                end
                
                
                if ~obj.use_new_solver && obj.merge_solvers
                    xyz = act_obj.getXYZlattice(true);
                    r   = xstim.sim__getSingleAPSolver('solver','from_old_solver');
                    r.solver.sim_logger = act_obj.sim_logger;
                    r.getSolution(xyz);
                    continue
                end
                
                
                
                %Population of result
                %---------------------------------------------------------------
                r = NEURON.reproductions.Hokanson_2013.activation_volume_results;
                
                r.counts = stim_level_counts;
                r.stimulus_amplitudes    = extras.stim_amplitudes;
                r.raw_abs_thresholds     = extras.raw_abs_thresholds;
                
                r.internode_length       = internode_length;
                r.z_saturation_amplitude = extras.z_saturation_threshold;
                r.xyz_used               = extras.xyz_cell;
                
                
                r.slice = NEURON.reproductions.Hokanson_2013.activation_volume_slice(...
                    act_obj,max_stim_level,xyz_info,slice_dim,obj.slice_value);
                
                if in.single_with_replication
                    r.replicated_slice =  NEURON.reproductions.Hokanson_2013.activation_volume_slice(...
                        act_obj,max_stim_level,xyz_info,slice_dim,obj.slice_value,...
                        'replication_points',replication_points);
                    r.replicated_thresholds = extras.threshold_extras.replication_extras.electrode_thresholds;
                end

                %Properties of the request
                %-------------------------------------------------------
                r.max_stim_level = max_stim_level;
                r.is_single              = in.single_with_replication;
                if r.is_single
                    %NOTE: Due to the merger, we adjust the z
                    %values so the locations aren't exactly
                    %correct (or rather, don't match up with these values)
                    r.electrode_locations = replication_points;
                else
                    r.electrode_locations = cur_elec_loc;
                end
                r.stim_widths            = obj.stim_widths;
                r.fiber_diameter         = obj.fiber_diameter;
                r.phase_amplitudes       = obj.phase_amplitudes;
                
                if in.single_with_replication
                    rep_extras = extras.threshold_extras.replication_extras;
                    
                    r.overlap_amplitudes     = rep_extras.electrode_interaction_thresholds;
                    r.electrode_z_locations  = rep_extras.electrode_z_locations;
                    r.mean_error             = rep_extras.mean_rep_error;
                end
                
                result_objs{iSet} = r;
            end
            
            if in.single_output && length(result_objs) == 1
                result_objs = result_objs{1};
            end
        end
    end
    
end

