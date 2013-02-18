function figure1()
%
%       NEURON.reproductions.Hokanson_2013.figure1

%For right now stop at smallest amplitude in which the separate
%electrodes would start to recruit the same neurons
%This will always be at the bisection of the two

%TODO: Need to correct for longitudinal interactions ...

obj = NEURON.reproductions.Hokanson_2013;

single_electrode_location = obj.ALL_ELECTRODE_PAIRINGS{1};

n_electrode_pairings = length(obj.ALL_ELECTRODE_PAIRINGS);

max_stim_all = zeros(1,n_electrode_pairings);
x_stim_all   = cell(1,n_electrode_pairings);
counts_all   = cell(1,n_electrode_pairings);

%We start at 2 to ignore the single electrode case ...
for iPair = 2:n_electrode_pairings
    fprintf('Running Pair: %d\n',iPair);
    current_pair = obj.ALL_ELECTRODE_PAIRINGS{iPair};
    
    %Determine max stimulus amplitude to test for this pair ...
    %----------------------------------------------------------
   
    max_stim_all(iPair) = obj.getMaxStimLevelToTest(current_pair);

    %Determine counts for electrode pairing given max stimulus
    %---------------------------------------------------------------
    options = {...
        'electrode_locations',current_pair,...
        'tissue_resistivity',obj.TISSUE_RESISTIVITY};
    xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
    act_obj   = xstim_obj.sim__getActivationVolume();
    
    x_stim_all{iPair} = 1:0.5:max_stim_all(iPair);
    counts_all{iPair} = act_obj.getVolumeCounts(x_stim_all{iPair});
end

%Determining the "normalization factor"
%--------------------------------------------------------------
max_stim_test_single_electrode = max(max_stim_all);

options = {...
    'electrode_locations',single_electrode_location,...
    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
act_obj   = xstim_obj.sim__getActivationVolume();

counts_all{1} = act_obj.getVolumeCounts(1:0.5:max_stim_test_single_electrode);

figure
hold all
for iPair = 2:n_electrode_pairings
    cur_counts   = counts_all{iPair};
    n_cur_counts = length(cur_counts);
    x_stim       = x_stim_all{iPair};
    %NOTE: We double count the single electrode to account for both
    %electrodes
    plot(x_stim,cur_counts./(2*counts_all{1}(1:n_cur_counts)));
end

legend(obj.ELECTRODE_PAIRING_DESCRIPTIONS(2:end))

keyboard


end