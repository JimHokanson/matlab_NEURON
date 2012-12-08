function potential_matrix = compute__potential_matrix(obj,x,y,z,varargin)
%compute__potential_matrix
%
%   p_mat = compute__potential_matrix(obj,x,y,z,varargin)
%
%   NOTE: This function was originally designed to allow analysis of the
%   potential in a volume of space. In addition to helping with plotting
%   the applied stimulus, it has also been used for computing parameters
%   that can be used to predict threshold from the stimulus, without
%   running the cell dynamics.
%
%   INPUTS
%   =========================================================
%   x,y,z : Arrays over which to compute the applied stimulus potential.
%           The vectors are combined to form a grid.
%
%   OPTIONAL INPUTS
%   ==============================================================
%   remove_zero_stim : (default true), if true this removes cases
%                      in which no stimulus is applied. Generally at the
%                      beginning of a simulation, the stimulus is
%                      initialized to zero. This may not be interesting to
%                      the user who only wants to look at the potential due
%                      to a stimulus pulse.
%   set_inf_to_nan   : (default true), If true, this replaces infinite values
%                       in the potential matrix output with NaN. This would
%                       occur when the distance betweeen the stimulus and
%                       the cell is zero.
%
%   OUTPUTS
%   =========================================================
%   potential_matrix : Dimensions are x,y,z,stim_time 
%
%   See Also:
%       NEURON.simulation.extracellular_stim.compute_potential

in.remove_zero_stim = true;
in.set_inf_to_nan   = true; 
in = processVarargin(in,varargin);

%Compute x,y,z in grid then linearize for input to computeStimulus
[X,Y,Z] = meshgrid(x,y,z);
xyz_use = [X(:) Y(:) Z(:)];

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