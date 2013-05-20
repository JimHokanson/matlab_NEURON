classdef Hokanson_2013
    %
    %
    %   Work on my unpublished stimulus interaction paper.
    %
    %
    % Result 1 – Two electrodes, different configurations (transverse, longitudinal, diagonal),
    %       standard pulse width, same diameter
    % Result 2 – different diameters, same pulse width, plot versus distance in transverse and longitudinal
    % This is the main figure …
    % Result 2.5 – population result, all diameters combined ala Bourbeau 2011
    % Result 3 – Changing pulse widths, use comparisons normalized to recruitment volume with a single electrode
    % Result 4 – More than 2 electrodes?
    % Result 5 – resistivity plot, influence of resistivity …
    
    properties
        
    end
    
    properties (Constant)
        %MRG Diameters ...
        %ALL_DIAMETERS = [5.7, 7.3, 8.7, 10, 11.5, 12.8, 14, 15, 16;];
        ALL_DIAMETERS = [5.7, 8.7, 10, 12.8, 15];
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
        figure0()
        figure1()
        figure2()
        figure3()
    end
    
    methods (Access = private,Hidden)
        function plotLimits(obj,x_points,y_points)
            chars    = 'xzXZ';
            %X_OFFSET = 
            %TODO: Add dots at points instead of letters for better
            %resolution
            for iVal = 1:4
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

