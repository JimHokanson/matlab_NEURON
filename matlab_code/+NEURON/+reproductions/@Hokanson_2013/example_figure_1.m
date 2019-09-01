function example_figure_1()
%
%   NEURON.reproductions.Hokanson_2013.example_figure_1

obj = NEURON.reproductions.Hokanson_2013;

%Create NEURON model, show applied stimuli
%and show stimulus results ...

STIM_AMPLITUDE = 8;
CELL_XYZ = [100 0 300];
E1       = [-200 0 0];
E2       = [200  0 0];
MAX_Z    = 2000;
MIN_Z    = -2000;

%Threshold 4.91
%Use 5 uA as an example ...

figure(10)
clf
%r = xstim.sim__determine_threshold(1);

%This should generate 3 plots:
%1) the left electrode
%2) the right electrode
%3) both electrodes together

for iElec = 1:3
    if iElec == 1
        loc = E1;
        title_str = 'Stimulus at x = -200 (um)';
    elseif iElec == 2
        loc = E2;
        title_str = 'Stimulus at x = 200 (um)';
    else
        loc = [E1; E2];
        temp_ca   = num2cell(CELL_XYZ);
        title_str = sprintf('Stimulus at both sites, cell at [%d, %d, %d]',temp_ca{:});
    end
    
    title_str = sprintf('%d uA %s',STIM_AMPLITUDE,title_str);
    
    xstim = instantiateXstim(obj,loc);
    
    xstim.cell_obj.moveCenter(CELL_XYZ)
    
    subplot(2,3,iElec)
    set(gca,'FontSize',18)
    xstim.plot__AppliedStimulus(STIM_AMPLITUDE);
    set(gca,'YLim',[-40 0],'XLim',[-15 15])
    
    title(title_str)
    
    r = xstim.sim__single_stim(STIM_AMPLITUDE);
    subplot(2,3,iElec+3)
    set(gca,'FontSize',18)
    r.plot__singleSpace(11);
    set(gca,'YLim',[-90 30],'XLim',[0 1.1])
end

figure(11)
clf
hold on
%TODO: Make this a method (for plotting spatial layout of cell)
%--------------------------------------------------------------
%- expose "up to date" methods for each object for syncing
%NEURON and Matlab
%- require a section list that matches xyz_all
%- in NEURON grab stuff and return to Matlab



scatter([-200 200],[0 0],100,'filled')
node_z = (CELL_XYZ(3)-1150*2):1150:(CELL_XYZ(3)+1150*2);
node_z(node_z < MIN_Z | node_z > MAX_Z) = [];
scatter(CELL_XYZ(1)*ones(1,length(node_z)),node_z,100,'filled')
line([CELL_XYZ(1) CELL_XYZ(1)],[MIN_Z MAX_Z],'Linewidth',3)
%             line([100 100],[2 1150],'Linewidth',3)
%             line([100 100],[-1150 -2],'Linewidth',3)
set(gca,'FontSize',18)
title('Spatial layout of 10 um diameter fiber with 2 electrodes at x = [-200 200], cell at x = 100, node at z = 300')
xlabel('X')
ylabel('Z')
axis equal
hold off

%TODO: Add stimulus timing plots ...

end