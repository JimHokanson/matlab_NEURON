function [min_threshold,all_thresholds] = computeThreshold(obj,xstim,method)

% get fiber diameter, pulse width from xstim
fiber_diameter = xstim.cell_obj.props_obj.fiber_diameter;
stim_timing = xstim.elec_objs(1).stimulus_transition_times;
pulse_width = stim_timing(3) - stim_timing(2);

% get membrane voltage
test_V = obj.computeVoltages(xstim);

if any(test_V > 0)
    error('Unhandled code case of stimuli being positive, we need to filter these out')
    %Anodal stimuli are not supported and the nodes that look like
    %they are primarily getting anodal activaton don't fit in this model
    %
    %#model_limitation
end

% get mdf
if method == 1 % mdf1
    test_MDF = obj.computeMDF1(test_V);
elseif method == 2 % mdf2
    test_MDF = obj.computeMDF2(test_V,pulse_width,fiber_diameter);
else
    error('Invalid option, only 1 & 2 supported')
end


[v,m] = getVM(obj,method,fiber_diameter,pulse_width);

% extend
v_last_val = 1e6;
m_last_val = interp1(v,m,v_last_val,'linear','extrap');
v = [v; v_last_val];
m = [m; m_last_val];

% make lines from test data
test_V = test_V(2:end-1); % cut off ends
scale_factor = 1e6;
x_all = [-scale_factor*test_V(:) scale_factor*test_V(:)];
y_all = [-scale_factor*test_MDF(:) scale_factor*test_MDF(:)];

% use intersections to compute thresholds
all_thresholds = zeros(size(test_V));
tic
for iV = 1:length(test_V)
    [x0,y0] = sigp.intersections(x_all(iV,:),y_all(iV,:),v,m,false);
    if isempty(x0) %slower but more robust approach
        [x0,y0] = sigp.intersections(x_all(iV,:),y_all(iV,:),v,m,true);
        if isempty(x0)
            warning('Intersection not found!')
            x0 = NaN;
        end
    end
    all_thresholds(iV) = x0(1)/test_V(iV); % ratio of V, equivalent to ratio of I
end
toc
pos_thresholds = all_thresholds(all_thresholds > 0);
if ~isempty(pos_thresholds)
    min_threshold = min(pos_thresholds);
elseif all(isnan(all_thresholds))
    min_threshold = NaN;
    if method == 1
        keyboard
    end
else
    warning('negative threshold')
    min_threshold = min(abs(all_thresholds));
    if method == 1
        keyboard
    end
end
end