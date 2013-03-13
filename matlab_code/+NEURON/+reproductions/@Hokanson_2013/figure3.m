function figure3()
%
%   NEURON.reproductions.Hokanson_2013.figure3
%

%TODO: Create pairing requests - 400x instead of some magic number

obj = NEURON.reproductions.Hokanson_2013;


%For fixed setup and diameter, vary pulse width

CELL_DIAMETER = 15;
TEST_PAIRING  = 3; %400 um apart in X
FONT_SIZE     = 18;

stim_widths_all = [0.050 0.100 0.2 0.40];
n_stim_widths   = length(stim_widths_all);

max_stim_level_all = zeros(1,n_stim_widths);
x_stim_all         = cell(1,n_stim_widths);
counts_all         = cell(2,n_stim_widths);

for iStimWidth = 1:n_stim_widths
    
    cur_stim_width = stim_widths_all(iStimWidth);

    max_stim_level_all(iStimWidth) = obj.getMaxStimLevelToTest(...
                    obj.ALL_ELECTRODE_PAIRINGS{TEST_PAIRING},...
                    'current_diameter',CELL_DIAMETER,...
                    'stim_width',cur_stim_width);
    
    for iOrig = 1:2
            fprintf('Running Width: %g\n',cur_stim_width);
            fprintf('Running iOrig: %d\n',iOrig);
        
        options = {...
            'stim_durations',[cur_stim_width 2*cur_stim_width],...
            'tissue_resistivity',obj.TISSUE_RESISTIVITY};
        
        if iOrig == 1
            options = [options 'electrode_locations',obj.ALL_ELECTRODE_PAIRINGS{1}];
        else
            options = [options 'electrode_locations',obj.ALL_ELECTRODE_PAIRINGS{TEST_PAIRING}];
        end
        
        xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
        cell_obj  = xstim_obj.cell_obj;
        cell_obj.props_obj.changeFiberDiameter(CELL_DIAMETER);
        
        act_obj   = xstim_obj.sim__getActivationVolume();
        
        x_stim_all{iStimWidth} = 1:0.5:max_stim_level_all(iStimWidth);
        
        counts_all{iOrig,iStimWidth} = act_obj.getVolumeCounts(x_stim_all{iStimWidth});
    end
    
end

%Result 1: normalized by amplitude
%Result 2: normalized by charge
%Result 3: normalized by original volume

width_labels = arrayfun(@(x) sprintf('%g ms',x),stim_widths_all,'un',0);

%Normalized by amplitude ...
%---------------------------------------
figure
subplot(1,3,1)
hold all
for iWidth = 1:n_stim_widths
   plot(x_stim_all{iWidth},counts_all{2,iWidth}./(2*counts_all{1,iWidth}),'linewidth',3) 
end
legend(width_labels)
xlabel('Stimulus Amplitude (uA)','FontSize',FONT_SIZE)
set(gca,'FontSize',FONT_SIZE)

%Normalized by charge
%----------------------------------------
subplot(1,3,2)
hold all
for iWidth = 1:n_stim_widths
   plot(x_stim_all{iWidth}*stim_widths_all(iWidth),counts_all{2,iWidth}./(2*counts_all{1,iWidth}),'linewidth',3) 
end
legend(width_labels)
xlabel('Stimulus Charge (nC)','FontSize',FONT_SIZE)
set(gca,'FontSize',FONT_SIZE)

%Normalized by effectiveness
%------------------------------------------
subplot(1,3,3)
hold all
for iWidth = 1:n_stim_widths
   plot((2*counts_all{1,iWidth}).^(1/3),counts_all{2,iWidth}./(2*counts_all{1,iWidth}),'linewidth',3) 
end
legend(width_labels)
xlabel('Cubed Root Original Recruitment Volume (um^3)^(1/3)','FontSize',FONT_SIZE)
set(gca,'FontSize',FONT_SIZE)

end