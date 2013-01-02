function varargout = computeStimulus(obj,varargin)
%computeStimulus Computes the stimulus
%   
%   varargout = computeStimulus(obj,varargin)
%
%   Computes the stimulus that is applied to a cell.
%
%   POPULATES (unless requested via output, [t_vec,v_all]
%   ======================================================================
%   obj.t_vec
%   obj.v_all
%
%   OPTIONAL INPUTS
%   =======================================================================
%   remove_zero_stim_option: (default 0)
%           - 0, remove nothing
%           - 1, remove start & end zeros
%           - 2, remove all zero stim times
%   xyz_use          : (default []), allows passing in different locations, 
%                       default (i.e. if empty) is to use cell location
%
%   RELIES ON
%   =======================================================================
%   1) cell placement
%   2) tissue properties
%   3) spatial relation between electrodes and cell
%   4) stimulus pattern for each electrode
%
%
%
%   NOTE: In general this function should be called only by:
%      NEURON.simulation.extracellular_stim.init__create_stim_info
%
%   NOTE: There is no stimulus amplitude applied here, only the scales and
%   superposition ...
%
%

in.remove_zero_stim_option = 0;
in.xyz_use          = [];
in = processVarargin(in,varargin);

if isempty(in.xyz_use)
    cell_xyz_all = obj.cell_obj.xyz_all;
else
    cell_xyz_all = in.xyz_use;
end

%Change stim times to match across all electrodes. 
%This causes redundant information but makes vector addition possible.
[t_vec,all_stim] = getMergedStimTimes(obj.elec_objs);
%all_stim: columns are electrodes, rows are times

switch in.remove_zero_stim_option
    case 0
        %Do Nothing
    case 1
        mask = false(1,size(all_stim,1));
        if all(all_stim(1,:) == 0)
            mask(1) = true;
        end
        if all(all_stim(end,:) == 0)
            mask(end) = true;
        end
        all_stim(mask,:) = [];
        t_vec(mask)      = [];
    case 2
        %removal of zero stim cases
        mask = ~any(all_stim,2);
        all_stim(mask,:) = [];
        t_vec(mask)      = [];
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

%Not super thrilled about this hack ...
if nargout
    varargout{1} = t_vec;
    varargout{2} = v_all;
else
    obj.v_all = v_all;
    obj.t_vec = t_vec;
end