function plotVolumeRatio(obj,rs,rd,varargin)
%
%    INPUTS
%    ==========================================
%    Class: NEURON.reproductions.Hokanson_2013.activation_volume_results
%    rs : cell array of objects
%    rd : cell array of objects ...
%
%
%   TODO: This code needs to be documented ...
%

in.x_by_single_volume = false; %If true we'll plot the counts for the single
%electrodes on the x-axis
in.normalize            = false;
in.normalization_index  = 1;
in.normalization_method = 'subtract'; %divide
in = NEURON.sl.in.processVarargin(in,varargin);

FONT_SIZE = 18;

n_sets = length(rs);

if in.normalize
    
    cur_rs = rs{in.normalization_index};
    cur_rd = rd{in.normalization_index};
    
    base_ratio = cur_rd.counts./cur_rs.counts;
    
    if in.x_by_single_volume
        base_x_axis = cur_rs.counts;
    else
        base_x_axis = cur_rs.stimulus_amplitudes;
    end
    
end


hold all
for iSet = 1:n_sets
    cur_rs = rs{iSet};
    cur_rd = rd{iSet};
    
    stim_rs = cur_rs.stimulus_amplitudes;
    stim_rd = cur_rd.stimulus_amplitudes;
    
    if ~isequal(stim_rs,stim_rd)
        error('Stimulus amplitude mismatch found')
    end
    
    vol_ratio = cur_rd.counts./cur_rs.counts;
    
    
    
    if in.x_by_single_volume
        x_axis = cur_rs.counts./(1000^3);
        %x_axis = cur_rs.counts;
    else
        x_axis = cur_rs.stimulus_amplitudes;
    end
    
    if in.normalize
        
        %Need to change x_axis and vol_ratio
        %to being on the same scale as the base ...
        
        vol_ratio = interp1(x_axis,vol_ratio,base_x_axis,'linear','extrap');
        
        x_axis = base_x_axis;
        
        if strcmp(in.normalization_method,'divide')
            vol_ratio = vol_ratio./base_ratio;
            norm_method = 'dividing by';
        else
            vol_ratio = vol_ratio - base_ratio;
            norm_method = 'subtracting';
        end
    end
    
    
    plot(x_axis,vol_ratio,'Linewidth',3)
    
    
end

set(gca,'FontSize',FONT_SIZE)
if in.x_by_single_volume
    xlabel('Recruitment Volume (mm^3)','FontSize',FONT_SIZE)
    %xlabel('1 um voxels','FontSize',FONT_SIZE)
else
    xlabel('Stimulus Amplitude (uA)','FontSize',FONT_SIZE)
end
if in.normalize 
   ylabel(sprintf('Volume Ratio normalized by %s index %d',norm_method,in.normalization_index))
else
   ylabel('Volume Ratio','FontSize',FONT_SIZE)
end
end