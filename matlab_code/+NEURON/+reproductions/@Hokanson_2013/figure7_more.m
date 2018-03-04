function figure7_more()
%
%   NEURON.reproductions.Hokanson_2013.figure7_more
%
%   Final figure 7.
%
%   =======================================================================
%                       DIFFERENT RESISTIVITIES
%   =======================================================================

import NEURON.reproductions.*

%NEURON.reproductions.Hokanson_2013.activation_volume_requestor

%PLOTTING OPTIONS
%---------------------------------------------
P.Y_LIM = [1 5];

C.MAX_STIM_TEST_LEVEL = 25;

obj = Hokanson_2013;
avr = Hokanson_2013.activation_volume_requestor(obj);
avr.quick_test     = false;
avr.merge_solvers  = false;
avr.use_new_solver = true;

OLD_MODEL_RESIST = 1; %should point to 500 iso
NEW_MODEL_RESIST = 4; %should point to 1211 1211 175

% RESISTIVITY   = {[500 500 500] [1211 1211 350] [1211 1211 87.5] [1211 1211 175]};
% RESIST_STRINGS = {'500 iso' '1211 trans, 350 long' '1211 trans, 87.5 long' '1211 trans, 175 long'};

%RESISTIVITY   = { [1211 1211 350] [1211 1211 87.5] [1211 1211 175] [1411 1411 175] [1011 1011 175]};
%RESIST_STRINGS = {'1211 trans, 350 long' '1211 trans, 87.5 long' '1211 trans, 175 long' '1411 trans, 175 long' '1011 trans, 175 long'};

resist_ls = {'r:' 'b:' 'g:' 'g-' 'r-' 'b-' 'k-' 'k:'}; %linestyles
RESISTIVITY   = {[1211 1211 350] ... %Increased long
    [1211 1211 500] ... %Really increased long
    [606 606 175] ... %Decreased trans
    [1817 1817 175] ... %Increased trans
    [1211 1211 175] ... %Standard
    [1817 1817 350] ... %Both inreased
    [606 606 75] ... %Both decreased
    }; 
RESIST_STRINGS = {'1211 trans, 350 long' ...
    '1211 trans, 500 long' ... 
    '606 trans, 175 long' ...
    '1817 trans, 175 long' ...
    '1211 trans, 175 long' ...
    '1817 trans, 350 long' ...
    '606 trans, 75 long' ...
    };

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
    fprintf(2,'Current resist: %d ------------\n', iRes);
for iPair = 1:2
    fprintf(2,'Current pair: %d ------------\n', iPair);
    electrode_locations_test = EL_LOCATIONS{iPair};
    temp_cell = cell(2,n_diameters);
    avr.custom_setup_function = @(x,y) helper__changeResistivity(x,y,RESISTIVITY{iRes});
    avr.slice_dims = SLICE_DIMS{iPair}; %Long slice on x, trans on y

    for iDiameter = 1:n_diameters
        fprintf(2,'Current diameter: %d\n', iDiameter);
        avr.fiber_diameter = C.FIBER_DIAMETERS(iDiameter);
        fprintf(2,'Single %d ------------\n', iPair);
        temp_cell{1,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL,...
            'single_with_replication',true);
        fprintf(2,'Double %d ------------\n', iPair);
        temp_cell{2,iDiameter}  = avr.makeRequest(electrode_locations_test,C.MAX_STIM_TEST_LEVEL);
    end
    rs_all{iRes,iPair} = temp_cell(1,:);
    rd_all{iRes,iPair} = temp_cell(2,:);
end
end

%--------------------------------------------------------------------------
%                           Plotting results
%--------------------------------------------------------------------------

%Go from by diameter to by resistivity
%NOTE: We need to include 

keyboard

%iDiameter = C.FIBER_DIAMETERS(1);
iDiameter = 1;

figure(71)
clf
rs2_all = cell(n_resist,2);
rd2_all = cell(n_resist,2);

%RESIST_STRINGS = {'1211 trans, 350 long' '1211 trans, 87.5 long' '1211 trans, 175 long' '1411 trans, 175 long' '1011 trans, 175 long'};

for iRes  = 1:n_resist
    %fprintf(2,'Current resist: %d\n', iRes);
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
    c = get(gca,'Children');
    c = c(end:-1:1); %Apparently the last shall be first
    for iC = 1:n_resist
       cur_ls = resist_ls{iC}; 
       set(c(iC),'Color',cur_ls(1),'LineStyle',cur_ls(2)); 
    end
    legend(RESIST_STRINGS)
    if iPair == 1
       title('Longitudinal pairing, 400 um');
    else
       title('Transverse pairing, 400 um'); 
    end
    %title(sprintf('%s fiber diameter: %5.2f',TITLE_STRINGS{iPair},cur_diameter))
    %set(gca,'YLim',P.Y_LIM);
    set(gca,'ylim',[1 3.5])
end

end

function helper__changeResistivity(~,xstim,resistivity)
    xstim.tissue_obj.resistivity = resistivity;
end


