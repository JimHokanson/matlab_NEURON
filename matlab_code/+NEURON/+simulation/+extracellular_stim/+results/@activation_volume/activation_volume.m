classdef activation_volume < handle
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.results.activation_volume
    %
    %   This class is meant to handle analyis of activation volumes.
    %
    %   Improvements. The design of this class needs to be significantly
    %   changed. The biggest problem is the non-static nature of the
    %   result and the inclusion of replicated data with non-replicated
    %   data.
        
    %HELPER METHODS IN OTHER FILES
    %======================================================================
    methods (Hidden)
        adjustBoundsGivenMaxScale(obj,max_scale,varargin)
    end

    %REFERENCE OBJECTS ====================================================
    properties (Hidden)
        xstim_obj  %
        
        %Known calls to solvers ...
        %------------------------------------------------------------------
        %NEURON.simulation.extracellular_stim.results.activation_volume.checkBounds
        %NEURON.simulation.extracellular_stim.results.activation_volume.getThresholdsEncompassingMaxScale
        sim_logger
        request_handler
    end
    
    properties (Hidden)
        %.getThresholdsEncompassingMaxScale()
        %------------------------------------------------------------------
        cached_threshold_data_present = false
        cached_threshold_data       
        cached_max_stim_level = 0
        cached_threshold_bounds
    end
    
    %OPTIONS  =============================================================
    properties
        start_width   = 100
        step_size     = 20
        spacing_model = 1 %Currently only one value is valid
        %Use this to ensure a proper range of values
        %1 - indicates axon type model
        %
        %   TODO: Increase documentation on this model ...
    end
    
    properties
        bounds = [] % [min x xyz; max x xyz]
        %This property is initialized in the constructor
    end

    methods
        function obj = activation_volume(xstim,varargin)
            %
            %
            
            in.request_handler = [];
            in = NEURON.sl.in.processVarargin(in,varargin);
            
            obj.request_handler = in.request_handler;
            
            
            obj.xstim_obj  = xstim;
            
            %This is a call to get the logged data ...
            %This is getting really slow ...
            if isempty(in.request_handler)
                obj.sim_logger = xstim.sim__getLogInfo;
            end
            
            %Population of bounds
            %--------------------------------------------------------------
            elec_objs = xstim.elec_objs;
            
            all_elec_locations = vertcat(elec_objs.xyz);
            
            obj.bounds = [min(all_elec_locations,[],1); ...
                max(all_elec_locations,[],1)];
            
            
            if obj.spacing_model == 1
                
                step_sz_local = obj.step_size;
                
                rf = @(x) NEURON.sl.array.roundToPrecision(x,step_sz_local,@floor);
                rc = @(x) NEURON.sl.array.roundToPrecision(x,step_sz_local,@ceil);
                
                
                %Round x & y mins down
                %----------------------------------------------------------
                obj.bounds(1,1:2)  = rf(obj.bounds(1,1:2) - obj.start_width);
                
                %Round x & y max values up
                %----------------------------------------------------------
                obj.bounds(2,1:2)  = rc(obj.bounds(2,1:2) + obj.start_width);
                
                half_INL = obj.getInternodeLength/2;
                
                obj.bounds(1,3)    = rf(-half_INL);
                obj.bounds(2,3)    = rc(half_INL);
            else
                error('Only spacing model #1 is implemented')
            end
            
        end
        function [slice_thresholds,xyz_new] = getSliceThresholds(obj,max_stim_level,dim_use,dim_value,varargin)
           %getSliceThresholds  Retrieves thresholds for a 2d plane
           %
           %    [slice_thresholds,xyz_new] = getSliceThresholds(obj,max_stim_level,dim_use,dim_value,varargin)
           %
           %    Specify the singular dimension and the value of that
           %    dimension to examine for the other 2 dimensions.
           %
           %    OUTPUTS
           %    ===========================================================
           %    slice_thresholds :
           %    xyz_new :
           %
           %    INPUTS
           %    ===========================================================
           %    max_stim_level :
           %    dim_use   :
           %    dim_value : Singular value of specified dimension in which
           %                to retrieve thresholds.
           %    
           %    OPTIONAL INPUTS
           %    ===========================================================
           %    For the following see:
           %    .getThresholdsAndBounds()
           %    replication_points : default []
           %    replication_center : default [0 0 0]
           %
           %
           %    EXAMPLE
           %    ===========================================================
           %    [slice_thresholds,xyz_new] = getSliceThresholds(obj,max_stim_level,dim_use,dim_value,varargin)
           %
           %    FULL PATH:
           %    NEURON.simulation.extracellular_stim.results.activation_volume.getSliceThresholds
           
           in.replication_points = [];
           in = NEURON.sl.in.processVarargin(in,varargin);
           
           %thresholds = getThresholdsEncompassingMaxScale(obj,max_stim_level);
           
           [thresholds,x,y,z] = obj.getThresholdsAndBounds(max_stim_level,in.replication_points);
           
           xyz = {x,y,z};
           
           %xyz        = obj.getXYZlattice(true);
           
           dim_use = NEURON.sl.xyz.getNumericDim(dim_use);
           
           xyz_new = cell(1,3);
           for iXYZ = 1:3
               cur_old_value = xyz{iXYZ};
               if iXYZ == dim_use
                   %TODO: Ensure value is within extremes
                   xyz_new{iXYZ} = dim_value;
               else
                   xyz_new{iXYZ} = cur_old_value(1):cur_old_value(end);
               end
           end
           
           slice_thresholds = interpn(xyz{:},thresholds,xyz_new{:});
           
        end
        function internode_length = getInternodeLength(obj)
            %getInternodeLength
            %
            %    internode_length = getInternodeLength(obj)
            %
            
            if obj.spacing_model == 1
                
                %Known implementations:
                %--------------------------------------------------------
                %NEURON.cell.axon.MRG.getAverageNodeSpacing
                internode_length = obj.xstim_obj.cell_obj.getAverageNodeSpacing;
            else
                error('Internode length should only be requested for spacing model 1')
            end
        end
    end
    
    %THRESHOLD DATA METHODS  %=============================================
    methods

    end
    
    
    %BOUND METHODS   %=====================================================
    methods (Hidden)
        function growBounds(obj,bound_indices)
            n_indices = length(bound_indices);
            for iIndex = 1:n_indices
                cur_index = bound_indices(iIndex);
                if mod(cur_index,2) == 0
                    obj.bounds(cur_index) = obj.bounds(cur_index) + obj.step_size;
                else
                    obj.bounds(cur_index) = obj.bounds(cur_index) - obj.step_size;
                end
            end
        end
        
        %TODO: Rename to growBoundByValue
        %
        %   - this implies that we care about the direction, and that it is
        %   growing, which allows us to do an error check on that fact
        %
        function setBoundValue(obj,bound_index,new_value)
            %TODO: Add on some check that things haven't flipped
            %i.e. that I didn't go from -300 to 350
            %
            %I had pchip interpolation and it made my positive bound negative
            %and my negative bound positive
            if mod(bound_index,2) == 0
                obj.bounds(bound_index) = NEURON.sl.array.roundToPrecision(new_value,obj.step_size,@ceil);
            else
                obj.bounds(bound_index) = NEURON.sl.array.roundToPrecision(new_value,obj.step_size,@floor);
            end
        end
    end
    
    %BOUND METHODS CONTINUED  %============================================
    methods
        function str = getBoundsString(obj)
            temp = num2cell(obj.bounds(:));
            str = sprintf('x: [%d %d], y: [%d %d], z: [%d %d]',temp{:});
        end
        function dispBounds(obj)
            fprintf('Current volume bounds: %s\n',obj.getBoundsString);
        end
        function varargout = getXYZlattice(obj,as_cell)
            %getXYZlattice
            %
            %   varargout = getXYZlattice(obj,*as_cell)
            %
            %   Returns vectors for each of the dimensions based on the
            %   bounds and the step size.
            %
            %   INPUTS
            %   ===========================================================
            %   as_cell : (default false), changes output type, see
            %           varargout
            %
            %   OUTPUTS
            %   ===========================================================
            %   varargout :
            %       'as_cell' = true
            %           - returns a single cell array => [{x,y,z}]
            %       'as_cell' = false
            %           - returns each dimension as an output => [x,y,z]
            %           
            
            if ~exist('as_cell','var')
                as_cell = false;
            end
            
            x = obj.bounds(1,1):obj.step_size:obj.bounds(2,1);
            y = obj.bounds(1,2):obj.step_size:obj.bounds(2,2);
            z = obj.bounds(1,3):obj.step_size:obj.bounds(2,3);
            
            if as_cell
                varargout{1} = {x y z};
            else
                varargout{1} = x;
                varargout{2} = y;
                varargout{3} = z;
            end
        end
    end
    
    
    
end

