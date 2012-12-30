function getThresholds(obj,cell_locations,threshold_sign)
%
%
%   INPUTS
%   =======================================================================
%   cell_locations : either [samples by xyz] or {x_values y_values z_values}
%
%   See Also:
%       
%
%   FullPath: NEURON.simulation.extracellular_stim.sim_logger.data.getThresholds

%OUTLINE
%==========================================================================
%0) Compute applied stimulus
%1) Find previous matches
%2) For those not find previous matches, have place for prediction
%(implement later)
%3) 

xstim_obj = obj.xstim_obj;

if iscell(cell_locations)
   cell_locations = helper__convert_to_matrix(cell_locations); 
end


end

function cell_locations = helper__convert_to_matrix(cell_locations)

    
    cell_locations = 
end