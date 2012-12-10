function solveVolume(obj)
%
%
%
%   IMPROVEMENT:
%   ==============================================
%   Based on cell type would determine max time for AP propogation ...
%
%%Improvements
% - over or under guess on purpose instead of shooting for exact this
% should lead to more accurate results for example with a value of 15 and a
% final accuracy of 0.1 as well as a
%   guess rate of the same size if we start with 14.99 then go to 15.09,
%   we'll settle on a threshold of 15.04 if instead we went for 14.94, we'd
%   end up with a threshold of 14.99 which is closer to the true threshold
%   of 15
% - don't allow the guess rate to get below some fraction of the
%   final accuracy, probaly equal to the final accuracy would be best
% - clean up what we hold on to
% - better initial guess support

MAX_RANDOM_STEP = 0.1;

%Some initial setup stuff
%=======================================================
next_stim_start_guess = -5; %NOTE: I really need to pass this in ...

default_guess = next_stim_start_guess;
starting_sign = sign(next_stim_start_guess);

%ONLY NEEDS TO BE DONE ONCE ...
%NOTE: Need x,y,z later though ...
[x,y,z] = getXYZ(obj,obj.n_points_side); %NOTE: x,y,&z are vectors, not matrices

obj.x_solution = x;
obj.y_solution = y;
obj.z_solution = z;

