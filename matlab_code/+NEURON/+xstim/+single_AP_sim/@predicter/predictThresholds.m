function predicted_thresholds = predictThresholds(obj,new_indices_predict)
%
%
%   predicted_thresholds = predictThresholds(obj,new_indices_predict)
%
%   OLD CODE:
%   NEURON.simulation.extracellular_stim.threshold_predictor.predictThresholds
%
%
%   FULL PATH:
%   NEURON.xstim.single_AP_sim.predicter.predicted_thresholds
%
%   NOTE: This is not actually implemented properly yet ....


%This might become a method - METHOD START
%--------------------------------------------------------------------------
if ~obj.initialized
   obj.initialize(); 
end

n_unknown = length(new_indices_predict);

%NEURON.xstim.single_AP_sim.predicter.getLearnedLowDStimuliAndThresholds
[known_inputs,known_thresholds] = obj.getLearnedLowDStimuliAndThresholds();

%Yikes, ran into the following problem ...
%
%a = [1 5];
%b = 1:10
%c = b(a)
%c = [1 5]

known_thresholds = known_thresholds(:);

n_known    = length(known_thresholds);
dim_inputs = size(known_inputs,2);

if n_known == 0 || n_known < obj.opt__min_prediction_size || n_known < 3*dim_inputs
   predicted_thresholds = obj.getDefaultPrediction(length(new_indices_predict));
   return
end

unknown_inputs = obj.new_low_d_stimulus(new_indices_predict,:);
%--------------------------------------------------------------------------
%                           METHOD END



%These are horrible prediction algorithms but they'll work for now ...
%--------------------------------------------------------------------------

if dim_inputs == 1
    %Do interpolation ...
    [x,I] = sort(known_inputs);
    y = known_thresholds(I);
    %Diff is not-zero, why are these not unique ????
    predicted_thresholds = interp1(x,y,unknown_inputs,'pchip'); %Extrapolation
    %if present turned out to be a bad idea ...
    %We could improve this with a max and min assignment
    %instead of the default ... i.e. assign to min if less than current
    %min or max if greater than current max ...
    
    bad_sign_mask = sign(predicted_thresholds) ~= obj.s.stim_sign;
    if any(bad_sign_mask)
       predicted_thresholds(bad_sign_mask) = obj.getDefaultPrediction(sum(bad_sign_mask)); 
    end
elseif n_known < 5000
    
    %Data can be higly coplanar due to current-distance testing
    %This will cause problems for the convex hull
    try
        predicted_thresholds = griddatan(known_inputs,known_thresholds(:),unknown_inputs);
    catch
        predicted_thresholds = NaN(n_unknown,1);
    end
    
    I_NaN = find(isnan(predicted_thresholds));
    
    if ~isempty(I_NaN)
        
        ft = 'linearinterp';
        opts = fitoptions( ft );
        opts.Normalize = 'on';
        
        %YIKES: This could lead to duplicates as there are
        
        fitresult = fit(known_inputs(:,1:2), known_thresholds(:), ft,opts);
        predicted_thresholds(I_NaN) = feval(fitresult,unknown_inputs(I_NaN,1:2));
        
        I_NaN = find(isnan(predicted_thresholds));
        if ~isempty(I_NaN)
            predicted_thresholds(I_NaN) = obj.getDefaultPrediction(length(I_NaN));
        end
    end
else
    
    %Possible Improvements:
    %1) Use transformed coordinates for averaging ... (low priority)
    
    I_all = randperm(n_known);
    nHalf = floor(n_known/2);
    I_1   = I_all(1:nHalf);
    I_2   = I_all(nHalf+1:end);
    idx   = knnsearch(known_inputs(I_1,:),known_inputs(I_2,:),'k',20);
    thresh_local = known_thresholds(I_1(idx));
    c_thresh_local    = cumsum(thresh_local,2);
    m_thresh_local    = bsxfun(@rdivide,c_thresh_local,1:20);
    thresh_local_diff = bsxfun(@minus,m_thresh_local,known_thresholds(I_2));
    
    avg_error_vs_number_of_nn = mean(abs(thresh_local_diff));
    
    [~,best_n_use] = min(avg_error_vs_number_of_nn);
    
    idx = knnsearch(known_inputs,unknown_inputs,'k',best_n_use);
    
    thresh_old = known_thresholds(idx);
    predicted_thresholds = mean(thresh_old,2);
end

predicted_thresholds = predicted_thresholds(:)';

end

%                           OLD COMMENTS
%==========================================================================


%SOME DEBUGGING CODE
%==========================================================================
% scatter(known_inputs(:,1),known_inputs(:,2),50,known_thresholds,'filled')
% hold on
% plot(unknown_inputs(:,1),unknown_inputs(:,2),'ok')
% hold off

%NOTE: This function works by:
%1) Computing delauny triangulation on known points so as to minimize
%the distance between any new point placed in the space and the distance to
%the known points in an enclosing simplex.
%2) For all new points, it computes barycentric coordinates, which allows
%it to:
%    - deterimine for each new point which simpliex it is is in
%    - compute an interpolated value from the weightings of each simplex
%    point
%NOTE: This method fails if a new point is not in any simplex. Failure to
%be in any simplex could be tested up front by computing convhulln() on the
%old and new points together, and seeing if any of the new points are
%members of the convex hull. For now a NaN check is fine. The up front test
%could be used to learn the convex hull first, and then use this method.
%NOTE: I really dislike this method as it does no smoothing. It also does
%two checks for uniqueness :/

%GRID DATA CRAPS OUT WITH A HIGH # OF SAMPLES

%Distance, difference in thresholds between

% idx = knnsearch(known_inputs,known_inputs,'K',10);
%
% thresh_local = known_thresholds(idx);
% plot(sum(abs(bsxfun(@minus,thresh_local,mean(thresh_local,2))),2))
%
% thresh_diff_avg = mean(abs(bsxfun(@minus,thresh_local,mean(thresh_local,2))),2);

%Do I need to run the grouping algorithm to downsample?
%That approach could likely work ..., although it would be good to use
%thresholding information in the process ...
%
%How about an algorithm which deletes the least useful point, sequentially?


