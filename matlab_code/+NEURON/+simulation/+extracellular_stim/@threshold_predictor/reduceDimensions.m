function reduceDimensions(obj)
%reduceDimensions
%
%   reduceDimensions(obj)
%
%   Call this method to reduce the dimensionality of the data
%

if isempty(obj.old_stimuli)
    obj.data_mean = mean(obj.new_stimuli,1);
    
    [obj.coeff,scores_new,latent] = princomp(obj.new_stimuli,'econ');
elseif isempty(obj.new_stimuli)
    obj.data_mean = mean(obj.old_stimuli,1);
    
    [obj.coeff,scores_old,latent] = princomp(obj.old_stimuli,'econ');
else
    n_new = obj.n_new;
    temp_data = [obj.new_stimuli; obj.old_stimuli];
    obj.data_mean = mean(temp_data,1);
    
    [obj.coeff,~,latent] = princomp(temp_data,'econ');
    
    %PCA uses svd which uses an iterative solver meaning that some points
    %which are exactly the same in a high dimensional space will not be
    %exactly the same in the low dimensional space (off by some small percentage).
    %This is currently important because I have yet to implement a loose
    %matching algorithm
    %This can either be fixed by:
    %1) Recomputing scores based on coefficients
    %2) Rounding results to remove insigificant rounding errors
    
    
    temp_data_no_mean = bsxfun(@minus,temp_data,mean(temp_data));
    scores_both = temp_data_no_mean*obj.coeff;
    scores_new  = scores_both(1:n_new,:);
    scores_old  = scores_both(n_new+1:end,:);
    
%     scores_new = round2(scores_both(1:n_new,:),obj.opt__score_rounding_precision);
%     scores_old = round2(scores_both(n_new+1:end,:),obj.opt__score_rounding_precision);
end

%How much should we keep
%--------------------------------------------------------------
if length(latent) < 3
    %TODO: Document this
    obj.n_pcs_keep = length(latent);
else
    %NOTE: With this code if length(latent) == 1
    %then I will be empty ...
    csl = cumsum(latent) - latent(1);
    I = find(csl./csl(end) > obj.opt__PCA_THRESHOLD,1);

    if isempty(I)
        if isempty(latent)
            error('PCA returned no dimensions to keep ~?~?~??~?')
        end 
       I = length(latent);
    end

    obj.n_pcs_keep = I;
end
%Reducing the dimensions
%--------------------------------------------------------------
if ~isempty(obj.new_stimuli)
    obj.low_d_new_stimuli = scores_new(:,1:obj.n_pcs_keep);
end
if ~isempty(obj.old_stimuli)
    obj.low_d_old_stimuli = scores_old(:,1:obj.n_pcs_keep);
end
end