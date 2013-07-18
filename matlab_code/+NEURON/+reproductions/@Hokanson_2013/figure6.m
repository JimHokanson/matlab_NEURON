function figure6()
%
%   
%   I'm not sure what I was going to do with this file ...

MAX_STIM_TEST_LEVEL      = 30;
ELECTRODE_LOCATIONS_TEST = 2:8; %This is the transverse set ...
STIM_WIDTH               = {[0.2 0.4]};
FIBER_DIAMETER           = 15;

obj = NEURON.reproductions.Hokanson_2013;

[dual_counts,single_counts,x_stim] = getCountData(obj,...
        MAX_STIM_TEST_LEVEL,...
        obj.ALL_ELECTRODE_PAIRINGS(ELECTRODE_LOCATIONS_TEST),...
        STIM_WIDTH,FIBER_DIAMETER);

    
    
vol_ratio = dual_counts./single_counts;

% % %Plot Type 1
% % %---------------------------------
% % %subplot(1,2,1)
% % figure
% % imagesc(x_stim,1400:-200:200,vol_ratio');
% % xlabel('Stimulus Amplitude (uA)','FontSize',18)
% % ylabel('Distance between electrode pair (um)','FontSize',18)
% % colorbar
% % set(gca,'FontSize',18)

%subplot(1,2,2)
figure
plot(x_stim,vol_ratio,'Linewidth',3)

%This would ideally be extracted from the pairings
electrode_separations = 1400:-200:200;
legend(arrayfun(@(x) sprintf('%d um',x),electrode_separations,'un',0))
set(gca,'FontSize',18)
xlabel('Stimulus Amplitude (uA)','FontSize',18)
ylabel('Volume Ratio')

keyboard
end