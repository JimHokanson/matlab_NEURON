classdef activation_volume < handle
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.results.activation_volume
    %
    %   TODO: Summarize purpose of this class
    
    
    %METHODS IN OTHER FILES  %=============================================
    %adjustBoundsGivenMaxScale
    %checkBounds
    
    %HELPER METHODS IN OTHER FILES
    %======================================================================
    methods (Hidden)
        adjustBoundsGivenMaxScale(obj,max_scale,varargin)
    end
    
    
    %REFERENCE OBJECTS ====================================================
    properties (Hidden)
        xstim_obj  %
        sim_logger
    end
    
%     properties (Hidden)
%         thresholds
%         threshold_bounds
%     end
    
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
        function obj = activation_volume(xstim_obj)
            
            obj.xstim_obj  = xstim_obj;
            obj.sim_logger = xstim_obj.sim__getLogInfo;
            
            
            %Population of bounds
            %--------------------------------------------------------------
            elec_objs = xstim_obj.elec_objs;
            
            all_elec_locations = vertcat(elec_objs.xyz);
            
            obj.bounds = [min(all_elec_locations,[],1); ...
                max(all_elec_locations,[],1)];
            
            
            if obj.spacing_model == 1
                obj.bounds(1,1:2)  = round2(obj.bounds(1,1:2) - obj.start_width,obj.step_size,@floor);
                obj.bounds(2,1:2)  = round2(obj.bounds(2,1:2) + obj.start_width,obj.step_size,@ceil);
                
                %Updating z to completely encompass the axon ...
                z_distance_spanned = obj.bounds(2,3) - obj.bounds(1,3);
                extra_spacing      = (obj.getInternodeLength - z_distance_spanned)/2;
                obj.bounds(1,3)    = round2(obj.bounds(1,3) - extra_spacing,obj.step_size,@floor);
                obj.bounds(2,3)    = round2(obj.bounds(2,3) + extra_spacing,obj.step_size,@ceil);
                
            else
                error('Only spacing model #1 is implemented')
            end
            
        end
        function [slice_thresholds,xyz_new] = getSliceThresholds(obj,max_stim_level,dim_use,dim_value)
           %
           %
           %    NOTE: This could be sped up ...
           
           thresholds = getThresholdsEncompassingMaxScale(obj,max_stim_level);
           xyz        = obj.getXYZlattice(true);
           
           dim_use = arrayfcns.xyz.getNumericDim(dim_use);
           
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
        function thresholds = getThresholdsEncompassingMaxScale(obj,max_stim_level)
            %Stim Bounds determination
            %--------------------------------------------------------------------------
            %This method expands the testing bounds so that the maximum stimulus level
            %is encompassed in the threshold solution space.
            
            %NEURON.simulation.extracellular_stim.results.activation_volume.adjustBoundsGivenMaxScale
            obj.adjustBoundsGivenMaxScale(max_stim_level)
            
            %Retrieval of thresholds
            %--------------------------------------------------------------------------
            
            done = false;
            while ~done
                
                thresholds = obj.xstim_obj.sim__getThresholdsMulipleLocations(obj.getXYZlattice(true),...
                    'threshold_sign',sign(max_stim_level),'initialized_logger',obj.sim_logger);
                
                %TODO: Implement gradient testing
                
                %   Determine area of large gradient, test maybe 10 - 20 places
                %   see how they compare to interpolation values at those locations
                %   if they are too different, then change scale and rerun
                %
                %   If they are close, then do interpolation and return result
                done = true;
            end
            
            %TODO: Could add truncation option here ...
            %NM, build as separate method ...
            
        end
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
                obj.bounds(bound_index) = round2(new_value,obj.step_size,@ceil);
            else
                obj.bounds(bound_index) = round2(new_value,obj.step_size,@floor);
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
            %    CALLING FORMS
            %    ===========================================================
            %    [x,y,z]   = getXYZlattice(obj,false)
            %
            %    [{x,y,z}] = getXYZlattice(obj,true)
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

