function V = compute_voltages(obj,xstim)
% compute voltage at nodes using equation 3 (for a particular current)

% TODO: CHECK UNITS are r, z supposed to be in meters? They would need to
% be divided by a 1e6.

% find node positions, initialize V vector
XYZnodes = xstim.cell_obj.spatial_info_obj.get__XYZnodes;
N_nodes = size(XYZnodes,1);
V = zeros(N_nodes,1);

% conductivity
ct = 1/obj.resistivity_transverse;
cl = 1/obj.resistivity_longitudinal;

% get electrode objects
elec_objs = xstim.elec_objs;
N_electrodes = length(elec_objs);

for i_electrode = 1:N_electrodes % loop over electrodes and add (superposition)
    electrode = elec_objs(i_electrode);
    XYZelec = repmat(electrode.xyz,N_nodes,1);
    Iext = electrode.base_amplitudes;
    Iext = Iext(find(Iext,1)); % assumes single monophasic square pulse
    
    deltaXYZ2 = (XYZelec - XYZnodes).^2;
    r2 = deltaXYZ2(:,1) + deltaXYZ2(:,2);
    z2 = deltaXYZ2(:,3);
    
    V = V + Iext./(4*pi*sqrt(cl*ct*r2+ct^2*z2));
    
end

end