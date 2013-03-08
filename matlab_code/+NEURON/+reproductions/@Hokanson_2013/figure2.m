function figure2()
%
%       NEURON.reproductions.Hokanson_2013.figure2

%??? - how to combine different diameters


obj = NEURON.reproductions.Hokanson_2013;

single_electrode_location = obj.ALL_ELECTRODE_PAIRINGS{1};

n_diameters = length(obj.ALL_DIAMETERS);



%We start at 2 to ignore the single electrode case ...
for iPair = [3 6]
    for iDiameter = 1:n_diameters
        
        fprintf('Running Pair: %d\n',iPair);
        fprintf('Running Diameter: %d\n',iDiameter);
        
        current_pair     = obj.ALL_ELECTRODE_PAIRINGS{iPair};
        current_diameter = obj.ALL_DIAMETERS(iDiameter);
        
        
        max_stim_all(iPair,iDiameter) = obj.getMaxStimLevelToTest(current_pair,...
            'current_diameter',current_diameter);
        
        
        %Determine counts for electrode pairing given max stimulus
        %---------------------------------------------------------------
        options = {...
            'electrode_locations',current_pair,...
            'tissue_resistivity',obj.TISSUE_RESISTIVITY};
        xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
        cell_obj  = xstim_obj.cell_obj;
        cell_obj.props_obj.changeFiberDiameter(current_diameter);
        act_obj   = xstim_obj.sim__getActivationVolume();
        
        x_stim_all{iPair,iDiameter} = 1:0.5:max_stim_all(iPair,iDiameter);
        counts_all{iPair,iDiameter} = act_obj.getVolumeCounts(x_stim_all{iPair,iDiameter});
    end
end

%Determining the "normalization factor"
%--------------------------------------------------------------
for iDiameter = 1:n_diameters
    
    current_diameter = obj.ALL_DIAMETERS(iDiameter);
    
    
    max_stim_test_single_electrode = max(max_stim_all(:,iDiameter));
    
    options = {...
        'electrode_locations',single_electrode_location,...
        'tissue_resistivity',obj.TISSUE_RESISTIVITY};
    xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
    act_obj   = xstim_obj.sim__getActivationVolume();
    cell_obj  = xstim_obj.cell_obj;
    cell_obj.props_obj.changeFiberDiameter(current_diameter);
    counts_all{1,iDiameter} = act_obj.getVolumeCounts(1:0.5:max_stim_test_single_electrode);
end

figure

pairs_use = [3 6];
ax = zeros(1,2);
diameter_legends = cell(1,n_diameters);
for iPair = 1:2
    cur_pair = pairs_use(iPair);
    ax(iPair) = subplot(1,2,iPair);
    hold all
    for iDiameter = 1:n_diameters
        
        diameter_legends{iDiameter} = sprintf('%g um',obj.ALL_DIAMETERS(iDiameter));
        
        cur_counts   = counts_all{cur_pair,iDiameter};
        n_cur_counts = length(cur_counts);
        x_stim       = x_stim_all{cur_pair,iDiameter};
        %NOTE: We double count the single electrode to account for both
%         n_cur_counts = length(x_stim);
%         cur_counts = cur_counts(1:n_cur_counts);
        %electrodes
        plot(x_stim,cur_counts./(2*counts_all{1,iDiameter}(1:n_cur_counts)));
    end
    legend(diameter_legends)
    title(obj.ELECTRODE_PAIRING_DESCRIPTIONS{cur_pair})
    xlabel('Stimulus Amplitude (uA)')
end

%TODO: Remove hardcode
set(ax,'YLim',[0 3],'XLim',[0 25])

keyboard


end