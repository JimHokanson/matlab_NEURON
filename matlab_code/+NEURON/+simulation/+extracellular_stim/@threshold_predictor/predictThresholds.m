function predicted_thresholds = predictThresholds(obj,...
            old_indices_use,...
            new_indices_learned,...
            new_indices_predict,...
            new_thresholds_all)
%
%
%
%   NOTE: predicted thresholds should always be positive
%   The calling function will switch signs if needed ...







%new_stimuli,old_stimuli,old_thresholds,threshold_sign)

%NOTE: All input thresholds should be positive
%The precited thresholds will be signed the same
%as the threshold_sign
%stimuli should always be computed so as to be positive ...

n_new_stimuli = length(new_indices_predict);

if isempty(old_indices_use) && isempty(new_indices_learned)
    predicted_thresholds = ones(1,n_new_stimuli);
    return
end

known_inputs = [obj.low_d_old_stimuli(old_indices_use,:); ...
                obj.low_d_new_stimuli(new_indices_learned,:)];
            
known_thresholds = [obj.old_thresholds(old_indices_use) ...
                            new_thresholds_all(new_indices_learned)];           
            
unknown_inputs = obj.low_d_new_stimuli(new_indices_predict,:);


%SOME DEBUGGING CODE
%==========================================================================
% scatter(known_inputs(:,1),known_inputs(:,2),50,known_thresholds,'filled')
% hold on
% plot(unknown_inputs(:,1),unknown_inputs(:,2),'ok')
% hold off

%TODO: How many points are needed for this to work?????

%TODO: Remove this sort, and this silly function
%I could keep my inputs sorted ...
[low_d_old,IA] = unique(low_d_old,'rows');
old_thresholds = old_thresholds(IA);

predicted_thresholds = griddatan(low_d_old,old_thresholds',low_d_new);

I_NaN = find(isnan(predicted_thresholds));

if ~isempty(I_NaN)
    
    ft = 'linearinterp';
    opts = fitoptions( ft );
    opts.Normalize = 'on';
    
    %YIKES: This will also lead to potential duplicates since
    %we are only using two dimensions ...
    
    fitresult = fit(low_d_old(:,1:2), old_thresholds', ft,opts);
    predicted_thresholds(I_NaN) = feval(fitresult,low_d_new(I_NaN,1:2));
    
    I_NaN = find(isnan(predicted_thresholds));
    if ~isempty(I_NaN)
        predicted_thresholds(I_NaN) = threshold_sign;
    end
end