xstim_obj_local = obj.xstim_obj;
t_obj           = xstim_obj_local.threshold_cmd_obj;  %(Class

[second_diff,max_applied_voltage] = helper__getStatistics(obj,x,y,z);
X_field = [second_diff(:) 1./max_applied_voltage(:)]; %NOTE: The inversion of the max applied voltage seems to give a smoother surface

run_order = helper__getSolveOrder(obj,X_field);
%================================================================

obj.X_field   = X_field;
obj.run_order = run_order;


[uRun,uRunI_ca] = unique2(run_order);

ft = 'linearinterp';
opts = fitoptions( ft );
opts.Normalize = 'on';


%RUNNING THROUGH AND SOLVING
%=====================================================================
final_size = size(obj.thresh_matrix);
rc = 0;
NaN_found = false;

%Still not yet implemented
%start_index = obj.last_run_index;

h = waitbar(0,'Initializing waitbar...');
for iRun = 1:length(uRun)
    indices_run = uRunI_ca{iRun};
    
    %Interpolation
    %---------------------------------------------------------------------
    %Once we've run things once, we can do interpolation to provide better
    %starting values ...
    if iRun > 1
        done_data_mask = run_order < iRun;
        %Should test 'nearest as well'
        
        fitresult = fit(X_field(done_data_mask,:), obj.thresh_matrix(done_data_mask(:)), ft,opts);
        new_stim_guesses_all = feval(fitresult,X_field(indices_run,:));
        %Make sure no NaN and sign changes ...
        new_stim_guesses_all(isnan(new_stim_guesses_all) | sign(new_stim_guesses_all) ~= starting_sign) = default_guess;
    end
    
    %Solving
    %----------------------------------------------------------------------
    %NOTE: For each run we test a grid of points that are a little denser
    %than the previous run. On the final run we just test all remaining
    %points. See helper__getSolveOrder for details ...
    tic
    rc_start_loop = rc;
    for iIndex = 1:length(indices_run)
        cur_index = indices_run(iIndex);
        
        [iX,iY,iZ] = ind2sub(final_size,cur_index);
        cur_xyz = [x(iX) y(iY) z(iZ)];
        moveCenter(xstim_obj_local.cell_obj,cur_xyz);
        
        %These are defined after the first run
        if iRun > 1
            next_stim_start_guess = new_stim_guesses_all(iIndex);
        end
        
        %The actual threshold detection
        %METHOD: NEURON.simulation.extracellular_stim.sim__determine_threshold
        [last_threshold,nloops]      = sim__determine_threshold(xstim_obj_local,next_stim_start_guess);
        obj.thresh_matrix(cur_index) = last_threshold;
        
        %Code below can be used for manual interogation ...
        %[apFired,extras] = sim__single_stim(obj.xstim_obj,-8,'save_data',true,'complicated_analysis',true)
        
        %DEBUG LOGGING
        if ~isnan(last_threshold)
            rc = rc + 1;
            obj.n_loops_linear(rc)  = nloops;
            obj.threshold_error(rc) = abs(next_stim_start_guess - last_threshold);
        else
            NaN_found = true;
        end
        
        perc = iIndex/length(indices_run);
        waitbar(iIndex/length(indices_run),h,sprintf('%d%% along...',round(perc*100)))
        
    end
    
    %MESSY STUFF, SHOULD BE CLEANED UP
    %-------------------------------------------------------------------
    fprintf('run %d/%d completed\n',iRun,length(uRun));
    
    avg_error_last_loop = mean(obj.threshold_error(rc_start_loop+1:rc));
    %NOTE: Could do a weight or error based on location ...
    
    if avg_error_last_loop < 0.5*t_obj.threshold_accuracy
        %We don't need to be that accurate ...
        t_obj.guess_amount = 0.5*t_obj.threshold_accuracy;
    else
        t_obj.guess_amount = avg_error_last_loop;
    end
    
    obj.last_run_index = iRun;
    
    t_toc = toc;
    fprintf('Total Time: %g, time per sim: %g\n',t_toc,t_toc/length(indices_run))
    saveObject(obj)
end

if NaN_found
    %Save NaN indices
    %Interpolate
    
    %CODE IS MEANT TO HANDLE:
    %- electrodes close to node - essentially 0 threshold
    %- node close to bipolar electrode field split, threshold infinite but
    %only in numerical sense, just use neighboring value
    %    - note, this latter case might skew interpolation ...
    
    
    I_NAN = find(isnan(obj.thresh_matrix));
    for iFix = 1:length(I_NAN)
        cur_index = I_NAN(iFix);
        [iX,iY,iZ] = ind2sub(final_size,I_NAN(iFix));
        cur_xyz = [x(iX) y(iY) z(iZ)];
        cur_xyz = cur_xyz - 0.5*MAX_RANDOM_STEP + rand(1,3)*MAX_RANDOM_STEP;
        moveCenter(xstim_obj_local.cell_obj,cur_xyz);
        
        %
        
        %Test small first ...
        %NEED TO FIX THIS CODE ...
        [apFired,extras] = sim__single_stim(obj.xstim_obj,starting_sign*0.1,'save_data',false,'complicated_analysis',true);
        %NOTE: Need to handle case in which we allow flipping of sign ...
        if apFired
            %Might be apFired == 2, that's fine ...
            %Assume for interpolation purposes threshold is zero, might be
            %some small value but the value is essentially zero for
            %interpolation purposes ...
            obj.thresh_matrix(cur_index) = 0;
        else
            [last_threshold,nloops] = sim__determine_threshold(xstim_obj_local,default_guess);
            %             if apFired ~= 1
            %                 error('Unable to find threshold for point, see code')
            %             else
            obj.thresh_matrix(cur_index) = last_threshold;
            %             end
        end
    end
    
    if ~isempty(find(any(isnan(obj.thresh_matrix(:)))))
        error('NaN values still remain after trying to fix things')
    end
    
end

obj.finished = true;
saveObject(obj)



end

function [second_diff,max_applied_voltage] = helper__getStatistics(obj,x,y,z)
%
%
%   TODO: Document function
%
%

xstim_obj_local = obj.xstim_obj;

MAX_NODE_SHIFT = 1; %Closest node will either be center or next node

node_shifts       = -1*MAX_NODE_SHIFT-1:MAX_NODE_SHIFT+1;
nPlaces           = length(node_shifts);
all_node_voltages = cell(1,nPlaces); %
node_spacing      = getNodeSpacing(xstim_obj_local.cell_obj);

%JAH TODO: Ensure that we cover the node spacing in our testing??
%place = shifts in the node from the center node to neighboring nodes ...
for iPlace = 1:nPlaces
    temp = compute__potential_matrix(xstim_obj_local,x,y,z+node_shifts(iPlace)*node_spacing);
    
    %NOTE: Might want to do max(temp,[],4) instead ...
    
    %I might be having a brain fart here but I want to keep
    %sign and get max absolute value at the same time ...
    all_max = max(temp,[],4);
    all_min = min(temp,[],4);
    mask = abs(all_min) > all_max; %Find out where the negative magnitude is actually greater ...
    all_max(mask) = all_min(mask); 
    
    all_node_voltages{iPlace} = all_max;
    %all_node_voltages{iPlace} = squeeze(temp(:,:,:,1)); %NOTE: This 1 signifies to use the 
    %first stimulation value, this might not be valid ...
end

%Now we need to find which one is the strongest then use the 2nd diff
sz    = size(temp);
if length(sz) == 4
    sz(4) = []; %Remove variation in stim dimension
end
max_applied_voltage = zeros(sz);
index_max           = zeros(sz);
for iPlace = 2:nPlaces-1
    mask                      = abs(all_node_voltages{iPlace}) > abs(max_applied_voltage);
    index_max(mask)           = iPlace;
    max_applied_voltage(mask) = all_node_voltages{iPlace}(mask);  %NOTE: We'll use this later don't change the sign ...
end

second_diff = zeros(sz);
for iPlace = 2:nPlaces-1
    mask =  index_max == iPlace;
    second_diff(mask) = all_node_voltages{iPlace+1}(mask) - 2*all_node_voltages{iPlace+1}(mask) + all_node_voltages{iPlace-1}(mask);
end

end

function run_order = helper__getSolveOrder(obj,X_field)
%
%
%IMPROVEMENTS:
%================================================
%1) DONE The knnsearch is redundant as grid spacing gets finer
%       i.e. some of the same points exist for 5 & 7, could remove redundant
%       points to make knnsearch go quicker ...
%2) We are starting fresh on every single search, might be able to do
%   something recursively here ...
%
%   ALGORITHM
%   ======================================================
%   We are working in a two dimensional field:
%   JAH TODO FINISH DOCUMENTATION

