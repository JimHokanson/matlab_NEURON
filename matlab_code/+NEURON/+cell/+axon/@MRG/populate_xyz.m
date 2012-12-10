function populate_xyz(obj)
%populate_xyz
%
%   This function populates:
%   ===================================
%   .xyz_all
%
%   Class: NEURON.cell.axon.MRG
%
%   See also:
%       NEURON.cell.axon.MRG.populateSpatialInfo

n_sections_total = length(obj.section_ids);

if size(obj.xyz_all,1) ~= n_sections_total
    obj.xyz_all      = zeros(n_sections_total,3);
end
obj.xyz_all(:,1) = obj.xyz_center(1);
obj.xyz_all(:,2) = obj.xyz_center(2);

obj.xyz_all(:,3) = cumsum(obj.L_all);
obj.xyz_all(:,3) = obj.xyz_all(:,3) - obj.xyz_all(obj.center_I,3) + obj.xyz_center(3); %Start at zero
%Make center node at zero, then offset everything to the center location ...


end