function figure_8c
%
%   NEURON.reproductions.MRG_2002.figure_8c   
%
%   TODO:
%   =========================================
%   1) Add regression
%   2) Add additional diameter fiber

%NOTE: I'm still missing the regression that was done on the resulting data...

%Details:
%See page 1001
%- 50 randomly distributed fibers 
%   uniform distribution 100 - 950
%   uniform distribution on other dimension 

%1 - 100 us stimuli
%2 - show 10 um diameter fiber


%STEPS:
%1) Run simulations
%2) Save data
%3) Do plotting

N_FIBERS           = 50;
TISSUE_RESISTIVITY = [1200 1200 300]; %See Stimulation Procedure Section
STIM_START_TIME    = 0.1;
STIM_DURATION      = 0.1;   %100 us duration
STIM_AMP           = -1;    %Let's work with + numbers on the scales
DEFAULT_GUESS      = 80;
MAX_THRESHOLD      = 500;   %outside this range will throw an error

obj = NEURON.simulation.extracellular_stim;

t_obj = obj.threshold_cmd_obj;
t_obj.allow_opposite_sign = false;
t_obj.max_threshold       = MAX_THRESHOLD; 

%tissue -------------------------------------------------
set_Tissue(obj,NEURON.tissue.createHomogenousTissueObject(TISSUE_RESISTIVITY));

%electrode ----------------------------------------------
e_obj = NEURON.extracellular_stim_electrode([0 0 0]); %Null for now, will move ...
setStimPattern(e_obj,STIM_START_TIME,STIM_DURATION,STIM_AMP);
set_Electrodes(obj,e_obj);

%cell ---------------------------------------------------
set_CellModel(obj,NEURON.cell.axon.MRG([0 0 0]))

axon_distance     = 100 + 850*rand(1,N_FIBERS);
node_spacing      = obj.cell_obj.getNodeSpacing;
parallel_distance = 0.5*node_spacing*rand(1,N_FIBERS);
threshold = zeros(1,N_FIBERS);
for iSim = 1:N_FIBERS
   new_xyz = [0 axon_distance(iSim) parallel_distance(iSim)];
   moveElectrode(e_obj,new_xyz)
   threshold(iSim) = sim__determine_threshold(obj,DEFAULT_GUESS);
end

plot(axon_distance,threshold,'o')
set(gca,'XLim',[0 1000],'YLim',[0 160])
