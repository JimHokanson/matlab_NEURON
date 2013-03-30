function figure3()
%
%   NEURON.reproductions.Hokanson_2013.figure3
%
%   Impact of Stimulus Width on Result.

obj = NEURON.reproductions.Hokanson_2013;

ELECTRODE_LOCATION       = {obj.ALL_ELECTRODE_PAIRINGS{7}};
FIBER_DIAMETER           = 15;
STIM_START_TIME          = 0.1;
PHASE_AMPLITUDES         = [-1 0.5];
MAX_STIM_AMPLITUDE_DEFAULT = 30;
STIM_WIDTHS_ALL     = [0.050 0.100 0.2 0.40];
DEFAULT_WIDTH_INDEX = 3; %references the 0.2 we've been testing ...
n_stim_widths       = length(STIM_WIDTHS_ALL);

CONST_AMPLITUDE_TESTS = [5 10 15 20];

FONT_SIZE = 18;

%Determining rough scaling factors to test
%--------------------------------------------------------------------------
x_dist_test   = 20:20:800;
n_x_dist_test = length(x_dist_test);

thresholds_current_distance = zeros(n_x_dist_test,n_stim_widths);

for iStim = 1:n_stim_widths
    cur_widths = [STIM_WIDTHS_ALL(iStim) 2*STIM_WIDTHS_ALL(iStim)];
    
    %TODO: make this a class method that is exposed ...
    %------------------------------------------
    options = {...
        'tissue_resistivity',obj.TISSUE_RESISTIVITY};
    xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
    
    xstim_obj.cell_obj.props_obj.changeFiberDiameter(FIBER_DIAMETER);
    xstim_obj.elec_objs.setStimPattern(STIM_START_TIME,cur_widths,PHASE_AMPLITUDES);
    
    temp_result_obj = xstim_obj.sim__getCurrentDistanceCurve(1,[0 0 0],x_dist_test,2);
    thresholds_current_distance(:,iStim) = temp_result_obj.thresholds;
end

dist_given_max_default_amp = interp1(...
            thresholds_current_distance(:,DEFAULT_WIDTH_INDEX),...
            x_dist_test(:),MAX_STIM_AMPLITUDE_DEFAULT);
        
amps_given_desired_distance = zeros(1,n_stim_widths);
for iStim = 1:n_stim_widths
   amps_given_desired_distance(iStim) = interp1(...
       x_dist_test(:),thresholds_current_distance(:,iStim),...
       dist_given_max_default_amp);
end
      
%This is a rough approximation which is only correct if the volume
%grows the same way for all stim widths, as we have only examined point on
%the volume, really we would need to also take into account longitudinal
%direction
max_stim_amplitudes_by_width = ceil(amps_given_desired_distance);

%Obtaining volume data
%--------------------------------------------------------------------------
dual_counts_all   = cell(1,n_stim_widths);
single_counts_all = cell(1,n_stim_widths);
stim_amps_all     = cell(1,n_stim_widths);

for iStim = 1:n_stim_widths
    cur_widths = {[STIM_WIDTHS_ALL(iStim) 2*STIM_WIDTHS_ALL(iStim)]};
   
    [dual_counts_all{iStim},single_counts_all{iStim},stim_amps_all{iStim}] = ... 
                getCountData(obj,max_stim_amplitudes_by_width(iStim),...
                ELECTRODE_LOCATION,cur_widths,FIBER_DIAMETER);
end

ratio_all         = cell(1,n_stim_widths);
for iStim = 1:n_stim_widths
   ratio_all{iStim} = dual_counts_all{iStim}./single_counts_all{iStim}; 
end

%Plotting Results
%--------------------------------------------------------------------------

keyboard

%Result 1: normalized by amplitude
%Result 2: normalized by charge
%Result 3: normalized by original volume

width_labels = arrayfun(@(x) sprintf('%g ms',x),STIM_WIDTHS_ALL,'un',0);

%Varying Stimulus Amplitude
%==========================================================================
%Normalized by amplitude ...
%---------------------------------------
figure
subplot(1,3,1)
hold all
for iWidth = 1:n_stim_widths
    plot(stim_amps_all{iWidth},ratio_all{iWidth},'linewidth',3)
end
legend(width_labels)
xlabel('Stimulus Amplitude (uA)','FontSize',FONT_SIZE)
set(gca,'FontSize',FONT_SIZE)

%Normalized by charge
%----------------------------------------
subplot(1,3,2)
hold all
for iWidth = 1:n_stim_widths
    plot(stim_amps_all{iWidth}*STIM_WIDTHS_ALL(iWidth),ratio_all{iWidth},'linewidth',3)
end
legend(width_labels)
xlabel('Stimulus Charge (nC)','FontSize',FONT_SIZE)
set(gca,'FontSize',FONT_SIZE)

%Normalized by effectiveness
%------------------------------------------
subplot(1,3,3)
hold all
for iWidth = 1:n_stim_widths
    plot((2*single_counts_all{1,iWidth}).^(1/3),ratio_all{iWidth},'linewidth',3)
end
legend(width_labels)
xlabel('Cubed Root Original Recruitment Volume (um^3)^(1/3)','FontSize',FONT_SIZE)
set(gca,'FontSize',FONT_SIZE)

%Constant Amplitude
%================================================================================


end