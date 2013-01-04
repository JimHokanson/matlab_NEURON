function predicted_thresholds = predictThresholds(obj,new_stimuli,old_stimuli,old_thresholds,threshold_sign)

%NOTE: All input thresholds should be positive
%The precited thresholds will be signed the same
%as the threshold_sign
%stimuli should always be computed so as to be positive ...

n_new_stimuli = size(new_stimuli,1);

if isempty(old_stimuli)
    predicted_thresholds = threshold_sign*ones(1,n_new_stimuli);
    return
end

[low_d_new,low_d_old] = rereduceDimensions(obj,new_stimuli,old_stimuli);


% scatter(low_d_old(:,1),low_d_old(:,2),50,old_thresholds,'filled')
% hold on
% plot(low_d_new(:,1),low_d_new(:,2),'ok')
% hold off

%TODO: How many points are needed for this to work?????


predicted_thresholds = griddatan(low_d_old,old_thresholds',low_d_new);

I_NaN = find(isnan(predicted_thresholds));

if ~isempty(I_NaN)
    
    ft = 'linearinterp';
    opts = fitoptions( ft );
    opts.Normalize = 'on';
    
    fitresult = fit(low_d_old(:,1:2), old_thresholds', ft,opts);
    predicted_thresholds(I_NaN) = feval(fitresult,low_d_new(I_NaN,1:2));
    
    I_NaN = find(isnan(predicted_thresholds));
    if ~isempty(I_NaN)
        predicted_thresholds(I_NaN) = threshold_sign;
    end
end


