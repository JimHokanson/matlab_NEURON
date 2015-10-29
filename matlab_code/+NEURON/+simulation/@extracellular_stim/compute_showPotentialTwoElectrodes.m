function [applied_voltage,x_indices] = compute_showPotentialTwoElectrodes(obj,varargin)
%
%
%   OPTIONAL INPUTS
%   ===========================================
%
%
%   Class: NEURON.simulation.extracellular_stim

%STATUS: This function could use some polishing ...


in.dim_plot = 1;
in.plot_results = true;
%in.depth_out_of_plane = 0; %@ y = 0
%in.show_electrodes    = true;
in.spatial_resolution = 1;
in.padding = 400;
%?? - how to handle all times????
%1 - movie
%2 - single time frame - implement for now ...
in = NEURON.sl.in.processVarargin(in,varargin);

%INPUT HANDLING
all_dims = 'xyz';

%Plot in 1 vs 2 space, 3rd specifies depth plane, see subsequent code ...
% dim_numbers = zeros(1,3);
% 
% dim_numbers(1) = strfind(all_dims,in.plane(1));
% dim_numbers(2) = strfind(all_dims,in.plane(2));
% dim_numbers(3) = find(~ismember(1:3,dim_numbers(1:2)));

%1) Determine electrode extents
xyz_bounds = getXYZBounds(obj.elec_objs);

x = xyz_bounds(:,in.dim_plot);

x_indices = (x(1)-in.padding):in.spatial_resolution:(x(2)+in.padding);

n_points = numel(x_indices);
zero_vec = zeros(n_points,1);

xyz_points = [x_indices(:) zero_vec zero_vec];


%2) Compute voltage fields

obj.computeStimulus('xyz_use',xyz_points);


%3) Plot results 
%t_vec = obj.t_vec;
v_all = obj.v_all;

applied_voltage = v_all(2,:); %Plot at 2nd point, 1st point is time zero = NULL

if in.plot_results
    pos_mask = applied_voltage > 0;
    temp_p = applied_voltage;
    temp_n = applied_voltage;
    temp_p(~pos_mask) = NaN;
    temp_n(pos_mask) = NaN;
    plot(x_indices,temp_p,'r')
    hold on
    plot(x_indices,temp_n,'b')
    hold off
end

end