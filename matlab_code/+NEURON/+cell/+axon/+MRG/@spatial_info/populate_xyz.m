function populate_xyz(obj)
%populate_xyz Population of xyz coordinates based on object properties
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

%NOTE: If we move, we need to change xyz, but the # of elements doesn't
%change so we might as well keep the same memory
if size(obj.xyz_all,1) ~= n_sections_total
    obj.xyz_all  = zeros(n_sections_total,3);
end

%NOTE: X & Y 
obj.xyz_all(:,1) = obj.xyz_center(1);
obj.xyz_all(:,2) = obj.xyz_center(2);

obj.xyz_all(:,3) = cumsum(obj.L_all);

%Nudge over to the center of the object
%NOTE: L_all is a row vector, make column for adding ...
obj.xyz_all(:,3) = obj.xyz_all(:,3) - (0.5*obj.L_all)'; 

%Make it so that the center is now 0
obj.xyz_all(:,3) = obj.xyz_all(:,3) - obj.xyz_all(obj.center_I,3); 

%With this centered axon, redefine everything so that the center is now at
%the specified center location
obj.xyz_before_shift = obj.xyz_all; %We'll hold

obj.xyz_all(:,3) = obj.xyz_all(:,3) + obj.xyz_center(3); 

end