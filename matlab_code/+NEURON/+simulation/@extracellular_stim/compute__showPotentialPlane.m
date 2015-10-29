function output = compute__showPotentialPlane(obj,varargin)
%
%
%   OPTIONAL INPUTS
%   ===========================================
%
%
%   OUTPUTS
%   ===========================================
%       .v_all  = v_all;
%       .v_plot = v_plot;
%
%   Class: NEURON.simulation.extracellular_stim
%
%   STATUS: FUCNTION IS UNFINISHED

%
%
%   TODO: Create static methods which expose this ...
%   Create example class ...

%NEED 2d version


in.plane              = 'xz';
in.depth_out_of_plane = 0; %@ y = 0
in.show_electrodes    = true;
in.spatial_resolution = 1;
in.padding            = 400;
in.plot_data          = true;
in.plot_electrodes    = true;
in.electrode_size     = 40;

%?? - how to handle all times????
%1 - movie
%2 - single time frame - implement for now ...
in = NEURON.sl.in.processVarargin(in,varargin);

%INPUT HANDLING
all_dims = 'xyz';

%Plot in 1 vs 2 space, 3rd specifies depth plane, see subsequent code ...
dim_numbers = zeros(1,3);

dim_numbers(1) = strfind(all_dims,in.plane(1));
dim_numbers(2) = strfind(all_dims,in.plane(2));
dim_numbers(3) = find(~ismember(1:3,dim_numbers(1:2)));

%1) Determine electrode extents
xyz_bounds = getXYZBounds(obj.elec_objs);

x = xyz_bounds(:,dim_numbers(1));
y = xyz_bounds(:,dim_numbers(2));

x_indices = (x(1)-in.padding):in.spatial_resolution:(x(2)+in.padding);
y_indices = (y(1)-in.padding):in.spatial_resolution:(y(2)+in.padding);

[X,Y] = meshgrid(x_indices,y_indices);

xyz_points = [X(:) Y(:) in.depth_out_of_plane*ones(numel(X),1)];

sz = [numel(x_indices) numel(y_indices)];

%2) Compute voltage fields

obj.computeStimulus('xyz_use',xyz_points);


%3) Plot results 
t_vec = obj.t_vec;
v_all = obj.v_all;

%v_all => 



v_plot = reshape(v_all(2,:),[sz(2) sz(1)]);

%TODO: Resize everything ...

output.v_all  = v_all;
output.v_plot = v_plot;
output.t_vec  = t_vec;

% imagesc(v_plot);
% axis equal
% set(gca,'CLim',[-10 10])

if in.plot_data  
    ratio = [0.05:0.05:0.5];
    nRatios = length(ratio);
    N_BINS = 64;
    non_zero_N = zeros(1,nRatios);
    v_lin_plot = v_plot(:);
    v_lin_plot(isinf(v_lin_plot)) = NaN;
    for iRatio = 1:nRatios
        cur_ratio = ratio(iRatio);
        [N,X] = hist(sign(v_lin_plot).*abs(v_lin_plot).^cur_ratio,N_BINS);
        non_zero_N(iRatio) = length(find(N ~= 0));
    end

    [~,best_ratio_I] = max(non_zero_N);

    ratio_use = ratio(best_ratio_I);
    imagesc(x_indices,y_indices,sign(v_plot).*abs(v_plot).^ratio_use)
    axis equal
    h = colorbar;

    yTicks    = get(h,'YTick');
    newYTicks = sign(yTicks).*abs(yTicks).^(1/ratio_use);

    newTickLabels = arrayfun(@(x) sprintf('%0.1f',x),newYTicks,'un',0);
    
    set(h,'YTickLabel',newTickLabels)
    
    if in.plot_electrodes
       %Class NEURON.extracellular_stim_electrode
       %obj.elec_objs 
       e_objs = obj.elec_objs;
       nElectrodes = length(e_objs);
       hold on
       for iElectrode = 1:nElectrodes
          xyz = e_objs(iElectrode).xyz;
          scatter(xyz(dim_numbers(1)),xyz(dim_numbers(2)),in.electrode_size,[1 1 1],'filled')
       end
       hold off
    end
end

end

