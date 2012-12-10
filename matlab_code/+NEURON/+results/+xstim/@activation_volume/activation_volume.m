classdef activation_volume < handle
    %
    %   Class: NEURON.results.xstim.activation_volume
    %
    %   USAGE
    %   =============================================================
    %   This class requires a fully defined extracellular stimulation
    %   class to be defined.
    %   
    %
    %
    %   CURRENT VERSION: 1
    %   No previous versions exist
    %
    %IMPROVEMENTS
    %=============================================================
    %1) Allow variation in # of grid points per dimension, currently
    %   everything is done with equal # of points per dimension
    %
    %
    %
    
    %QUESTIONS
    %================================================================
    %What if something crashes ...
    
    %OUTPUT FUNCTIONS
    %================================================================
    %plot threshold planes (with electrodes)
    
    %FEATURES
    %================================================================
    %Auto complete on failure, go back to last successful step ...
    
    %METHODS IN OTHER FILES
    %================================================================
    %   NEURON.results.xstim.activation_volume.determineStepSize
    %   NEURON.results.xstim.activation_volume.solveVolume
    %   NEURON.results.xstim.activation_volume.populateVolumeCounts
    %   NEURON.results.xstim.activation_volume.getPlaneData
    
    
    %TODO
    %================================================================
    %   - build in symettry tester ... => based on applied voltage
    %   - allow expansion of bounds if thresholds are not high enough
    %   - allow 2d or 1d based on bounds being equal ...
    
    properties
       VERSION = 1
       xstim_obj
       thresh_matrix  %matrix of values equally spaced in x,y,z of threshold values

       
       
       file_save_path
       
       %solveVolume debug stuff 
       n_loops_linear
       threshold_error
    end

    properties
       stim_levels_for_counts 
       stim_counts_populated = false
    end
    
    properties (Hidden)
       %Build retrieval functions around this ...
       stim_counts_xy   %(x,y,nstim tested) 
       %NOTE: With this we can test for bounds saturation
       
    end
    
    properties 
       %.determineStepSize()
       opt__step_size_voltage_accuracy = 0.99; %NOTE: Due to the way this works this needs to be pretty tight ...
                %I think, but I haven't tested it fully enough to know for sure
    end
    
    properties
       
       %.determineStepSize()
       n_points_side 
       n_points_total
       
       %.solveVolume()
       finished  %When done given params, set this to true
                 %Do partial saves during simulation to allow saving state
                 %and returning to where we were before ...
       last_run_index = 0
       run_order
       X_field
    end
    
    properties 
       %FOR NOW:
       %Assume symmetry based on 0 based bounds
       %i.e. if we only go from 0 to 500 in z, we can assume z-symetric
       %For symmetry always provide positive axis PLEASE!
       %[min max]
       x_bounds  
       y_bounds
       z_bounds
       
       %NOTE: Each of these must be evenly spaced for interpolation
       %The step size can, and generally does vary, between them
       x_solution
       y_solution
       z_solution
    end
    
    properties (Dependent)
       elec_objs 
       all_bounds
    end
    
    methods 
        function value = get.all_bounds(obj)
           value = zeros(3,2);
           value(1,:) = obj.x_bounds;
           value(2,:) = obj.y_bounds;
           value(3,:) = obj.z_bounds;
        end
    end
    
    properties (Hidden)
        
    end
    
    methods (Static)
        function obj = get(xstim_obj,file_save_path,x_bounds,y_bounds,z_bounds)
            %
            %
            %   NEURON.results.xstim.activation_volume.get(xstim_obj,file_save_path,x_bounds,y_bounds,z_bounds)
            
           %NOTE: On loading will need to replace
           %the .xstim_obj with the version passed in ...
           if exist(file_save_path,'file')
              obj = load2(file_save_path,'obj');
              obj.xstim_obj = xstim_obj;
              obj.file_save_path = file_save_path; %In case we've switched machines ...
              
              %TODO: Build in version handling here ...
              
              
              if ~obj.finished
                 resumeSolvingVolume(obj)
              end
              return
           end
           
           obj = NEURON.results.xstim.activation_volume(xstim_obj,file_save_path,x_bounds,y_bounds,z_bounds);
           
        end
    end
    
    methods
        function obj = activation_volume(xstim_obj,file_save_path,x_bounds,y_bounds,z_bounds)
           obj.x_bounds       = x_bounds;
           obj.y_bounds       = y_bounds;
           obj.z_bounds       = z_bounds;
           obj.xstim_obj      = xstim_obj;
           obj.file_save_path = file_save_path;
           
           xstim_obj.ev_man_obj.initSystem();
           
           determineStepSize(obj)
           init_thresh_matrix(obj)
           solveVolume(obj)
        end
        function init_thresh_matrix(obj)
           obj.finished = false; 
           obj.thresh_matrix   = zeros(obj.n_points_side*ones(1,3)); %:/, looks a bit funny eh?
           obj.n_loops_linear  = zeros(1,obj.n_points_total);
           obj.threshold_error = zeros(1,obj.n_points_total);
        end
        function resumeSolvingVolume(obj)
           %
           %    Call this when something causes everything to crash ...
           keyboard
           error('Not yet implemented')
        end
        function [x,y,z] = getXYZ(obj,nPoints)
           %Helper function for:
           %    solveVolume
           x = linspace(obj.x_bounds(1),obj.x_bounds(2),nPoints);
           y = linspace(obj.y_bounds(1),obj.y_bounds(2),nPoints);
           z = linspace(obj.z_bounds(1),obj.z_bounds(2),nPoints); 
        end
        function saveObject(obj)
           xstim_obj_local = obj.xstim_obj;
           obj.xstim_obj = [];
           save(obj.file_save_path,'obj')
           obj.xstim_obj = xstim_obj_local; 
        end
        function [stim_count,stim_level] = getStimCounts(obj,varargin)
           
           in.return_averaged = true;
           in = processVarargin(in,varargin);
            
           if isempty(obj.stim_counts_xy)
              error('Populate Volume Counts needs to be called first')
           end 
           stim_level = obj.stim_levels_for_counts;
           stim_count = getStimXY_completeBounds(obj);
           if in.return_averaged
              stim_count = sum(sum(stim_count,1),2); 
           end
           
        end

    end
    
    methods (Hidden)
        function stim_xy_complete = getStimXY_completeBounds(obj)
           
           if isempty(obj.stim_counts_xy)
              error('Populate Volume Counts needs to be called first')
           end 
            
           stim_xy_complete = obj.stim_counts_xy;
           if obj.x_bounds(1) == 0
              stim_xy_complete = cat(1,flipdim(stim_xy_complete,1),stim_xy_complete); 
           end
           
           if obj.y_bounds(1) == 0
              stim_xy_complete = cat(2,flipdim(stim_xy_complete,2),stim_xy_complete);  
           end
        end 
    end
    
    
end

