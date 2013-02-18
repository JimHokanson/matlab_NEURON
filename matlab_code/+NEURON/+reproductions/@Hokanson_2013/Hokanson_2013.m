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
        %ALL_DIAMETERS = [5.7, 7.3, 8.7, 10, 11.5, 12.8, 14, 15, 16;];
        ALL_DIAMETERS = [5.7, 8.7, 10, 12.8, 15];
        ALL_ELECTRODE_PAIRINGS = {
            [0 0 0]                          %1) Centered Electrode
            [-400   0   0;  400  0   0]      %2) Transverse pairing
            [-200   0   0;  200  0   0]      %3)
            [-100   0   0;  100  0   0]      %4)
            [0    -100 -400; 0   100 400]    %5) Longitudinal pairing
            [0    -50  -200; 0   50  200]    %6)
            [0    -25  -100; 0   25  100]    %7)
            [-200 -50  -200; 200 50 200]     %8) Diagonal pairing
            }
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
    end
    
    methods (Static)
        function figure0()
            %Steup figure, do later ...
            %Thresholds in 3d (circle size and color is threshold)
            %Do for both a two electrode case and the single electrode case
            %Or do one for one and one for the other ...
        end
        
        figure1()
        figure2()
        figure3()
        
        %------------------------------------------------------------------
        
        function create_log_data()
            
            %NEURON.reproductions.Hokanson_2013.create_log_data
            
            obj = NEURON.reproductions.Hokanson_2013;
            
            %             n_electrode_pairings = length(obj.ALL_ELECTRODE_PAIRINGS);
            %             for iPair = 1:n_electrode_pairings
            %                 for iDiameter = 1:length(obj.ALL_DIAMETERS)
            %                     current_diameter = obj.ALL_DIAMETERS(iDiameter);
            %                     fprintf('Running Pairing: %d\n',iPair);
            %                     fprintf('Current Diameter: %d\n',iDiameter);
            %                     options = {...
            %                         'electrode_locations',obj.ALL_ELECTRODE_PAIRINGS{iPair},...
            %                         'tissue_resistivity',obj.TISSUE_RESISTIVITY};
            %                     xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
            %                     cell_obj  = xstim_obj.cell_obj;
            %                     cell_obj.props_obj.changeFiberDiameter(current_diameter);
            %                     xstim_obj.sim__getThresholdsMulipleLocations({-500:20:500 -500:20:500 -500:20:500});
            %                 end
            %             end
            
            for iPair = [1 2 5]
                for iDiameter = [2 3 4]
                    for stim_width = [0.050 0.100 0.40]
                        current_diameter = obj.ALL_DIAMETERS(iDiameter);
                        fprintf('Running Pairing: %d\n',iPair);
                        fprintf('Current Diameter: %d\n',iDiameter);
                        options = {...
                            'stim_durations',[stim_width 2*stim_width],...
                            'electrode_locations',obj.ALL_ELECTRODE_PAIRINGS{iPair},...
                            'tissue_resistivity',obj.TISSUE_RESISTIVITY};
                        xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
                        cell_obj  = xstim_obj.cell_obj;
                        cell_obj.props_obj.changeFiberDiameter(current_diameter);
                        xstim_obj.sim__getThresholdsMulipleLocations({-500:20:500 -500:20:500 -500:20:500});
                    end
                end
            end
            
            %s = xstim_obj.sim__getLogInfo;
            %s.simulation_data_obj.fixRedundantOldData
            
            
        end
    end
    
    methods (Access = private,Hidden)
        function max_stim_level = getMaxStimLevelToTest(obj,current_electrode_pair,varargin)
            %getMaxStimLevelToTest
            %
            %
            
            in.current_diameter = [];
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

