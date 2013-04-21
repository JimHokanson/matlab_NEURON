function figure3()
%
%   NEURON.reproductions.Hokanson_2013.figure3
%
%   Impact of Stimulus Width on Result.
%
%   This is currently NEW FIGURE 3
%   

obj = NEURON.reproductions.Hokanson_2013;

ELECTRODE_LOCATION       = {obj.ALL_ELECTRODE_PAIRINGS{7}};
FIBER_DIAMETER           = 15;
STIM_START_TIME          = 0.1;
PHASE_AMPLITUDES         = [-1 0.5];
MAX_STIM_AMPLITUDE_DEFAULT = 30;
STIM_WIDTHS_ALL     = [0.050 0.100 0.2 0.40 1 2];
DEFAULT_WIDTH_INDEX = 3; %references the 0.2 we've been testing ...
n_stim_widths       = length(STIM_WIDTHS_ALL);
STIM_SPACING = 200;

%We might make a separate function that examines reproducing
%work from Yoshida & Horch where for a fixed amplitude they varied the
%pulse width ...
CONST_AMPLITUDE_TESTS = [5 10 15 20];

FONT_SIZE = 18;

%Determining rough scaling factors to test
%--------------------------------------------------------------------------
x_dist_test   = 20:20:800; %We should make sure that this is sufficiently
%large so as to encompass MAX_STIM_AMPLITUDE_DEFAULT for our default
%stimulus width
n_x_dist_test = length(x_dist_test);

thresholds_current_distance = zeros(n_x_dist_test,n_stim_widths);

fprintf('Running current vs distance tests for stim width normalizaton\n')
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

%We first need to find the distance that the "default" stimulus width
%will activate given the maximum stimulus amplitude at that stimulus width
%that we want to investigate. For example, for a 200 us pulse, how much
%tissue will we activate given the maximum stimulus amplitude we are
%testing
dist_given_max_default_amp = interp1(...
            thresholds_current_distance(:,DEFAULT_WIDTH_INDEX),...
            x_dist_test(:),MAX_STIM_AMPLITUDE_DEFAULT);
 
%Next we say, for each stimulus width, how strong a stimulus do we need
%(approximately) to get the same amount of tissue
amps_given_desired_distance = zeros(1,n_stim_widths);
for iStim = 1:n_stim_widths
   amps_given_desired_distance(iStim) = interp1(...
       x_dist_test(:),thresholds_current_distance(:,iStim),...
       dist_given_max_default_amp);
end
      
%This is a rough approximation which is only correct if the volume
%grows the same way for all stim widths, as we have only examined point on
%the volume, really we would need to also take into account longitudinal
%direction. We round up here as the max amplitudes should be integers.
max_stim_amplitudes_by_width = ceil(amps_given_desired_distance);

%Obtaining volume data
%--------------------------------------------------------------------------
dual_counts_all   = cell(1,n_stim_widths);
single_counts_all = cell(1,n_stim_widths);
stim_amps_all     = cell(1,n_stim_widths);

%NOTE: We run each width separately as we are testing different 
%stim amplitudes at each width. We could improve the counts
for iStim = 1:n_stim_widths
    fprintf('Running Stim Width %d/%d\n',iStim,n_stim_widths);
    cur_widths = {[STIM_WIDTHS_ALL(iStim) 2*STIM_WIDTHS_ALL(iStim)]};
   
    [dual_counts_all{iStim},single_counts_all{iStim},stim_amps_all{iStim},temp_extras] = ... 
                getCountData(obj,max_stim_amplitudes_by_width(iStim),...
                ELECTRODE_LOCATION,cur_widths,FIBER_DIAMETER);
            
    if iStim == 1
        extras = temp_extras;
    else
        fn = fieldnames(extras);
        for iField = 1:length(fn)
            cur_field = fn{iField};
            extras.(cur_field) = [extras.(cur_field) temp_extras.(cur_field)];
        end
    end          
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
cla
hold all

volume_single = cell(1,n_stim_widths);
volume_dual   = cell(1,n_stim_widths);

for iWidth = 1:n_stim_widths
    x_plot = single_counts_all{1,iWidth}.^(1/3);
    plot(x_plot,ratio_all{iWidth},'linewidth',3)
    
%     volume_single{iWidth} = interp1(stim_amps_all{iWidth},...
%         x_plot,extras.single_slice_thresholds{iWidth});
%     volume_dual{iWidth} = interp1(stim_amps_all{iWidth},...
%         x_plot,extras.dual_slice_thresholds{iWidth});
%     
%     dual_t   = volume_dual{iWidth};
%     single_t = volume_single{iWidth}; 
% 
%     t_min_z_dual   = min(dual_t(:,:,1));
%     t_min_x_dual   = min(dual_t(ceil(size(dual_t,1)/2),:,:));
%     t_min_z_single = min(single_t(:,:,1));
%     
%     x_single       = extras.single_slice_xyz{iWidth}{1};
%     t_min_x_single = min(single_t(x_single == STIM_SPACING,:,:));
%     
%     all_values = [t_min_x_single t_min_z_single t_min_x_dual t_min_z_dual];
%     chars      = 'xzXZ';
%     for iVal = 1:4
%        y_val = interp1(x_plot(:),ratio_all{iWidth},all_values(iVal));
%        s = text(all_values(iVal),y_val,chars(iVal));
%        set(s,'FontSize',18)
%     end
    
end
legend(width_labels)
xlabel('Cubed Root Original Recruitment Volume (um^3)^(1/3)','FontSize',FONT_SIZE)
set(gca,'FontSize',FONT_SIZE)

%Contours for the same spatial recruitment
% % % % % figure
% % % % % contour_value = [550 550];
% % % % % color_order = get(gca,'ColorOrder');
% % % % % ax = zeros(1,2);
% % % % % for iWidth = 1:n_stim_widths
% % % % %    ax(1) = subplot(1,2,1);
% % % % %    hold all
% % % % %    cur_xyz  = extras.single_slice_xyz{iWidth};
% % % % %    cur_data = squeeze(volume_single{iWidth});
% % % % %    [~,h] = contour(cur_xyz{1},cur_xyz{3},cur_data',contour_value);
% % % % %    set(h,'Color',color_order(iWidth,:));
% % % % %    
% % % % %    ax(2) = subplot(1,2,2);
% % % % %    hold all
% % % % %    cur_xyz  = extras.dual_slice_xyz{iWidth};
% % % % %    cur_data = squeeze(volume_dual{iWidth});
% % % % %    [~,h] = contour(cur_xyz{1},cur_xyz{3},cur_data',contour_value);
% % % % %    set(h,'Color',color_order(iWidth,:));
% % % % % end
% % % % % linkaxes(ax)
% % % % % legend(width_labels)


end