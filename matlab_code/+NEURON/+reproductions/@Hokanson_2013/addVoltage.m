

x = [-1000:1:1000];
z = [-800:1:800];

nx = length(x);
nz = length(z);

[X,Z] = ndgrid(x,z);

xyz = zeros(numel(X),3);
xyz(:,1) = X(:);
xyz(:,3) = Z(:);

wtf = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',[200 0 0]);
wtf.elec_objs.setStimPattern(0.1,0.1,1);
[t,v] = wtf.computeStimulus('xyz_use',xyz,'remove_zero_stim_option',1);
v1 = reshape(v,[nx nz]);


wtf = NEURON.simulation.extracellular_stim.create_standard_sim('electrode_locations',[-200 0 0]);
wtf.elec_objs.setStimPattern(0.1,0.1,1);
[t,v] = wtf.computeStimulus('xyz_use',xyz,'remove_zero_stim_option',1);
v2 = reshape(v,[nx nz]);

v3 = v2 + v1;

v4 = v3./max(v2,v1);

imagesc(x,z,v4')