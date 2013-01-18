function determineFiberEquations()
%
%   TODO: I'd like to move this to a separate section on morphology
%
%
%
%   SOURCE A
%   -----------------------------------------------------------------------
%   Nilsson I, Berthold CH (1988) Axon classes and internodal growth in the
%   ventral spinal root L7 of adult and developing cats. Journal of Anatomy
%   156:71–96.
%
%   - internodal length
%   - See Figure 3, Tables 4 & 5
%
%   SOURCE B
%   -----------------------------------------------------------------------
%   Berthold CH, Nilsson I, Rydmark M (1983) Axon diameter and myelin
%   sheath thickness in nerve fibres of the ventral spinal root of the
%   seventh lumbar nerve of the adult and developing cat. Journal of
%   anatomy 136:483–508.
%
%   - # of myelin lemella
%   - MYSA diameter
%   - FLUT diameter
%   - STIN diameter
%
%
%   SOURCE C
%   -----------------------------------------------------------------------
%   Rydmark, 1981, Nodal axon diameter correlates linearly with internodal
%   axon diameter in spinal roots of the cat.
%
%   The general gist of this article is that the axon constricts at the
%   node relative to its diameter in the internode. This paper examines the
%   relationship between d_n and d_in (diameter at the node and internode).
%   
%
%   PARAMETERS AFFECTED:
%   - node_diameter_all
%   - paranode_diameter_1_all
%   - relationship between axon_diameter_all & node_diameter_all
%
%   SOURCE D
%   -----------------------------------------------------------------------
%   Rydmark M, Berthold CH (1983) Electron microscopic serial section
%   analysis of nodes of Ranvier in lumbar spinal roots of the cat: a
%   morphometric study of nodal compartments in fibres of different sizes.
%   Journal of neurocytology 12:537–565.
%
%   Wow, this seems to have it all:
%   - number_lemella_all  DOES THIS MATCH AT ALL????? looks off
%   - 
%
%
%   SOURCE E
%   -----------------------------------------------------------------------
%   Berthold CH, Rydmark M (1983) Electrophysiology and morphology of
%   myelinated nerve fibers. VI. Anatomy of the paranode-node-paranode
%   region in the cat. Experientia 39:964–976.
%
%   Source on diameters and periaxonal spacings (some of the more "exotic"
%   things about this model"
%   
%   SOURCE 3
%   -----------------------------------------------------------------------
%   
%
%
%

fiber_diameter_fit       = 2:20;
axon_diameter_fit        = 2:20;

fiber_diameter_all       = [5.7      7.3     8.7     10      11.5    12.8    14      15      16];

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


%--------------------------------------------------------------------------
%               INTERNODE LENGTH
%--------------------------------------------------------------------------
%
%   SOURCE A: See Table 5, pg 82 
%
%   Nilsson I, Berthold CH (1988) Axon classes and internodal growth in the
%   ventral spinal root L7 of adult and developing cats. Journal of Anatomy
%   156:71–96.
%
%   Summary: Data seems to be fairly different from claimed source
%
%
subplot(3,2,1)
%plot(node_diameter_all,internode_length_all,'-o')
plot(axon_diameter_all,internode_length_all,'-o')
title('Internode Length')


%Year 5 from source
%---------------------------------------
p_orig_fit = [-91.1 -20.2 1745.9];
%p_orig_fit = [ -20.2 1745.9];
orig_fit = p_orig_fit(1) + p_orig_fit(2).*axon_diameter_fit + p_orig_fit(3).*log10(axon_diameter_fit);

%Year 1 from source
%--------------------------------------
p_y1       = [-117.5 -126 2753];
y1         = p_y1(1) + p_y1(2).*axon_diameter_fit + p_y1(3).*log10(axon_diameter_fit);

%Matt's version
%-------------------------------------
p_in_fit = polyfit(log(axon_diameter_all),internode_length_all,1);
in_fit   = polyval(p_in_fit,log(axon_diameter_fit));

X_1 = [log10(axon_diameter_all(:)) axon_diameter_all(:) ones(length(axon_diameter_all),1)];
X_2 = [log10(axon_diameter_fit(:)) axon_diameter_fit(:) ones(length(axon_diameter_fit),1)];

B_alt_fit = regress(internode_length_all(:),X_1);
alt_fit    = X_2*B_alt_fit;

hold on
plot(axon_diameter_fit,orig_fit,'r')
plot(axon_diameter_fit,y1,'g')
plot(axon_diameter_fit,in_fit,'k')
plot(axon_diameter_fit,alt_fit,'c')
hold off
legend('MRG','Best 5y From Source','Best 1y from source','Matt fit MRG','Jim fit to MRG data')




%--------------------------------------------------------------------------
%               NUMBER LAMELLA
%--------------------------------------------------------------------------
subplot(3,2,2)
plot(fiber_diameter_all,number_lemella_all,'-o')
title('# Lemella')




%MS - 65.897*log(fiberD)-32.66


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------



subplot(3,2,3)
plot(fiber_diameter_all,node_diameter_all,'-o')
title('Node Diameter')
hold on
p_node_diameter   = [0.006304 0.2071 0.5339];
node_diameter_fit = polyval(p_node_diameter,fiber_diameter_fit);
hold on
plot(fiber_diameter_fit,node_diameter_fit,'r')
hold off

%MS: 0.3449 -0.1484 R2 9961 % I get the same thing
%??? Why is their paranode_diameter_1 different???????
%poylnomial fit, order 2 

% subplot(3,2,4)
% plot(fiber_diameter_all,paranode_diameter_1_all,'-o')
% title('MYSA diameter')



subplot(3,2,4)
plot(fiber_diameter_all,paranode_length_2_all,'-o')
title('FLUT Length')


% subplot(3,2,5)
% plot(fiber_diameter_all,paranode_diameter_2_all,'-o')
% title('FLUT Diameter')



subplot(3,2,6)
plot(fiber_diameter_all,axon_diameter_all,'-o')
%p_axon_diameter   = polyfit(fiber_diameter_all,axon_diameter_all,2);
p_axon_diameter = [0.0188    0.4787    0.1204]; %To make sure we entered it right

axon_diameter_fit = polyval(p_axon_diameter,fiber_diameter_fit);
hold on
plot(fiber_diameter_fit,axon_diameter_fit,'r')
hold off
title('Axon Diameter')
%MS: linear = 0.889*fD - 1.9104 I think a truer fit is obtained with a
%poylnomial fit, order 2 p_axon_diameter = [0.0188    0.4787    0.1204];



%Some more validation of what things look like compared to publication
%Rydmark M (1981) Nodal axon diameter correlates linearly with internodal
%axon diameter in spinal roots of the cat. Neuroscience letters 24:247–250.
% figure(2)
%Figure 5 in paper
% plot(fiber_diameter_all,node_diameter_all./axon_diameter_all,'o')