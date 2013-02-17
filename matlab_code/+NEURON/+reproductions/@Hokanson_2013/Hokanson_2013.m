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
            [0 0 0]              	 %1) Centered Electrode
            [-200 0 0; 200 0 0]      %2) Transverse pairing
            [-400 0 0; 400 0 0]      %3)
            [-100 0 0; 100 0 0]      %4)
            [0 -100 -400; 0 100 400] %5) Longitudinal pairing
            [0 -50  -200; 0 50  200] %6)
            [0 -25  -100; 0 25  100] %7)
            [-200 0 -200; 200 0 200] %8) Diagonal pairing
            }
        %ELECTRODE_PAIRING_DESCRIPTIONS
        TISSUE_RESISTIVITY = [1211 1211 175]
    end
    
    methods (Static)
        function figure1()
            %
            %       NEURON.reproductions.Hokanson_2013.figure1
            
            %For right now stop at smallest amplitude in which the separate
            %electrodes would start to recruit the same neurons
            %This will always be at the bisection of the two
            
            obj = NEURON.reproductions.Hokanson_2013;
            
            single_electrode_location = obj.ALL_ELECTRODE_PAIRINGS{1};
            
            n_electrode_pairings = length(obj.ALL_ELECTRODE_PAIRINGS);
            
            max_stim_all = zeros(1,n_electrode_pairings);
            counts_all   = cell(1,n_electrode_pairings);
            
            %We start at 2 to ignore the 
            for iPair = 2:n_electrode_pairings
                
                current_pair = obj.ALL_ELECTRODE_PAIRINGS{iPair};
                
                %TODO: Get halfway distance
                
                
                
                %Determine max stimulus amplitude to test for this pair ...
                %----------------------------------------------------------
                %TODO: This should be a method
                %The goal here is to get the point at which a single
                %electrode would start to recruit a neighboring electrodes 
                %neurons, complicating the interpretation of the analysis
                %
                %Instead we stop the analysis at the point in which
                %independent populations would begin to overlap. This might
                %not be optimal in terms of recruitment but it simplifies
                %the analysis
                max_threshold_distance_vector = mean(current_pair) - current_pair(1,:);
                
                options = {...
                    'electrode_locations',single_electrode_location,...
                    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
                xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
                
                xstim_obj.cell_obj.moveCenter(max_threshold_distance_vector)
                
                %The 1 indicates the stimulus sign, which given the scale
                %factors means cathode stimulation
                temp_result = xstim_obj.sim__determine_threshold(1);
                
                max_stim_all(iPair) = floor(temp_result.stimulus_threshold);
                
                %Determine counts for electrode pairing given max stimulus
                options = {...
                    'electrode_locations',current_pair,...
                    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
                xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
                act_obj   = xstim_obj.sim__getActivationVolume();
                
                counts_all{iPair} = act_obj.getVolumeCounts(1:0.5:max_stim_all(iPair));
            end
            
            %Determining the "normalization factor"
            %--------------------------------------------------------------
            max_stim_test_single_electrode = max(max_stim_all);
            
            options = {...
                    'electrode_locations',single_electrode_location,...
                    'tissue_resistivity',obj.TISSUE_RESISTIVITY};
                xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
                act_obj   = xstim_obj.sim__getActivationVolume();
                
            counts_all{1} = act_obj.getVolumeCounts(1:0.5:max_stim_test_single_electrode);
            
            figure
            hold all
            for iPair = 2:n_electrode_pairings
               cur_counts = counts_all{iPair};
               n_cur_counts = length(cur_counts);
               x_stim       = (1:n_cur_counts)/2 + 0.5;
               plot(x_stim,cur_counts./(2*counts_all{1}(1:n_cur_counts)));
            end
            
            keyboard
            
            
        end
        %------------------------------------------------------------------
        function figure3()
            %
            %   NEURON.reproductions.Hokanson_2013.figure3
            %   
            
             obj = NEURON.reproductions.Hokanson_2013;

            
             for iPair = [1 2 5]
                for iDiameter = [2 3 4]
                    for stim_width = [0.050 0.100 0.2 0.40]
                        current_diameter = obj.ALL_DIAMETERS(iDiameter);
                        fprintf('Running Pairing: %d\n',iPair);
                        fprintf('Current Diameter: %d\n',iDiameter);
                        fprintf('Running Width: %g\n',stim_width);
                        options = {...
                            'stim_durations',[stim_width 2*stim_width],...
                            'electrode_locations',obj.ALL_ELECTRODE_PAIRINGS{iPair},...
                            'tissue_resistivity',obj.TISSUE_RESISTIVITY};
                        xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
                        cell_obj  = xstim_obj.cell_obj;
                        cell_obj.props_obj.changeFiberDiameter(current_diameter);
                        
                        act_obj   = xstim_obj.sim__getActivationVolume();
                
                        temp = act_obj.getVolumeCounts(1:0.5:30);
                        
                        
                        %xstim_obj.sim__getThresholdsMulipleLocations({-500:20:500 -500:20:500 -500:20:500});
                    end
                end
            end
            
        end
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
    
end

