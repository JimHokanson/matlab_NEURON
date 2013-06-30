classdef Hokanson_2013
    %
    %   Work on my unpublished stimulus interaction paper.
    %
    %   See Also:
    %   NEURON.reproductions.Hokanson_2013.activation_volume_requestor
    %   NEURON.reproductions.Hokanson_2013.activation_volume_results
        
    properties (Constant)
        %MRG Diameters:
        %[5.7, 7.3, 8.7, 10, 11.5, 12.8, 14, 15, 16;];
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
            [0    -175 -700; 0   175 700]    %9  Longitudinal pairing
            [0    -150 -600; 0   150 600]    %10
            [0    -125 -500; 0   125 500]    %11
            [0    -100 -400; 0   100 400]    %12
            [0    -75  -300; 0   75  300]    %13
            [0    -50  -200; 0   50  200]    %14
            [0    -25  -100; 0   25  100]    %15
            [-200 -50  -200; 200 50 200]     %Diagonal pairing
            }
        STANDARD_ELECTRODES_X = {[-200   0   0;  200  0   0]}
        STANDARD_ELECTRDOES_Z = {[0    -50  -200; 0   50  200]}
        %TODO:
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
        figure2(use_long)
        figure3(use_long)
        respondsAtHighStimulusTest()
        accuracyTest()
        refractoryPeriodTest()
    end
    
    methods
        function example_figure_2(obj)
           %Show recruitment redundancy ...
           
           %TODO: Might want to reduce resolution
           %file is really large ...
           X_VECTOR = -200:5:200;
           Z_VECTOR = -2000:5:2000;
           Y_VECTOR = 0;
           
           XYZ = {X_VECTOR Y_VECTOR Z_VECTOR};
           
           xstim = obj.instantiateXstim([0 0 0]);
           
           r = xstim.sim__getThresholdsMulipleLocations(XYZ);
           
           %Plotting results
           %-------------------------------------------------
           imagesc(X_VECTOR,Z_VECTOR,squeeze(r)');
           colorbar;
           axis equal
           hold on
           scatter(0,0,100,'w','filled')
           hold off
           
           temp = sl.plot.postp.imageToPatch(gcf,'ignore_colorbars',false);
           %print -depsc -painters wtf
           %MATLAB:hg:patch:RGBColorDataNotSupported
           
           keyboard
           
        end
         function example_figure_1(obj)
            
            %Create NEURON model, show applied stimuli
            %and show stimulus results ...
            
            STIM_AMPLITUDE = 5;
            CELL_XYZ = [100 0 300];
            E1       = [-200 0 0];
            E2       = [200  0 0];
            MAX_Z    = 2000;
            MIN_Z    = -2000;
            
            %Threshold 4.91
            %Use 5 uA as an example ...

            figure
            %r = xstim.sim__determine_threshold(1);
            
            %This should generate 3 plots:
            %1) the left electrode
            %2) the right electrode
            %3) both electrodes together
                        
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
            hold on
            %TODO: Make this a method (for plotting spatial layout of cell)
            %--------------------------------------------------------------
            %- expose "up to date" methods for each object for syncing
            %NEURON and Matlab
            %- require a section list that matches xyz_all
            %- in NEURON grab stuff and return to Matlab
            
            
            
            scatter([-200 200],[0 0],100,'filled')
            node_z = (CELL_XYZ(3)-1150*2):1150:(CELL_XYZ(3)+1150*2);
            node_z(node_z < MIN_Z | node_z > MAX_Z) = [];
            scatter(CELL_XYZ(1)*ones(1,length(node_z)),node_z,100,'filled')
            line([CELL_XYZ(1) CELL_XYZ(1)],[MIN_Z MAX_Z],'Linewidth',3)
%             line([100 100],[2 1150],'Linewidth',3)
%             line([100 100],[-1150 -2],'Linewidth',3)
            set(gca,'FontSize',18)
            title('Spatial layout of 10 um diameter fiber with 2 electrodes at x = [-200 200], cell at x = 100, node at z = 0')
            xlabel('X')
            ylabel('Z')
            axis equal
            hold off
            
            %TODO: Add stimulus timing plots ...
                        
        end 
    end
    methods (Hidden)
        function xstim = instantiateXstim(obj,electrode_locations)
            %
            %
            %
            options = {...
                'electrode_locations',electrode_locations,...
                'tissue_resistivity',obj.TISSUE_RESISTIVITY};
            xstim = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
        end 
    end
    methods (Access = private,Hidden)
        function final_strings = getElectrodeSeparationStrings(obj,electrode_locations)
           %If the dimension to use is empty, use all, if not 
           
           if ~iscell(electrode_locations)
               electrode_locations = cell(electrode_locations);
           end
           
           if any(cellfun(@(x) size(x,1) ~= 2,electrode_locations))
              error('Code only supports two electrodes') 
           end
           
           %The goal is to from from an element like:
           %[0 100 200; 0 -100 200] to
           %'200 y, 400 z'
           
           dx = cellfun(@(x) abs(x(1,1) - x(2,1)),electrode_locations);
           dy = cellfun(@(y) abs(y(1,2) - y(2,2)),electrode_locations);
           dz = cellfun(@(z) abs(z(1,3) - z(2,3)),electrode_locations);
           
           sx = arrayfun(@(x) sprintf('%d x',x),dx,'un',0);
           sy = arrayfun(@(y) sprintf('%d y',y),dy,'un',0);
           sz = arrayfun(@(z) sprintf('%d z',z),dz,'un',0);
           
           sx(dx == 0) = {''};
           sy(dy == 0) = {''};
           sz(dz == 0) = {''};
           
           final_strings = cellfun(@(x,y,z) sl.cellstr.join({x y z},'d',', ','remove_empty',true),sx,sy,sz,'un',0);
           
           
        end
        function plotVolumeRatio(obj,rs,rd,with_markup)
           %
           %    INPUTS
           %    ==========================================
           %    rs : cell array of objects
           %    rd : cell array of objects ...
           %
           %    Crap, how to determine overlap for 2 electrodes ...
           
                      FONT_SIZE = 18;
           keyboard 
            
           n_sets = length(rs);
           
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
              plot(stim_rs,vol_ratio,'Linewidth',3)
              if with_markup
                  
              end
           end
            

           
           set(gca,'FontSize',FONT_SIZE)
           xlabel('Stimulus Amplitude (uA)','FontSize',FONT_SIZE)
           ylabel('Volume Ratio','FontSize',FONT_SIZE)
        end
        function [xz_amp,xz_value] = getLimitAmplitudes(rs,rd,y_values)
           
            keyboard
            
        end
        function plotLimits(obj,xz_amp,xz_value)
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
    end
    
end