%Do everything in odds
%Then we can more easily divide, and remove duplicates ...

%FIX THIS LATER, ARG ...
n_points_total = obj.n_points_total;
n_points_side  = sqrt(n_points_total);
log_2_result   = ceil(log2(n_points_side));
n_points_side_use = 1 + 2^log_2_result; %Note

x_range = [min(X_field(:,1)) max(X_field(:,1))];
y_range = [min(X_field(:,2)) max(X_field(:,2))];
xlin = linspace(x_range(1),x_range(2),n_points_side_use);
ylin = linspace(y_range(1),y_range(2),n_points_side_use);

[xg,yg] = meshgrid(xlin,ylin);
idx = knnsearch(X_field,[xg(:) yg(:)]);

grid_size = size(xg);

max_step_size = 2^(log_2_result-1);
step_sizes = [2.^(1:(log_2_result-1)) max_step_size];
step_sizes = step_sizes(end:-1:1);

% % % indices_all = zeros(grid_size);
% % % %indices_all(:) = 1:numel(indices_all);
% % % %start 1,
% % % nSteps = length(step_sizes);
% % % start_index = 1;
% % % for iStep = 1:nSteps
% % %    cur_step_size = step_sizes(iStep);
% % %    temp_indices = start_index:cur_step_size:n_points_side_use;
% % %    indices_all(temp_indices,temp_indices) = iStep;
% % %    if iStep ~= nSteps
% % %        start_index = 1 + step_sizes(iStep+1)/2;
% % %    end
% % % end

%idx - might want to resize to be square

nSteps = length(step_sizes);
start_index = 1;

run_order = zeros(1,obj.n_points_total); %
set_mask  = false(1,obj.n_points_total);
for iStep = 1:nSteps
    cur_step_size = step_sizes(iStep);
    
    temp_indices = start_index:cur_step_size:n_points_side_use;
    [xg,yg] = meshgrid(temp_indices,temp_indices);
    I_use = sub2ind(grid_size,xg(:),yg(:));
    
    idx_temp = idx(I_use);
    idx_temp(set_mask(idx_temp)) = []; %Remove values that have already been matched
    run_order(idx_temp) = iStep;
    
    set_mask = run_order ~= 0;  %Update which values have been set and which haven't
    
% % %        scatter(X_field(set_mask,1),X_field(set_mask,2),100,run_order(set_mask),'filled')
% % %        title(sprintf('points grid: %d',numel(xg)))
% % %        pause
    
    if iStep ~= nSteps
        start_index = 1 + step_sizes(iStep+1)/2;
    end
end

run_order(~set_mask) = iStep + 1;


%OLD CODE: REMOVE AFTER SVN COMMIT
% % % % % N_POINTS_GRID_SIZE_START = 5;
% % % % % SEARCH_INCREMENT         = 25;
% % % % % STOP_PERCENTAGE = 0.2;
% % % % % 
% % % % % x_range = [min(X_field(:,1)) max(X_field(:,1))];
% % % % % y_range = [min(X_field(:,2)) max(X_field(:,2))];
% % % % % 
% % % % % run_order = zeros(1,obj.n_points_total); %
% % % % % set_mask  = false(1,obj.n_points_total); %Whether or not a point has been assigned to a run yet
% % % % % 
% % % % % cur_points_on_grid_side = N_POINTS_GRID_SIZE_START;
% % % % % cur_run_num = 1;
% % % % % done = false;
% % % % % while ~done
% % % % %     xlin = linspace(x_range(1),x_range(2),cur_points_on_grid_side);
% % % % %     ylin = linspace(y_range(1),y_range(2),cur_points_on_grid_side);
% % % % %     %run 1, 0 0.5 1
% % % % %     %run 2, 0 0.25 0.5 0.75 1  %NOTE duplication, we remove that below
% % % % %     if cur_run_num ~= 1
% % % % %         xlin(1:2:end) = [];
% % % % %         ylin(2:2:end) = [];
% % % % %     end
% % % % %     [xg,yg] = meshgrid(xlin,ylin);
% % % % %     cur_points_on_grid_side = cur_points_on_grid_side + 2;
% % % % %     
% % % % %     idx = knnsearch(X_field,[xg(:) yg(:)]);
% % % % %     idx(set_mask(idx)) = []; %Remove values that have already been matched
% % % % %     
% % % % %     run_order(idx) = cur_run_num;
% % % % %     cur_run_num    = cur_run_num + 1;
% % % % %     
% % % % %     set_mask = run_order ~= 0;  %Update which values have been set and which haven't
% % % % %     if length(find(set_mask)) > STOP_PERCENTAGE*obj.n_points_total
% % % % %         done = true;
% % % % %     end
% % % % %     %Debugging
% % % % %     % % %    scatter(X_field(set_mask,1),X_field(set_mask,2),100,run_order(set_mask),'filled')
% % % % %     % % %    title(sprintf('points grid: %d',points_grid))
% % % % %     % % %    pause
% % % % % end
% % % % % 
% % % % % %Assign the rest of the points to the final number
% % % % % run_order(~set_mask) = cur_run_num;

end

