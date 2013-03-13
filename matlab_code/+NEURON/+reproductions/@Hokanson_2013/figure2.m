function figure2()
%
%   NEURON.reproductions.Hokanson_2013.figure2




obj = NEURON.reproductions.Hokanson_2013;

MAX_STIM_LEVEL = 30;

single_electrode_location = obj.ALL_ELECTRODE_PAIRINGS{1};
double_electrode_location = obj.ALL_ELECTRODE_PAIRINGS{7};

n_diameters = length(obj.ALL_DIAMETERS);

stim_amplitudes = 1:0.5:MAX_STIM_LEVEL;
dual_counts_all   = cell(1,n_diameters);
single_counts_all = cell(1,n_diameters); 

%TODO: Replicate code for single electrodes as well ...
%Make this a function ????
for iDiameter = 1:n_diameters

    fprintf('Running Diameter: %d\n',iDiameter);

    current_diameter = obj.ALL_DIAMETERS(iDiameter);

    %Determine counts for electrode pairing given max stimulus
    %----------------------------------------------------------------------
    options = {...
        'electrode_locations',double_electrode_location,...
        'tissue_resistivity',obj.TISSUE_RESISTIVITY};
    xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
    cell_obj  = xstim_obj.cell_obj;
    cell_obj.props_obj.changeFiberDiameter(current_diameter);
    act_obj   = xstim_obj.sim__getActivationVolume();

    dual_counts_all{iDiameter} = act_obj.getVolumeCounts(stim_amplitudes);
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