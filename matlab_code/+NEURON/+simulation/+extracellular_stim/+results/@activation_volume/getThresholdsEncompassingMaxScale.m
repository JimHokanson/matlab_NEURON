function thresholds = getThresholdsEncompassingMaxScale(obj,max_stim_level)
%
%   Implementation Note: Call getThresholdsAndBounds instead ...
%
%   thresholds = getThresholdsEncompassingMaxScale(obj,max_stim_level)
%
%Stim Bounds determination
%--------------------------------------------------------------
%This method expands the testing bounds so that the maximum
%stimulus level is encompassed in the threshold solution space.
%
%   INPUTS
%   =======================================================================
%   max_stim_level : signed value, maximum stimulus value to encompass
%           within the solution volume
%
%   FULL PATH:
%   NEURON.simulation.extracellular_stim.results.activation_volume.getThresholdsEncompassingMaxScale


%NEURON.simulation.extracellular_stim.results.activation_volume.adjustBoundsGivenMaxScale
obj.adjustBoundsGivenMaxScale(max_stim_level)

%Retrieval of thresholds
%--------------------------------------------------------------------------

done = false;
while ~done
    
    if isempty(obj.request_handler)
        thresholds = obj.xstim_obj.sim__getThresholdsMulipleLocations(obj.getXYZlattice(true),...
            'threshold_sign',sign(max_stim_level),'initialized_logger',obj.sim_logger);
    else
        r   = obj.request_handler;
        s   = r.getSolution(obj.getXYZlattice(true));
        thresholds = s.thresholds;
    end
    
    %TODO: Implement gradient testing
    
    %   Determine area of large gradient, test maybe 10 - 20 places
    %   see how they compare to interpolation values at those locations
    %   if they are too different, then change scale and rerun
    %
    %   If they are close, then do interpolation and return result
    done = true;
end

obj.cached_threshold_data_present = true;
obj.cached_threshold_data         = thresholds;
obj.cached_max_stim_level    = max_stim_level;
obj.cached_threshold_bounds       = obj.bounds;


%TODO: Could add truncation option here ...
%NM, build as separate method ...

end