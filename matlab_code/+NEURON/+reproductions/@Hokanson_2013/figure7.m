function figure7()
%
%   NEURON.reproductions.Hokanson_2013.figure7
%
%   =======================================================================
%                       DIFFERENT RESISTIVITIES
%   =======================================================================

import NEURON.reproductions.*

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor

%PLOTTING OPTIONS
%---------------------------------------------
P.Y_LIM = [1 5];

C.MAX_STIM_TEST_LEVEL = 30;

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test     = false;
avr.merge_solvers  = false;
avr.use_new_solver = true;

OLD_MODEL_RESIST = 1; %should point to 500 iso
NEW_MODEL_RESIST = 4; %should point to 1211 1211 175

% RESISTIVITY   = {[500 500 500] [1211 1211 350] [1211 1211 87.5] [1211 1211 175]};
% RESIST_STRINGS = {'500 iso' '1211 trans, 350 long' '1211 trans, 87.5 long' '1211 trans, 175 long'};

RESISTIVITY   = { [1211 1211 350] [1211 1211 87.5] [1211 1211 175] [1411 1411 175] [1011 1011 175]};
RESIST_STRINGS = {'1211 trans, 350 long' '1211 trans, 87.5 long' '1211 trans, 175 long' '1411 trans, 175 long' '1011 trans, 175 long'};



TITLE_STRINGS = {'Longitudinal pairings'    'Transverse pairings'};
SLICE_DIMS    = {'xz' 'xz'};
EL_LOCATIONS = {[0 0 -200; 0 0 200]      [-200 0 0;200 0 0]};

C.MAX_STIM_TEST_LEVEL     = 30;
C.STIM_WIDTH              = {[0.2 0.4]};
C.FIBER_DIAMETERS         = 15;

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

    for iDiameter = 1:n_diameters
        fprintf(2,'Current diameter: %d\n', iDiameter);
        avr.fiber_diameter = C.FIBER_DIAMETERS(iDiameter);
        temp_cell{1,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
            'single_with_replication',true);
        temp_cell{2,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL);
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
    %final_strings = sl.cellstr.sprintf('%5.2f - um',C.FIBER_DIAMETERS);
        
    %NEURON.reproductions.Hokanson_2013.plotVolumeRatio
    obj.plotVolumeRatio(rs2_all(:,iPair),rd2_all(:,iPair));
    legend(RESIST_STRINGS)
    title(sprintf('%s fiber diameter: %5.2f',TITLE_STRINGS{iPair},cur_diameter))
    set(gca,'YLim',P.Y_LIM);
end
end

%Old vs new model - for paper with Dennis ...
%-----------------------------------------------------------
figure(iDiameter+1)
cla
hold all
final_strings = sl.cellstr.sprintf('%5.2f - um',C.FIBER_DIAMETERS);
for iDiameter = 1:length(C.FIBER_DIAMETERS)
   temp_old = rs_all{OLD_MODEL_RESIST}{iDiameter};
   temp_new = rs_all{NEW_MODEL_RESIST}{iDiameter};
   %temp_new = rs_all{2}{iDiameter}; %The 350, Dennis might have used 300 - this would be closer than the current norm
   plot(temp_old.stimulus_amplitudes,temp_old.counts./temp_new.counts); 
end
legend(final_strings)
title(sprintf('Single electrode Recruitment ratio, old counts/new counts Resists: (%s) / (%s)\n',RESIST_STRINGS{OLD_MODEL_RESIST},RESIST_STRINGS{NEW_MODEL_RESIST}));

end

function helper__changeResistivity(~,xstim,resistivity)
    xstim.tissue_obj.resistivity = resistivity;
end


