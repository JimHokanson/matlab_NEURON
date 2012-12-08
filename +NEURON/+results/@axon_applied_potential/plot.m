function plot(obj)
%JAH TODO: Add left hand side that summarizes electrodes ...

%link axes
nTimes = length(obj.t_vec);
ax = zeros(1,nTimes);
mn = min(obj.applied_potential(:));
mx = max(obj.applied_potential(:));
for iTime = 1:nTimes
    ax(iTime) = subplot(nTimes,1,iTime);
    plot(obj.xyz_axon(:,3),obj.applied_potential(iTime,:));
    set(gca,'XLim',obj.z_lim,'YLim',[mn mx]);
end
linkaxes(ax);
end