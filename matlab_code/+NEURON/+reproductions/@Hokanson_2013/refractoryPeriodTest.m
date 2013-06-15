function refractoryPeriodTest()
%
%
%   NEURON.reproductions.Hokanson_2013.refractoryPeriodTest()
%

obj          = NEURON.reproductions.Hokanson_2013;
options = {...
    'electrode_locations',[-200 0 0; 200 0 0],...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});


%Change stimulus timing 