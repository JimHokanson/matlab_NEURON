function plot(obj,varargin)
%
%

%I want to redo this to efficiently summarize the stimuli
%PLOT 1 - all stimuli in time
%PLOT 2 - spatial layout of all electrodes ...

in.stimulus_amplitude = 1;
in = NEURON.sl.in.processVarargin(in,varargin);


% % % in.half_square_size = 400;
% % % in.step_size        = 5;
% % % in.plot_centered    = false;
% % % in.CLim             = [];
% % % in = NEURON.sl.in.processVarargin(in,varargin);
% % % 
% % % rho = extrac_stim_obj.resistivity;
% % % 
% % % xy = -in.half_square_size:in.step_size:in.half_square_size;
% % % 
% % % nOnSide = length(xy);
% % % 
% % % [X,Y] = meshgrid(xy,xy);
% % % 
% % % elec_xyz = obj.xyz;
% % % 
% % % xyz_all = zeros(numel(X),3);
% % % if in.plot_centered 
% % %     xyz_all(:,1) = elec_xyz(1) - X(:);
% % %     xyz_all(:,2) = 0;
% % %     xyz_all(:,3) = elec_xyz(3) - Y(:);    
% % % else
% % %     xyz_all(:,1) = X(:);
% % %     xyz_all(:,2) = 0;
% % %     xyz_all(:,3) = Y(:);
% % % end
% % % 
% % % if length(rho) == 1
% % %     v_ext = extracellular_stim.computeIsoField(rho,xyz_all,elec_xyz,obj.current);
% % % else
% % %     v_ext = extracellular_stim.computeAnIsoField(rho,xyz_all,elec_xyz,obj.current);
% % % end
% % % 
% % % for iStim = 2 %:size(v_ext,1)
% % %     
% % %   % keyboard 
% % %    
% % %    temp = v_ext(iStim,:);
% % %    temp = reshape(temp,[nOnSide nOnSide]);
% % %    %temp = sign(temp).*log(abs(temp));
% % %    if ~isempty(in.CLim)
% % %     imagesc(temp,in.CLim)   
% % %    else
% % %     imagesc(temp)
% % %    end
% % %    axis equal
% % %    colorbar
% % %    set(gca,'YDir','normal')
% % %    ylabel('z')
% % %    xlabel('x')
% % % end