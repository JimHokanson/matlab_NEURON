function figure7_part2()
%
%   NEURON.reproductions.Hokanson_2013.figure7_part2
%
%   Not used in the paper
%
%   =======================================================================
%               DIFFERENT RESISTIVITIES - halving magnitude
%   =======================================================================

import NEURON.reproductions.*

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor

%PLOTTING OPTIONS
%---------------------------------------------
P.Y_LIM = [1 5];

C.MAX_STIM = [30 60];

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test     = false;
avr.merge_solvers  = false;
avr.use_new_solver = true;

RESISTIVITY    = {[1211 1211 175] [605.5 605.5 87.5]};
RESIST_STRINGS = {'1211 trans, 175 long' '605.5 trans, 87.5 long'};
TITLE_STRINGS  = {'Longitudinal pairings'    'Transverse pairings'};
SLICE_DIMS     = {'xz' 'xz'};
EL_LOCATIONS = {[0 0 -200; 0 0 200] [-200 0 0;200 0 0]};

C.MAX_STIM_TEST_LEVEL     = 30;
C.STIM_WIDTH              = {[0.2 0.4]};
C.FIBER_DIAMETERS         = [10 15]; % obj.ALL_DIAMETERS;

n_diameters = length(C.FIBER_DIAMETERS);
n_resist    = length(RESISTIVITY);
%Data retrieval
%--------------------------------------------------------------------------
rs_all = cell(n_resist,2);
rd_all = cell(n_resist,2);
for iRes  = 1:n_resist
    fprintf(2,'Current resist: %d\n', iRes);
for iPair = 1:2
    fprintf(2,'Current pair: %d\n', iPair);
    electrode_locations_test = EL_LOCATIONS{iPair};
    temp_cell = cell(2,n_diameters);
    avr.custom_setup_function = @(x,y) helper__changeResistivity(x,y,RESISTIVITY{iRes});
    avr.slice_dims = SLICE_DIMS{iPair}; %Long slice on x, trans on y

    MAX_STIM = C.MAX_STIM(iRes);
    
    for iDiameter = 1:n_diameters
        fprintf(2,'Current diameter: %d\n', iDiameter);
        avr.fiber_diameter = C.FIBER_DIAMETERS(iDiameter);
        temp_cell{1,iDiameter}  = avr.makeRequest(electrode_locations_test,MAX_STIM,...
            'single_with_replication',true);
        temp_cell{2,iDiameter}  = avr.makeRequest(electrode_locations_test,MAX_STIM);
    end
    rs_all{iRes,iPair} = temp_cell(1,:);
    rd_all{iRes,iPair} = temp_cell(2,:);
end
end


keyboard
%--------------------------------------------------------------------------
%                           Plotting results
%--------------------------------------------------------------------------

%Go from by diameter to by resistivity
%NOTE: We need to include 


%rows - different resistivities
%cols - pairings

I_diam = 1;

example_1s = rs_all{1,2}{I_diam};
example_2s = rs_all{2,2}{I_diam};
example_1d = rd_all{1,2}{I_diam};
example_2d = rd_all{2,2}{I_diam};


subplot(3,2,1)
plot(example_1s.replicated_slice)
subplot(3,2,2)
plot(example_1d.slice)
subplot(3,2,3)
plot(example_2s.replicated_slice)
subplot(3,2,4)
plot(example_2d.slice)
subplot(3,2,5)
contour(example_1s.replicated_slice,5)
hold on
contour(example_2s.replicated_slice,10)

subplot(3,2,6)
for iDiameter = I_diam
    cur_diameter = C.FIBER_DIAMETERS(iDiameter);
    
    rs2_all = cell(n_resist,2);
    rd2_all = cell(n_resist,2);


for iRes  = 1:n_resist
    fprintf(2,'Current resist: %d\n', iRes);
    for iPair = 1:2
        rs2_all(iRes,iPair) = rs_all{iRes,iPair}(iDiameter);
        rd2_all(iRes,iPair) = rd_all{iRes,iPair}(iDiameter);
    end
end


%1) Standard, vs amplitude ...
for iPair = 1:2
    subplot(1,2,iPair)
    %final_strings = NEURON.sl.cellstr.sprintf('%5.2f - um',C.FIBER_DIAMETERS);
        
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs2_all(:,iPair),rd2_all(:,iPair));
    legend(RESIST_STRINGS)
    title(sprintf('%s fiber diameter: %5.2f',TITLE_STRINGS{iPair},cur_diameter))
    set(gca,'YLim',P.Y_LIM);
end
end






for iDiameter = 1:length(C.FIBER_DIAMETERS)
    cur_diameter = C.FIBER_DIAMETERS(iDiameter);

    figure(iDiameter)
    
rs2_all = cell(n_resist,2);
rd2_all = cell(n_resist,2);


for iRes  = 1:n_resist
    fprintf(2,'Current resist: %d\n', iRes);
    for iPair = 1:2
        rs2_all(iRes,iPair) = rs_all{iRes,iPair}(iDiameter);
        rd2_all(iRes,iPair) = rd_all{iRes,iPair}(iDiameter);
    end
end


%1) Standard, vs amplitude ...
for iPair = 1:2
    subplot(1,2,iPair)
    %final_strings = NEURON.sl.cellstr.sprintf('%5.2f - um',C.FIBER_DIAMETERS);
        
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs2_all(:,iPair),rd2_all(:,iPair));
    legend(RESIST_STRINGS)
    title(sprintf('%s fiber diameter: %5.2f',TITLE_STRINGS{iPair},cur_diameter))
    set(gca,'YLim',P.Y_LIM);
end
end

end

function helper__changeResistivity(~,xstim,resistivity)
    xstim.tissue_obj.resistivity = resistivity;
end


