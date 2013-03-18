function figure1()
%
%   NEURON.reproductions.Hokanson_2013.figure1
%
%   This method examines the volume-ratio for a range of distances and
%   amplitudes.

MAX_STIM_TEST_LEVEL      = 30;
ELECTRODE_LOCATIONS_TEST = 2:8; %This is the transverse set ...
STIM_WIDTH               = {[0.2 0.4]};
FIBER_DIAMETER           = 15;

obj = NEURON.reproductions.Hokanson_2013;



x_stim = 1:0.5:MAX_STIM_TEST_LEVEL;


[dual_counts,single_counts] = getCountData(obj,...
    x_stim,obj.ALL_ELECTRODE_PAIRINGS(ELECTRODE_LOCATIONS_TEST),...
    STIM_WIDTH,FIBER_DIAMETER);
return


for iPair = 1:8
    fprintf('Running Pair: %d\n',iPair);
    current_pair = obj.ALL_ELECTRODE_PAIRINGS{iPair};
    
    %Determine max stimulus amplitude to test for this pair ...
    %----------------------------------------------------------
    %max_stim_all(iPair) = obj.getMaxStimLevelToTest(current_pair);

    %Determine counts for electrode pairing given max stimulus
    %---------------------------------------------------------------
    options = {...
        'electrode_locations',current_pair,...
        'tissue_resistivity',obj.TISSUE_RESISTIVITY};
    xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
    
    cell_obj  = xstim_obj.cell_obj;
    cell_obj.props_obj.changeFiberDiameter(CELL_DIAMETER);
    
    act_obj   = xstim_obj.sim__getActivationVolume();
    
    if iPair ~= 1
        counts_all{iPair} = act_obj.getVolumeCounts(x_stim);
    else
        for newPair = 2:8
           fprintf('Getting Base Counts For Pair: %d\n',iPair);
           base_counts{newPair} = act_obj.getVolumeCounts(x_stim,...
               'replication_points',obj.ALL_ELECTRODE_PAIRINGS{newPair}); 
        end
    end
end

dual_counts_m   = vertcat(counts_all{2:8});
single_counts_m = vertcat(base_counts{2:8});

vol_ratio = dual_counts_m./single_counts_m;

%Plot Type 1
%---------------------------------
subplot(1,2,1)
imagesc(x_stim,1400:-200:200,vol_ratio);
xlabel('Stimulus Amplitude (uA)','FontSize',18)
ylabel('Distance between electrode pair (um)','FontSize',18)
colorbar
set(gca,'FontSize',18)

subplot(1,2,2)
hold all
for iPair = 2:8
    plot(x_stim,counts_all{iPair}./base_counts{iPair},'Linewidth',3);
end
hold off

%This would ideally be extracted from the pairings
electrode_separations = 1400:-200:200;
legend(arrayfun(@(x) sprintf('%d um',x),electrode_separations,'un',0))
set(gca,'FontSize',18)
xlabel('Stimulus Amplitude (uA)','FontSize',18)
ylabel('Volume Ratio')






end