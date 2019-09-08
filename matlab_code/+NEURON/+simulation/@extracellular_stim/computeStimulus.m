function varargout = computeStimulus(obj,varargin)
%computeStimulus Computes the stimulus
%
%   Computes the stimulus to apply to the cell.
%
%   Calling Forms
%   -------------
%   1) User gets the computed variables
%   [t_vec,v_all,cell_xyz_all] = computeStimulus(obj,varargin)
%
%   2) Computed variables are stored internally
%   computeStimulus(obj,varargin)
%
%   
%
%   Infinite Stimulation Fix
%   ------------------------
%   The user may request stimuli that are too close   
%
%
%   Outputs
%   -------
%   t_vec
%   v_all
%   
%
%   Populates (when no outputs are requested)
%   -----------------------------------------
%   obj.t_vec
%   obj.v_all
%
%   Optional Inputs
%   ---------------
%   remove_zero_stim_option: (default 0)
%           - 0, remove nothing
%           - 1, remove start & end zeros
%           - 2, remove all zero stim times
%       I'm not entirely sure why this was added :/. It may have been
%       for plotting ...
%   xyz_use : (default []) [n x 3]
%           This should be used to pass in multiple xyz_locations. The
%           default behavior is to request xyz based on the location
%           of the single cell that is defined in the simulation currently.
%   nodes_only : (default false)
%           If true then the voltages are computed only at nodes. This was
%           initially added for plotting purposes.
%
%   Relies On
%   ---------
%   1) cell placement
%   2) tissue properties
%   3) spatial relation between electrodes and cell
%   4) stimulus pattern for each electrode
%
%   Improvements
%   ------------
%   1) Document infinite stimulation fix ...
%
%
%   NOTE: In general this function should be called only by:
%      NEURON.simulation.extracellular_stim.init__create_stim_info
%
%   NOTE: There is no stimulus amplitude applied here, only the scales and
%   superposition ...
%
%   See Also
%   --------
%   NEURON.cell.extracellular_stim_capable.getXYZnodes
%   NEURON.simulation.extracellular_stim.plot__AppliedStimulus

INF_MOVE_CELL = sqrt(1/3); %Distance between this (for x,y,and z) and 0 is 1
MAX_MV_STIM   = 1e4; %10 V max


in.remove_zero_stim_option = 0;
in.xyz_use = [];
in.nodes_only = false;
in = NEURON.sl.in.processVarargin(in,varargin);


if in.nodes_only && ~isempty(in.xyz_use)
    error('When retrieving stimuli applied to nodes, specific xyz to retrieve may not be used')
end

if isempty(in.xyz_use)
    if in.nodes_only
        cell_xyz_all = obj.cell_obj.getXYZnodes;
    else
        cell_xyz_all = obj.cell_obj.xyz_all;
    end
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

v_all = h__getAppliedPotentials(obj,cell_xyz_all,all_stim);

%Check for problems
%--------------------------------------------------------------------
%TODO: Handle zero applied stimulus ...
%[~,J] = find(isinf(v_all));

%abs() added because of large negative values
[~,J] = find(abs(v_all) > MAX_MV_STIM);

if ~isempty(J)
    
    cell_xyz_all(J,:) = cell_xyz_all(J,:) + INF_MOVE_CELL;
    
    %NOTE: Adding a random value causes uncertainty
    %which for consistent testing isn't so nice
    %We'll add a rediculously small amount which causes a slight bias
    %but I don't think it will be important, especially as the accuracy
    %isn't so high as to notice this small amount of movement
    v_all = h__getAppliedPotentials(obj,cell_xyz_all,all_stim);
    
    if any(v_all(:) > MAX_MV_STIM)
        error('Jim''s crappy fix to handling infinite stimulation failed, please come up with a better solution')
    end
end

%Not super thrilled about this hack ...
%TODO: This is going to become a handle class  ...
if nargout
    varargout{1} = t_vec;
    varargout{2} = v_all;
    varargout{3} = cell_xyz_all;
else
    obj.v_all = v_all;
    obj.t_vec = t_vec;
end

end

function v_all = h__getAppliedPotentials(obj,cell_xyz_all,all_stim)
%
%   Here we retrieve the applied potential from each of the electrodes
%
%   Inputs
%   ------
%   cell_xyz : [n x 3]
%   all_stim : 
%
%   Outputs
%   -------
%   v_all : [n_times x n_points]

%Compute the voltage field
%---------------------------------------------------------------------------
n_electrodes = length(obj.elec_objs);
for iElec = 1:n_electrodes
    
    elec_xyz = obj.elec_objs(iElec).xyz;
    tissue = obj.tissue_obj;
    v_ext = tissue.computeAppliedVoltageToCellFromElectrode(...
            cell_xyz_all,elec_xyz,all_stim(:,iElec));
    
    %Use superposition, NOT AVERAGING
    if iElec == 1
        v_all = v_ext;
    else
        v_all = v_all + v_ext;
    end
end



end