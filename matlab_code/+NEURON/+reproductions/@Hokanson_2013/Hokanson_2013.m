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
        %TISSUE_RESISTIVITY = [1211 1211 175]
        %TISSUE_RESISTIVITY = 500;
        TISSUE_RESISTIVITY = [1211 1211 350];
    end
    
    methods (Static)
        figure0()
        figure1()
        figure2()
        figure3()
    end
    
    methods (Access = private,Hidden)
        function max_stim_level = getMaxStimLevelToTest(obj,current_electrode_pair,varargin)
            %getMaxStimLevelToTest
            %
            %   This is an old method which was used to determine the
            %   stimulus amplitude at which a neuron located halfway
            %   between two electrodes would be recruited if one of the
            %   electrodes were active. A new replication technique for
            %   single electrodes was added to the getVolumeCounts method
            %   of the activation_volume class, making this code obsolete.
            
            in.current_diameter = [];
            in.stim_width       = [];
            in = processVarargin(in,varargin);
            
            %The goal here is to get the point at which a single
            %electrode would start to recruit a neighboring electrodes
            %neurons, complicating the interpretation of the analysis
            %
            %Instead we stop the analysis at the point in which
            %independent populations would begin to overlap. This might
            %not be optimal in terms of recruitment but it simplifies
            %the analysis
            
            if size(current_electrode_pair,1) ~= 2
                error('Code expects two electrodes for pairing')
            end
            
            max_threshold_distance_vector = mean(current_electrode_pair) - current_electrode_pair(1,:);
            
            single_electrode_location = obj.ALL_ELECTRODE_PAIRINGS{1};
            
            %We expect that the single_electrode_location is centered.
            %We then move the cell to the desired location.
            options = {...
                'electrode_locations',single_electrode_location,...
                'tissue_resistivity',obj.TISSUE_RESISTIVITY};
            
            if ~isempty(in.stim_width)
               options = [options 'stim_durations' [in.stim_width 2*in.stim_width]];
            end
            
            xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
            
            xstim_obj.cell_obj.moveCenter(max_threshold_distance_vector)
            
            
            if ~isempty(in.current_diameter)
                cell_obj  = xstim_obj.cell_obj;
                cell_obj.props_obj.changeFiberDiameter(in.current_diameter);    
            end
            
            %The 1 indicates the stimulus sign, which given the scale
            %factors means cathode stimulation
            temp_result = xstim_obj.sim__determine_threshold(1);
            
            max_stim_level = floor(temp_result.stimulus_threshold);
        end
    end
    
end

