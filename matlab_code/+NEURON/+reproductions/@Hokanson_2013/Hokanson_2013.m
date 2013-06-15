classdef Hokanson_2013
    %
    %
    %   Work on my unpublished stimulus interaction paper.
    %
    
    properties
        
    end
    
    properties (Constant)
        %MRG Diameters ...
        %ALL_DIAMETERS = [5.7, 7.3, 8.7, 10, 11.5, 12.8, 14, 15, 16;];
        ALL_DIAMETERS = [5.7, 7.3 8.7, 10, 12.8, 15];
        ALL_ELECTRODE_PAIRINGS = {
            [0 0 0]                          %Centered Electrode
            [-700   0   0;  700  0   0]      %Transverse pairing
            [-600   0   0;  600  0   0]      %3 3x
            [-500   0   0;  500  0   0]      %4
            [-400   0   0;  400  0   0]      %5 2x
            [-300   0   0;  300  0   0]      %6
            [-200   0   0;  200  0   0]      %7 x - standard width (400 um)
            [-100   0   0;  100  0   0]      %8
            [0    -100 -400; 0   100 400]    %Longitudinal pairing
            [0    -50  -200; 0   50  200]    %
            [0    -25  -100; 0   25  100]    %
            [-200 -50  -200; 200 50 200]     %Diagonal pairing
            }
        
        %NOTE: Ideally this would be self generated ...
        ELECTRODE_PAIRING_DESCRIPTIONS = {
            'Centered Electrode'
            '800 apart X'
            '400 apart X'
            '200 apart X'
            '800 apart Z, 200 Y'
            '400 apart Z, 100 Y'
            '200 apart Z, 50 Y'
            '400 apart X, 400 apart Z, 100 apart Y'
            }
        TISSUE_RESISTIVITY = [1211 1211 175]
        %TISSUE_RESISTIVITY = 500;
        %TISSUE_RESISTIVITY = [1211 1211 350];
        %TISSUE_RESISTIVITY = [1211 1211 87.5];
    end
    
    methods (Static)
        run()
        figure0()
        figure1()
        figure2()
        figure3()
        respondsAtHighStimulusTest()
        accuracyTest()
        refractoryPeriodTest()
    end
    
    methods
         function example_figure(obj)
            
            %Create NEURON model, show applied stimuli
            %and show stimulus results ...
            
            STIM_AMPLITUDE = 5;
            CELL_XYZ = [100 0 300];
            E1       = [-200 0 0];
            E2       = [200  0 0];
            MAX_Z    = 2000;
            MIN_Z    = 2000;
            
            %Threshold 4.91
            %Use 5 uA as an example ...

            figure
            %r = xstim.sim__determine_threshold(1);
            
            %This should generate 3 plots:
            %1) the left electrode
            %2) the right electrode
            %3) both electrodes together
            
            %REDO with nodes of Ranvier and dots for discrete locations of
            %the cable
            
            for iElec = 1:3
                if iElec == 1
                    loc = E1;
                    title_str = 'Stimulus at x = -200 (um)';
                elseif iElec == 2
                    loc = E2;
                    title_str = 'Stimulus at x = 200 (um)';
                else 
                    loc = [E1; E2];
                    temp_ca   = num2cell(CELL_XYZ);
                    title_str = sprintf('Stimulus at both sites, cell at [%d, %d, %d]',temp_ca{:});
                end
                
                title_str = sprintf('%d uA %s',STIM_AMPLITUDE,title_str);
                
                xstim = instantiateXstim(obj,loc);
            
                xstim.cell_obj.moveCenter(CELL_XYZ) 
                
                subplot(2,3,iElec)
                set(gca,'FontSize',18) 
                xstim.plot__AppliedStimulus(STIM_AMPLITUDE);
                set(gca,'YLim',[-25 0],'XLim',[-15 15])
                
                title(title_str)
                
                r = xstim.sim__single_stim(STIM_AMPLITUDE);
                subplot(2,3,iElec+3)
                set(gca,'FontSize',18)
                r.plot__singleSpace(11);
                set(gca,'YLim',[-90 30],'XLim',[0 1.1])
            end
            
            figure
            %TODO: Make this a method (for plotting spatial layout of cell)
            %--------------------------------------------------------------
            %- expose "up to date" methods for each object for syncing
            %NEURON and Matlab
            %- require a section list that matches xyz_all
            %- in NEURON grab stuff and return to Matlab
            
            
            
            scatter([-200 200],[0 0],100,'filled')
            node_z = CELL_XYZ(3)-1150*2*1150*cell_XYZ(3)+1150*2;
            node_z(node_z < MIN_Z & node_z < MAX_Z) = [];
            scatter(CELL_XYZ(1)*ones(1,length(node_z)),node_z,100,'filled')
            line([CELL_XYZ(1) CELL_XYZ(1)],[MIN_Z MAX_Z],'Linewidth',3)
%             line([100 100],[2 1150],'Linewidth',3)
%             line([100 100],[-1150 -2],'Linewidth',3)
            set(gca,'FontSize',18)
            title('Spatial layout of 10 um diameter fiber with 2 electrodes at x = [-200 200], cell at x = 100, node at z = 0')
            xlabel('X')
            ylabel('Z')
            axis equal
            
            %TODO: Add stimulus timing plots ...
                        
        end 
    end
    methods (Access = private,Hidden)
        function xstim = instantiateXstim(obj,electrode_locations)
            options = {...
                'electrode_locations',electrode_locations,...
                'tissue_resistivity',obj.TISSUE_RESISTIVITY};
            xstim = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
        end
        function plotLimits(obj,x_points,y_points)
            chars    = 'xzXZ';
            colors   = 'rgbc';
            symbol   = 'ospd';
            %X_OFFSET =
            %TODO: Add dots at points instead of letters for better
            %resolution
            hold on
            for iVal = 1:4
                h = scatter(x_points(iVal),y_points(iVal),300,colors(iVal),'filled',symbol(iVal));
                s = text(x_points(iVal),y_points(iVal),chars(iVal));
                set(s,'FontSize',18)
                
            end
        end
        function [x_lim__amp,z_lim__amp,x_lim__y_val,z_lim__y_val] = ...
                getLimitInfo(obj,stim_amps,y_values,threshold_matrix,xyz,internode_length)
            %
            %    [x_lim__amp,z_lim__amp,x_lim__y_val,z_lim__y_val] = ...
            %            getLimitInfo(obj,stim_amps,y_values,threshold_matrix,xyz,internode_length)
            %
            
            %NOTE: We need to get the threshold values at the internode
            %spacing, not at the bounds of the inputs ...
            
            %TODO: Clean this up
            %The inputs should really be 3d unless y = 0 is the value
            %passed in
            %In the current code it is, but this is very sloppy
            
            %Assume y = 0 ...
            %Squeeze results ...
            
            %TODO: Run
            z_max   = floor(internode_length/2);
            z_range = -z_max:z_max;
            
            %Get minimum at x = 0
            %i.e. what is the lowest threshold where the x-limit comes into
            %play
            x_lim__amp = min(interpn(xyz{1},xyz{3},squeeze(threshold_matrix),0,z_range));
            
            %Get minimum at z = z_max
            z_lim__amp = min(interpn(xyz{1},xyz{3},squeeze(threshold_matrix),xyz{1},z_max));
            
            x_lim__y_val = interp1(stim_amps,y_values,x_lim__amp);
            z_lim__y_val = interp1(stim_amps,y_values,z_lim__amp);
            
        end
    end
    
end

