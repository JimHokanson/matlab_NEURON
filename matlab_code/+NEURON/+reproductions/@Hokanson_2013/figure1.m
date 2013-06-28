function figure1(use_long)
%
%   NEURON.reproductions.Hokanson_2013.figure1
%
%   NEURON.reproductions.Hokanson_2013.figure1(true)
%
%   =======================================================================
%                       MULTIPLE ELECTRODE DISTANCES
%   =======================================================================
%
%   This method examines the volume-ratio for a range of distances and
%   amplitudes for a single fiber diameter. It is meant to provide insight
%   into what stimulus separations are acceptable

import NEURON.reproductions.*

if ~exist('use_long','var')
   use_long = false; 
end

C.MAX_STIM_TEST_LEVEL      = 30;

electrode_separations = 1400:-200:200;
if use_long
    TITLE_STR = 'Longitudinal pairings';
    ELECTRODE_LOCATION_INDICES = 9:16;
else
    ELECTRODE_LOCATION_INDICES = 2:8; %This is the transverse set ...
    TITLE_STR = 'Transverse pairings';
end

C.FIBER_DIAMETER           = 15;

obj = Hokanson_2013;

avr = Hokanson_2013.activation_volume_requestor(obj);
avr.fiber_diameter = C.FIBER_DIAMETER;

%TODO: Might consider looping here for trans vs long ...

electrode_locations_test = obj.ALL_ELECTRODE_PAIRINGS(ELECTRODE_LOCATION_INDICES);

rs  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
                                    'single_with_replication',true);

rd  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL);


[dual_counts,single_counts,x_stim,extras] = getCountData(obj,...
        MAX_STIM_TEST_LEVEL,...
        obj.ALL_ELECTRODE_PAIRINGS(ELECTRODE_LOCATIONS_TEST),...
        STIM_WIDTH,FIBER_DIAMETER);

    
    
vol_ratio = dual_counts./single_counts;

%subplot(1,2,2)
figure
plot(x_stim,vol_ratio,'Linewidth',3)

%This would ideally be extracted from the pairings

legend(arrayfun(@(x) sprintf('%d um',x),electrode_separations,'un',0))
set(gca,'FontSize',18)
xlabel('Stimulus Amplitude (uA)','FontSize',18)
ylabel('Volume Ratio')
title(TITLE_STR)

keyboard
end