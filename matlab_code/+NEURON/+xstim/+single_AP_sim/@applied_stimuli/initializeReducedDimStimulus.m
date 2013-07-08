function initializeReducedDimStimulus(obj1,obj2,options)
%
%   initializeReducedDimStimulus(obj1,obj2,options)
%
%   In general this method should be called from the predictor superclass.
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
%   FULL PATH:
%   =======================================================================
%   NEURON.xstim.single_AP_sim.applied_stimuli.initializeReducedDimStimulus
%
%   See Also:
%   NEURON.xstim.single_AP_sim.predictor.initializeLowDStimulus


% % % in.throw_error_on_multiple_calls = true;
% % % in = sl.in.processVarargin(in,varargin);
% % % 
% % % if ~isempty(obj1.low_d_stimulus)
% % %     %NOTE: We might not want to even allow this to run twice ...
% % %     %Might want to pass this in as an error, which can be overwritten
% % %     %TODO: Throw warning indicating this function is being called twice
% % % end


if obj2.n == 0
    [~,scores1,latent] = princomp(obj1.stimulus,'econ');
elseif isempty(obj1)
    error('Only object 2 should be empty')
else
    n1         = obj1.n;
    temp_data  = [obj1.stimulus; obj2.stimulus];
    data_mean  = mean(temp_data,1);
    
    [coeff,~,latent] = princomp(temp_data,'econ');
    
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
if length(latent) < options.MIN_PCA_DIMS_KEEP
    n_dims_keep = length(latent);
else
    
    total_variance = cumsum(latent);
    n_dims_keep = find(total_variance > options.VARIANCE_TO_KEEP,1);
    
    if isempty(n_dims_keep)
        if isempty(latent)
            error('PCA returned no dimensions to keep ~?~?~??~?')
        else
           n_dims_keep = length(latent); 
        end
    end
    
    %This a possible future improvement
    %
    %   TODO: Wrap PCA with object ...
    %
% % %     %NOTE: With this code if length(latent) == 1
% % %     %then I will be empty ...
% % %     csl = cumsum(latent) - latent(1);
% % %     I = find(csl./csl(end) > obj.opt__PCA_THRESHOLD,1);
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