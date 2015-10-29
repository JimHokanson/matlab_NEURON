function plotContours(obj,rs,rd,target,varargin)
%
%    cell array of objects of type:
%    NEURON.reproductions.Hokanson_2013.activation_volume_results
%    rs
%    rd
%

%Overlapping or separate?

in.use_counts = false;
in = NEURON.sl.in.processVarargin(in,varargin);

color_order = get(gca,'ColorOrder');

ax(1) = subplot(1,2,1);
hold on
ax(2) = subplot(1,2,2);
hold on

n_objs = length(rs);
for iObj = 1:n_objs
   cur_rs = rs{iObj};
   cur_rd = rd{iObj};
   
   if in.use_counts
      target_use = interp1(cur_rs.counts,cur_rs.stimulus_amplitudes,target);
   else
      target_use = target;
   end
   
   slice_s = cur_rs.replicated_slice; %NEURON.reproductions.Hokanson_2013.activation_volume_slice
   [~,h1] = contour(ax(1),slice_s.xyz{1},slice_s.xyz{2},slice_s.thresholds',[target_use target_use]);
   set(h1,'Color',color_order(iObj,:));
   
   slice_d = cur_rd.slice;
   [~,h2] = contour(ax(2),slice_d.xyz{1},slice_d.xyz{2},slice_d.thresholds',[target_use target_use]);
   set(h2,'Color',color_order(iObj,:));
end

NEURON.sl.plot.postp.makeDimsEqual(ax,'xy');
linkaxes(ax,'xy')
axis(ax,'image'); 
   
    
end