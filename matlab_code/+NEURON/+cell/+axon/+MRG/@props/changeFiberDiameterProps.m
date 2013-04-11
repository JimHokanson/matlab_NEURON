function changeFiberDiameterProps(obj)
%
%
%
%
%   FULL PATH:
%       NEURON.cell.axon.MRG.props.changeFiberDiameterProps

switch obj.fiber_dependency_method
    case 1
        helper__changePropsMethod1(obj);
    case 2
        helper__changePropsMethod2(obj);
    otherwise
        error('Option #%d not recognized')
end


end

function helper__changePropsMethod1(obj)
%
%
%   See MRG paper for details


fiber_diameter_all       = [5.7      7.3     8.7     10      11.5    12.8    14      15      16];

FIBER_INDEX = find(fiber_diameter_all == obj.fiber_diameter,1);
if isempty(FIBER_INDEX)
    error('Unable to find specifications for given fiber size')
end

%ROUGH DIAMETER OUTLINE
%--------------------------------------------------------------
%FIBER DIAMETER > AXON DIAMETER > NODE DIAMETER
%AXON DIAMETER = FLUT DIAMETER (PARANODE 2)
%NODE DIAMETER = MYSA DIAMETER (PARANODE 1)


internode_length_all     = [500      750     1000    1150    1250    1350    1400    1450    1500];
number_lemella_all       = [80       100     110     120     130     135     140     145     150];
%node_length             CONSTANT
node_diameter_all        = [1.9      2.4     2.8     3.3     3.7     4.2     4.7     5.0     5.5];
%paranode_length_1       CONSTANT
paranode_diameter_1_all  = [1.9      2.4     2.8     3.3     3.7     4.2     4.7     5.0     5.5];
%space_p1                CONSTANT
paranode_length_2_all    = [35       38      40      46      50      54      56      58      60];
paranode_diameter_2_all  = [3.4      4.6     5.8     6.9     8.1     9.2     10.4    11.5    12.7];
%space_p2                CONSTANT
%STIN LENGTH             DEPENDENT - delta_x_all,paranode_length_1,paranode_length_2_all,n_STIN
axon_diameter_all        = [3.4      4.6     5.8     6.9     8.1     9.2     10.4    11.5    12.7];

obj.internode_length     = internode_length_all(FIBER_INDEX);
obj.number_lemella       = number_lemella_all(FIBER_INDEX);
obj.node_diameter        = node_diameter_all(FIBER_INDEX);
obj.paranode_diameter_1  = paranode_diameter_1_all(FIBER_INDEX);
obj.paranode_length_2    = paranode_length_2_all(FIBER_INDEX);
obj.paranode_diameter_2  = paranode_diameter_2_all(FIBER_INDEX);
obj.axon_diameter        = axon_diameter_all(FIBER_INDEX);

end

function helper__changePropsMethod2(obj)
%
%   
%   See page 206 (pdf page 227) of Matt Schiefer's thesis
%
fd = obj.fiber_diameter;

%Check fd range ...


obj.axon_diameter       = 0.889*fd - 1.9104;
obj.node_diameter       = 0.3449*fd - 0.1484;
obj.paranode_diameter_1 = 0.3527*fd - 0.1804; %NOTE: In original this is
%the same as node_diameter ... :/
obj.paranode_diameter_2 = obj.axon_diameter;
obj.internode_length    = 969.3*log(fd) - 1144.6; %Referred to as deltax in
%Matt's original documentation
obj.paranode_length_2   = 2.5811*fd + 19.59;
obj.number_lemella      = 65.897*log(fd) - 32.666;

end