function figure0()
%
%   NEURON.reproductions.Hokanson_2013.figure0
%
%
    %Steup figure, do later ...
    %Thresholds in 3d (circle size and color is threshold)
    %Do for both a two electrode case and the single electrode case
    %Or do one for one and one for the other ...
    
    %1 - show electrodes and thresholds as points
    %2 - show interpolation, slice
    %3 - diagram explaining single stim expansion
    %4 - counting without double counting neurons
    
    
    
   obj = NEURON.reproductions.Hokanson_2013;
    
    current_pair = obj.ALL_ELECTRODE_PAIRINGS{6};
    
    CLIM_MAX = 20;
    XLIM = [-800 800];
    YLIM = [-200 200];
    
    %Let's do 2 electrodes 200 um apart
    
        options = {...
        'electrode_locations',current_pair,...
        'tissue_resistivity',obj.TISSUE_RESISTIVITY};
        xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

        
        xyz_mesh = {-200:20:200 -200:20:200 -660:20:660};
        
        thresholds = xstim_obj.sim__getThresholdsMulipleLocations(xyz_mesh);
        
  
        options = {...
        'electrode_locations',[0 0 0],...
        'tissue_resistivity',obj.TISSUE_RESISTIVITY};
        xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});

        %TODO: Shift thresholds to be on the one pair, crop results ....       
        thresholds2 = xstim_obj.sim__getThresholdsMulipleLocations(xyz_mesh);
        
        
        
        
%         scatter3(X(:),Y(:),Z(:),3*thresholds(:),thresholds(:),'filled')
%         axis equal
        subplot(3,1,1)
        cla
        imagesc(xyz_mesh{3},xyz_mesh{2},squeeze(thresholds(11,:,:)))
        axis equal
        hold on
        scatter(current_pair(:,3),current_pair(:,2),200,'w','filled')
        colorbar

        set(gca,'CLim',[0 CLIM_MAX]);
        set(gca,'XLim',XLIM,'YLim',YLIM)
        set(gca,'XDir','reverse','YDir','normal')
        %set(gca,'XLim'
        
        subplot(3,1,2)
        cla
        z_indices = 14:54;
        imagesc(xyz_mesh{3}(z_indices)+200,xyz_mesh{2}+50,squeeze(thresholds2(11,:,z_indices)))
        axis equal
        hold on
        scatter(current_pair(2,3),current_pair(2,2),200,'w','filled')
        scatter(0,0,100,'w','filled','^')
        colorbar
        set(gca,'XLim',XLIM,'YLim',YLIM)
        set(gca,'CLim',[0 CLIM_MAX]);
        set(gca,'XDir','reverse','YDir','normal')
        
        subplot(3,1,3)
        cla
        [X,Y,Z] = meshgrid(xyz_mesh{3},xyz_mesh{1},xyz_mesh{2});
        p = patch(isosurface(X,Y,Z,permute(thresholds,[2 3 1]),3.5));
        set(p, 'FaceColor','r', 'EdgeColor','none')
        alpha(p,0.25)
        axis equal
        [X2,Y2,Z2] = meshgrid(xyz_mesh{3}(z_indices),xyz_mesh{1},xyz_mesh{2});
        p2 = patch(isosurface(X2+200,Y2+50,Z2,permute(thresholds2(:,:,z_indices),[2 3 1]),3.5));
        p3 = patch(isosurface(X2-200,Y2-50,Z2,permute(thresholds2(:,:,z_indices),[2 3 1]),3.5));
        set(gca,'XDir','reverse')
        set(gca,'XLim',XLIM,'YLim',YLIM)
        keyboard

end