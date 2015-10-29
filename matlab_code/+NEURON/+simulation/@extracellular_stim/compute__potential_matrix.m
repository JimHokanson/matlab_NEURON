function potential_matrix = compute__potential_matrix(obj,x_y_z,varargin)
%compute__potential_matrix
%
%   p_mat = compute__potential_matrix(obj,x_y_z,varargin)
%
%   NOTE: This function was originally designed to allow analysis of the
%   potential in a volume of space. In addition to helping with plotting
%   the applied stimulus, it has also been used for computing parameters
%   that can be used to predict threshold from the stimulus, without
%   running the cell dynamics.
%
%   INPUTS
%   =========================================================
%   x_y_z : either [samples by xyz] or {x_values y_values z_values}
%           Arrays over which to compute the applied stimulus potential.
%           The vectors are combined to form a grid.
%
%   OPTIONAL INPUTS
%   ==============================================================
%   remove_zero_stim_option: (default 0)
%           - 0, remove nothing
%           - 1, remove start & end zeros
%           - 2, remove all zero stim times
%   returned_data_format : (default 0)
%           - 0, samples x space x time
%           - 1, samples x [space & time], this provides a concatenation
%                of all space values for a given time, followed by all
%                space values for the subsequent time
%           - 2, x by y by z by space x time NOT YET IMPLEMENTED
%                   only possible if input is in cell array form
%   change_inf_value : (default NaN), value to change inf to. Values
%   besides NaN will be signed i.e. if you are at -Inf and you apply a
%   replacement value of 10000 you will have -10000 in place of -Inf
%   
%   OUTPUTS
%   =========================================================
%   potential_matrix : Dimensions are x,y,z,stim_time 
%
%   See Also:
%       NEURON.simulation.extracellular_stim.compute_potential
%       NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds
%
%   Full Path:
%       NEURON.simulation.extracellular_stim.compute__potential_matrix


%JAH NOTE: 12/30/2012 11:15 PM
%I started rewriting this method without thinking too much about what
%I was doing, I might eventually revert to an older version and use a
%different approach or what I was trying to do with the data functions in
%the sim logger

%CRAP: I need to fix this method ...

in.remove_zero_stim_option = 1;
in.returned_data_format    = 0;
in.change_inf_value        = NaN;
in = NEURON.sl.in.process_varargin(in,varargin);


%Compute x,y,z in grid then linearize for input to computeStimulus

%TODO: Should do error checking on input ...
if iscell(x_y_z)
    [X,Y,Z] = meshgrid(x_y_z{:});
    xyz_use = [X(:) Y(:) Z(:)];
else
    xyz_use = x_y_z;
end


%NOTE: This populates v_all, t_vec
computeStimulus(obj,'remove_zero_stim',in.remove_zero_stim,'xyz_use',xyz_use)

%Resize output to potential matrix
v_all = obj.v_all;
t_vec = obj.t_vec;

sz = size(X);

potential_matrix = zeros([sz size(v_all,1)]);

nTimes = length(t_vec);
for iTime = 1:nTimes
   potential_matrix(:,:,:,iTime) = reshape(v_all(iTime,:),[sz(1) sz(2) sz(3)]); 
end

if in.set_inf_to_nan 
   potential_matrix(isinf(potential_matrix)) = NaN; 
end