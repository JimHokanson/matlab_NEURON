function refractoryPeriodTest()
%
%
%   NEURON.reproductions.Hokanson_2013.refractoryPeriodTest()
%

%CURRENT STATUS: The prediction step takes too long and needs to be fixed
%...

error('Not yet finished')

STIM_DELAYS = 0.4:0.1:2;
MAX_STIM_LEVEL = 30;
STIM_DELAYS_FINAL = 0.4:0.2:1;
X_RANGE = -400:10:400;
Z_RANGE = -700:10:700;


ELECTRODE_LOCATIONS = [-200 0 0; 200 0 0];
obj          = NEURON.reproductions.Hokanson_2013;


%Some manual examination of the response curve ...
%--------------------------------------------------------------------------
if false
    
    options = {...
        'electrode_locations',[-200 0 0; 200 0 0],...
        'tissue_resistivity',obj.TISSUE_RESISTIVITY};
    xstim_options = NEURON.simulation.extracellular_stim.options;
    xstim_options.sim_options.display_time_change_warnings = false;
    xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:},'xstim_options',xstim_options);
    
    xstim_obj.elec_objs(1).setStimPattern(0.1,[0.2 0.2],[-1 1]);
    
    %Cell should be located at center ...
    
    xstim_obj.cell_obj.moveCenter([0 0 0]);
    
    n_delays = length(STIM_DELAYS);
    
    
    for iRatio = 1:5
        for iDelay = 1:n_delays
            xstim_obj.elec_objs(2).setStimPattern(0.1+STIM_DELAYS(iDelay),[0.2 0.2],[-iRatio iRatio]);
            r = xstim_obj.sim__single_stim(20,true); %TODO: Change to prop/value pairs
            plot(r)
            title(sprintf('Delay: %g Ratio: %g',STIM_DELAYS(iDelay),iRatio));
            pause
        end
    end
end





%A delay of 1.5 is the first time I see a response for -1
%1.3 - ratio of 2
%? - 3
%1.1 - ratio of 4 - why not autoexpand???
%0.9 - ratio of 5 -

%Change stimulus timing
%==========================================================================

options = {...
    'electrode_locations',ELECTRODE_LOCATIONS(1),...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
xstim_obj.elec_objs(1).setStimPattern(0.1,[0.2 0.2],[-1 1]);





options = {...
    'electrode_locations',ELECTRODE_LOCATIONS,...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
xstim_obj.elec_objs(1).setStimPattern(0.1,[0.2 0.2],[-1 1]);


%1) Response to single electrode at a given amplitude
%2) Show response to both at various delays
%3) Determine when double counting occurs - low priority ...
    
    
    keyboard
for iDelay = 1:STIM_DELAYS_FINAL
    xstim_obj.elec_objs(2).setStimPattern(0.1+STIM_DELAYS_FINAL(iDelay),[0.2 0.2],[-1 1]);
    
    %TODO: Test solution in a grid
    %1) Determine whether a cell responds
    
    

end

