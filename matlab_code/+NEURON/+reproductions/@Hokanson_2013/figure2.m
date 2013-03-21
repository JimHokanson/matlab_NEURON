function figure2()
%
%   NEURON.reproductions.Hokanson_2013.figure2
%
%   The goal here is to explore the effect of different fiber diameters.

obj = NEURON.reproductions.Hokanson_2013;

MAX_STIM_TEST_LEVEL      = 30;
ELECTRODE_LOCATION       = {obj.ALL_ELECTRODE_PAIRINGS{7}};
STIM_WIDTH               = {[0.2 0.4]};

fiber_diameters          = obj.ALL_DIAMETERS;

[dual_counts,single_counts,x_stim] = getCountData(obj,...
    MAX_STIM_TEST_LEVEL,...
    ELECTRODE_LOCATION,...
    STIM_WIDTH,...
    fiber_diameters);

vol_ratio = dual_counts./single_counts;

n_diameters      = length(fiber_diameters);
diameter_legends = cell(1,n_diameters);

for iDiameter = 1:n_diameters
    diameter_legends{iDiameter} = sprintf('%g um',obj.ALL_DIAMETERS(iDiameter));
    plot(x_stim,vol_ratio,'Linewidth',3)
end
legend(diameter_legends)
title('Electrodes spaced 400 um apart in transverse direction')
xlabel('Stimulus Amplitude (uA)')

keyboard

end