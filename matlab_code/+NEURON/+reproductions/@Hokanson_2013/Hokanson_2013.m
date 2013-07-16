classdef Hokanson_2013
    %
    %   Work on my unpublished stimulus interaction paper.
    %
    %   See Also:
    %   NEURON.reproductions.Hokanson_2013.activation_volume_requestor
    %   NEURON.reproductions.Hokanson_2013.activation_volume_results
        
    properties (Constant)
        %MRG Diameters:
        %[5.7, 7.3, 8.7, 10, 11.5, 12.8, 14, 15, 16;]; %These are all the 
        %discrete diameters implemented in the original model.
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
        figure2()
        figure3()
        respondsAtHighStimulusTest()
        accuracyTest()
        refractoryPeriodTest()
    end
    
    %In other files
    %===============================
    %example_figure_1
    
    
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
           
           %The goal is to go from an element like:
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
           %        Class: 
           %    rs : cell array of objects
           %    rd : cell array of objects ...
           %
           %    Crap, how to determine overlap for 2 electrodes ...
           
           FONT_SIZE = 18;
            
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

