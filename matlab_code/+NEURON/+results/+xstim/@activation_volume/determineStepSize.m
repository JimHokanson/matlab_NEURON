function determineStepSize(obj)
%
%   
%
%
%Approach, given bounds, keep increasing step size until accuracy
%reaches desired level
%
%Compute applied voltage at set of points
%Interpolate to finer level
%Test difference between values, stop when reaches desired accuracy
%
%
%   More specifically, for a given # of points
%   We interpolate to a denser level
%   We also calculate the potential at the denser level using equations
%   We compare the interpolation to the equations
%   When these are essentially the same, we stop

%Haven't looked at this parameter closely, hopefully this is high enough ...
MAX_APPLIED_STIMULUS = 1000; %For NaN values ...


N_MAX = 1000;

%NOTE: Need method for getting applied voltage in matrix for all time points
%NOTE: Should test for zero stim points - in retrieval method allow filtering ...

%How to handle halving ?????
%Maybe rework in terms of dx??????

nPoints = 3; %Could start out a bit higher ...
done    = false;

[x_new,y_new,z_new] = getXYZ(obj,nPoints);

%NOTE: default method removes zero stimulus times ...
p_mat_new = compute__potential_matrix(obj.xstim_obj,x_new,y_new,z_new);
p_mat_new(isnan(p_mat_new)) = MAX_APPLIED_STIMULUS;

n_stim = size(p_mat_new,4);
p_diff_all = zeros(1,n_stim);
n = 0;
all_diff = zeros(1,1000); %
while ~done
    n = n + 1;
    %What a friggin mess ... :/
    x     = x_new;
    y     = y_new;
    z     = z_new;
    p_mat = p_mat_new;

    nPoints = nPoints + 1;
    [x_new,y_new,z_new] = getXYZ(obj,nPoints);

    p_mat_new = compute__potential_matrix(obj.xstim_obj,x_new,y_new,z_new);
    p_mat_new(isnan(p_mat_new)) = MAX_APPLIED_STIMULUS;
    
    [xi,yi,zi] = meshgrid(x_new,y_new,z_new);
    
    %This is for all time points
    %field may be complex at one time point vs another
    for iStim = 1:n_stim
        cur_stim_mat     = squeeze(p_mat(:,:,:,iStim));
        cur_new_stim_mat = squeeze(p_mat_new(:,:,:,iStim));
        interp_new = interp3(x,y,z,cur_stim_mat,xi,yi,zi,'cubic');
        p_diff_all(iStim) = sum(abs(interp_new(:)-cur_new_stim_mat(:)))./sum(cur_new_stim_mat(:));
    end

    all_diff(n) = mean(p_diff_all);
    
    if mean(p_diff_all) < 1 - obj.opt__step_size_voltage_accuracy
        done = true;
    end

    if n > N_MAX
        error('Loop running more than it should, error likely')
    end
end

%TODO: Fix this code ...
nPoints = nPoints + 2;

obj.n_points_side = nPoints;
obj.n_points_total = nPoints^3;



