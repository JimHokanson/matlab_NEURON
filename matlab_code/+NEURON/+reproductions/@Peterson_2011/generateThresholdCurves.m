function generateThresholdCurves(obj)

tissue_resistivity = [obj. resistivity_transverse obj. resistivity_transverse obj.resistivity_longitudinal];

EAS = [5:1:200,210:10:1000]; % y_vals

z_internode_shift = 0:0.01:0.5; % move over an entire internodal space

nY = length(EAS);
nZ = length(z_internode_shift);

% start with 20 us pulse
%stim_duration_all = obj.all_pulse_durations;
stim_duration_all = 0.02;
stim_start_time = 0.1;
stim_amp = -1;

%fiber_diameter_all = obj.all_fiber_diameters;
fiber_diameter_all = 10;

for iPW = 1:length(stim_duration_all)
    stim_duration = stim_duration_all(iPW);
    for iFD = 1:length(fiber_diameter_all)
        fiber_diameter = fiber_diameter_all(iFD);
        
        xstim = NEURON.simulation.extracellular_stim.create_standard_sim('tissue_resistivity',tissue_resistivity,'electrode_locations',[0 0 0]); % placed at origin, cell will be moved away
        xstim.elec_objs.setStimPattern(stim_start_time,stim_duration,stim_amp);
        cell = xstim.cell_obj;
        cell.props_obj.changeFiberDependencyMethod(2); % regression dependency
        cell.props_obj.changeFiberDiameter(fiber_diameter);
        
        internode_length = cell.props_obj.internode_length;
        z_vals = z_internode_shift*internode_length; % z_vals based on internode length
        
        N_nodes = size(cell.spatial_info_obj.get__XYZnodes,1);
        i_center_node = ceil(N_nodes/2);
        
        % generate large list of voltage vectors
        
        all_locations = {0 EAS z_vals};
        xyz_all_locs = cell.getCellXYZMultipleLocations(all_locations); % n_cells x n_nodes x 3
        sz = size(xyz_all_locs);
        xyz_computeStim = reshape(xyz_all_locs,[sz(1)*sz(2) sz(3)]);% (n_cells*n_nodes) x 3
        xyz_centers = squeeze(xyz_all_locs(:,i_center_node,:));
        
        [t_vec,v_all] = xstim.computeStimulus(...
            'remove_zero_stim_option',1,...
            'xyz_use',xyz_computeStim);
        
        v_all = v_all';
        
        applied_stimulus = reshape(v_all,[sz(1) sz(2)*size(v_all,2)]); % n_cells x n_nodes
        
        Ve = applied_stimulus(:,i_center_node);
        D2Ve = applied_stimulus(:,i_center_node - 1) - 2*Ve + applied_stimulus(:,i_center_node+1);
        VeD2Ve = [Ve,D2Ve]; % N_locations x 2
        
        % Range of Ve and D2Ve we want thresholds for
        test_Ve = [0:-.1:-1.9,-2:-10:-500];
        test_D2Ve = [linspace(0,3.7,20),linspace(7.3,180,50)];
        %test_Ve = linspace(0,-500,50);
        %test_D2Ve = linspace(0,180,50);
        %test_VeD2Ve = [test_Ve(:),test_D2Ve(:)];
        [X,Y] = meshgrid(test_Ve,test_D2Ve);
        test_VeD2Ve = [X(:),Y(:)];
        
        idx = knnsearch(VeD2Ve,test_VeD2Ve);
        
        cell_locs_use = xyz_centers(idx,:);
        VeD2Ve_use = VeD2Ve(idx,:);
        
        thresholds = xstim.sim__getThresholdsMulipleLocations(cell_locs_use);
        
        % plot
        figure
        v1 = VeD2Ve_use(:,1).*thresholds';
        ve_threshold = -v1;
        md1_threshold = VeD2Ve_use(:,2).*thresholds';
        plot(ve_threshold,md1_threshold,'o','markersize',10)
        fontsize = 18;
        xlabel('Peak Extracellular Voltage (V_e) [-mV]','fontsize',fontsize)
        %ylabel('Second Nodal Difference (\Delta^2V_e) [mV]','fontsize',fontsize)
        ylabel('MDF_1 [mV]','fontsize',fontsize)
        title(['Pulse Duration = ',num2str(stim_duration*1e3),' \mus diameter = ',num2str(fiber_diameter),' \mum'],'fontsize',fontsize + 2)
        set(gca,'fontsize',fontsize+2,'YLim',[0 180],'XLim',[0 500])
        
        % mdf2
        applied_stim_use = applied_stimulus(idx,:);
        N_stim = length(idx);
        mdf2_threshold = zeros(N_stim,1);
        for iStim = 1:N_stim;
            stimulus = applied_stim_use(iStim,:).*thresholds(iStim);
            mdf2_threshold(iStim) = obj.computeMDF2(stimulus,stim_duration,fiber_diameter,11);
        end
        
        % plot
        figure
        plot(ve_threshold,mdf2_threshold,'o','markersize',10)
        fontsize = 18;
        xlabel('Peak Extracellular Voltage (V_e) [-mV]','fontsize',fontsize)
        %ylabel('Weighted Sum Function Output','fontsize',fontsize)
        ylabel('MDF_2','fontsize',fontsize)
        title(['Pulse Duration = ',num2str(stim_duration*1e3),' \mus diameter = ',num2str(fiber_diameter),' \mum'],'fontsize',fontsize + 2)
        set(gca,'fontsize',fontsize+2,'XLim',[0 500])
        
    end
end
keyboard
end