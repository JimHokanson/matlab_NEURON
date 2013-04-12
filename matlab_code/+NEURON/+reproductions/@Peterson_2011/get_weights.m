function W = get_weights(obj,PW,d)
% Look up weights from supplementary table S1
% W = get_weights(Peterson_2011_obj,PW,d)
% 
% Inputs:
% PW: pulse width (stimulus duration)
% d: fiber diameter
%
% Outputs:
% W: weights [n_j_0, n_j_1, ..., n_j_10]
%
% Class: NEURON.reproductions.Peterson_2011

fiber_diameters = obj.all_fiber_diameters;
pulse_widths = obj.all_pulse_durations;
interpFlag = false; % if this is true, value must be interpolated, rather than taken directly from table

if ~any(fiber_diameters == d) || ~any(pulse_widths == PW)
    interpFlag = true;
end

if interpFlag
   error('PW and/or d not in table. Weight interpolation not yet implemented.') 
end

% load data
class_path = fileparts(mfilename('fullpath')); % I'm sure there's a more graceful way to do this, but this is easy..
data_path = fullfile(class_path,'MDF_threshold_data','weights.mat');
load(data_path) % creates variable weights_table

i_d = find(fiber_diameters == d,1);
i_PW = find(pulse_widths == d,1);
table = weights_table(i_d);

% here's where it gets a little ugly... I could have organized the data better...
W = zeros(11,1);
for i = 0:10
   n_j = eval(['table.n_j_',num2str(i)]);
   W(i+1) = n_j(i_PW);
end

end