function createCellInNEURON(obj)
%
%
%
%   Class: NEURON.cell.DRG_AD
%

cdToModelDirectory(obj)
c = obj.cmd_obj;
c.load_dll('mod_files/nrnmech.dll');

c.load_file('create_AD_cell.hoc');

%placeVariablesInNEURON(obj.props_obj,c)
%c.load_file('create_mrg_axon.hoc');
%populateSpatialInfo(obj)
%obj.cell_populated_in_NEURON = true;

NODE_LENGTH = 1.5;
D_LENGTH = 1450;
P_LENGTH = 1567;
N_SEGS   = 30;

%Let's go proximal to distal

L_P = repmat([NODE_LENGTH getL(P_LENGTH,6)],[1 N_SEGS]);
L_P = [L_P NODE_LENGTH getL(1119,5) NODE_LENGTH getL(670,3) NODE_LENGTH getL(461,3) NODE_LENGTH];
L_D = repmat([getL(D_LENGTH,7) NODE_LENGTH ],[1 N_SEGS]);
L_D = [NODE_LENGTH getL(358,3) NODE_LENGTH getL(780,5) NODE_LENGTH getL(1170,7) NODE_LENGTH L_D];

L_S = [NODE_LENGTH 201 NODE_LENGTH 168 NODE_LENGTH 130 NODE_LENGTH getL(85,2) NODE_LENGTH getL(200,6) 80];

L_P = L_P(end:-1:1);

%OOPS, X & Z are switched
z_P   = -1*cumsum(L_P);
xyz_P = zeros(length(z_P),3);
xyz_P(end:-1:1,3) = z_P; %Oy, what a mess

z_D   = cumsum(L_D);
xyz_D = zeros(length(z_D),3);
xyz_D(:,3) = z_D;

x_S   = cumsum(L_S);
xyz_S = zeros(length(x_S),3);
xyz_S(:,1) = x_S;

%NOTE: We need to create a list which
%has sections in the order specified below ...
obj.xyz_all = [xyz_P; xyz_D; xyz_S];

end

function L_out = getL(L_in,n_segs)
   L_out = L_in/n_segs*ones(1,n_segs);
end