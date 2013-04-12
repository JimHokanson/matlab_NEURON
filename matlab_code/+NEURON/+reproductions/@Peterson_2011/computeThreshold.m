function thresholds = computeThreshold(obj,xstim,method)

% get fiber diameter, pulse width from xstim
fiber_diameter = xstim.cell_obj.props_obj.fiber_diameter;
stim_timing = xstim.elec_objs(1).stimulus_transition_times;
pulse_width = stim_timing(3) - stim_timing(2);

% get membrane voltage
test_V = obj.compute_voltages(xstim);
% get mdf
if method == 1 % mdf1
    temp = obj.mdf1;
    test_MDF = obj.computeMDF1(test_V);
elseif method == 2 % mdf2
    temp = obj.mdf2;
    test_MDF = obj.computeMDF2(test_V);
else
    error('Invalid option, only 1 & 2 supported')
end

% lookup mdf threshold data
I = find(temp.diameters == fiber_diameter,1);
J = find(temp.pulse_widths == pulse_width,1);
% Ve, MDF
v = temp.ve{I,J};
m = temp.mdf{I,J};

% simplify and sort
simp = sigp.dpsimplify([v(:) m(:)],eps);
v = simp(:,1);
m = simp(:,2);
[v,I] = sort(v);
m = m(I);

% extend
v_last_val = 1e4;
m_last_val = interp1(v,m,v_last_val,'linear','extrap');
v = [v; v_last_val];
m = [m; m_last_val];

% make lines from test data
x_all = [-1*test_V(:) 10000*test_V(:)];
y_all = [-1*test_MDF(:) 10000*test_MDF(:)];

% use intersections to compute thresholds
thresholds = zeros(length(test_V),length(test_MDF));
tic
for iV = 1:length(test_V)
    for iM = 1:length(test_MDF)
        [x0,y0] = sigp.intersections(x_all(iV,:),y_all(iM,:),v,m,false);
        if isempty(x0) %slower but more robust approach
          [x0,y0] = sigp.intersections(x_all(iV,:),y_all(iM,:),v,m,true);
          if isempty(x0)
             error('You broke it.')
          end 
        end
        thresholds(iV,iM) = x0(1)/test_V(iV); % ratio of V, equivalent to ratio of I
    end
end
toc
end