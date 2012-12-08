function computeStimulus(obj,varargin)
%computeStimulus Computes the stimulus
%   
%   computeStimulus(obj,varargin)
%
%   Computes the stimulus that is applied to a cell.
%
%   OPTIONAL INPUTS
%   =======================================================================
%   remove_zero_stim : (default false), if true removes times when there is
%                      no stimulus.
%   xyz_use : (default []), allows passing in different locations, 
%               default (i.e. if empty) is to use cell location
%
%   RELIES ON
%   =======================================================================
%   1) cell placement
%   2) .... list unfinished
%
%   POPULATES
%   ===============================
%   obj.t_vec
%   obj.v_all
%
%   NOTE: In general this function should be called only by:
%      NEURON.simulation.extracellular_stim.init__create_stim_info
%
%   NOTE: There is no stimulus amplitude applied here, only the scales and
%   superposition ...
%
%

in.remove_zero_stim = false;
in.xyz_use          = [];
in = processVarargin(in,varargin);

if isempty(in.xyz_use)
    cell_xyz_all = obj.cell_obj.xyz_all;
else
    cell_xyz_all = in.xyz_use;
end

%Change stim times to match across all electrodes. Causes redundant
%information but makes vector addition easier.
[t_vec,all_stim] = getMergedStimTimes(obj.elec_objs);
%all_stim: columns are electrodes, rows are times

if in.remove_zero_stim
   %removal of zero stim cases
   mask = ~any(all_stim,2);
   all_stim(mask,:) = [];
   t_vec(mask) = [];
end

%Compute the voltage field
%---------------------------------------------------------------------------
n_electrodes = length(obj.elec_objs);
for iElec = 1:n_electrodes
    
    elec_xyz = obj.elec_objs(iElec).xyz;
    v_ext = computeAppliedVoltageToCellFromElectrode(obj.tissue_obj,cell_xyz_all,elec_xyz,all_stim(:,iElec));

    %Use superposition, NOT AVERAGING
    if iElec == 1
        v_all = v_ext;
    else
        v_all = v_all + v_ext;
    end
end

obj.v_all = v_all;
obj.t_vec = t_vec;