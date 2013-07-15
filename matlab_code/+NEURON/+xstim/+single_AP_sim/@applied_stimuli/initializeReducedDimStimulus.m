function initializeReducedDimStimulus(obj1,obj2,options)
%
%   initializeReducedDimStimulus(obj1,obj2,options)
%
%   The method uses PCA to reduce the # of dimensions in the stimulus for
%   comparison and subsequent prediction.
%   
%   INPUTS
%   =======================================================================
%   obj1    : Instance of this class
%   obj2    : Secondary instance, this can be used when performing
%             dimensionality reduction on both old and new stimuli
%   options : Class: NEURON.xstim.single_AP_sim.dim_reduction_options
%
%   See Also:
%   NEURON.xstim.single_AP_sim.dim_reduction_options
%   NEURON.xstim.single_AP_sim.applied_stimulus_manager.getLowDStimulusInfo
%
%   FULL PATH:
%   NEURON.xstim.single_AP_sim.applied_stimuli.initializeReducedDimStimulus

if obj2.n == 0
    [coeff,~,latent] = pca(obj1.stimulus,'Algorithm','svd','Economy',true);
    data_mean   = mean(obj1.stimulus,1);
    temp_data_no_mean = bsxfun(@minus,obj1.stimulus,data_mean);
    scores1     = temp_data_no_mean*coeff;
elseif obj1.n == 0
    [coeff,~,latent] = pca(obj2.stimulus,'Algorithm','svd','Economy',true);
    data_mean   = mean(obj2.stimulus,1);
    temp_data_no_mean = bsxfun(@minus,obj2.stimulus,data_mean);
    scores2     = temp_data_no_mean*coeff;
else
    n1         = obj1.n;
    temp_data  = [obj1.stimulus; obj2.stimulus];
    data_mean  = mean(temp_data,1);
    
    [coeff,~,latent] = pca(temp_data,'Algorithm','svd','Economy',true);
    
    %PCA uses svd which uses an iterative solver meaning that some points
    %which are exactly the same in a high dimensional space will not be
    %exactly the same in the low dimensional space (off by some small percentage).
    %This is currently important because I have yet to implement a loose
    %matching algorithm
    
    temp_data_no_mean = bsxfun(@minus,temp_data,data_mean);
    scores_both       = temp_data_no_mean*coeff;
    scores1           = scores_both(1:n1,:);
    scores2           = scores_both(n1+1:end,:);
end

%How much should we keep
%--------------------------------------------------------------
if length(latent) <= options.MIN_PCA_DIMS_KEEP
    n_dims_keep = length(latent);
else
    
    total_variance = cumsum(latent);
    
    if strcmp(options.VARIANCE_KEEP_METHOD,'after_first')
       total_variance = total_variance - total_variance(1);
       total_variance = total_variance/total_variance(end);
    end

    n_dims_keep = find(total_variance > options.VARIANCE_TO_KEEP,1);
    
    if isempty(n_dims_keep)
        if isempty(latent)
            error('PCA returned no dimensions to keep ~?~?~??~?')
        else
           n_dims_keep = length(latent); 
        end
    end
end

%Reducing the dimensions
%--------------------------------------------------------------
if obj1.n ~= 0
    obj1.low_d_stimulus = scores1(:,1:n_dims_keep);
end
if obj2.n ~= 0
    obj2.low_d_stimulus = scores2(:,1:n_dims_keep);
end

end