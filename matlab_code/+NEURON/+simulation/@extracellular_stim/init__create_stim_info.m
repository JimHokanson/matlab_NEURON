function init__create_stim_info(obj)
%init__create_stim_info  Initialize stimulation vector for extracellular stim in NEURON.
%
%   init__create_stim_info(obj)
%
%   The goal of this function is to create a voltage profile for 
%   stimulation in NEURON.
%
%    Writes voltage files for NEURON code to use ...
%
%   NEURON.simulation.extracellular_stim.init__create_stim_info
%   

[new_tissue_configuration,obj.tissue_configuration] = ...
    obj.tissue_obj.hasConfigurationChanged(obj.tissue_configuration);

[new_electrode_configuration,obj.electrode_configuration] = ...
    obj.elec_objs.hasConfigurationChanged(obj.electrode_configuration);


[new_cell_configuration,obj.cell_configuration] = hasSpatialInformationChanged(obj.cell_obj,obj.cell_configuration);

if ~(new_tissue_configuration || new_electrode_configuration || new_cell_configuration)
    return
end

%Compute stimulus information - populates t_vec and v_all
%   NEURON.simulation.extracellular_stim.computeStimulus
obj.computeStimulus();

t_vec = obj.t_vec;
v_all = obj.v_all;

%This call allows adjustment of the simulation time in case it is too short or long
adjustSimTimeIfNeeded(obj,t_vec(end))

%Data transfer to NEURON
obj.data_transfer_obj.writeStimInfo(v_all,t_vec);

end