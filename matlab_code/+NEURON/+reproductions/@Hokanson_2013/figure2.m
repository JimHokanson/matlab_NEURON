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
        
        x_stim_all{iPair,iDiameter} = 1:0.5:max_stim_all(iPair);
        counts_all{iPair,iDiameter} = act_obj.getVolumeCounts(x_stim_all{iPair});
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
hold all
% for iPair = 2:n_electrode_pairings
%     cur_counts   = counts_all{iPair};
%     n_cur_counts = length(cur_counts);
%     x_stim       = x_stim_all{iPair};
%     %NOTE: We double count the single electrode to account for both
%     %electrodes
%     plot(x_stim,cur_counts./(2*counts_all{1}(1:n_cur_counts)));
% end

keyboard


end