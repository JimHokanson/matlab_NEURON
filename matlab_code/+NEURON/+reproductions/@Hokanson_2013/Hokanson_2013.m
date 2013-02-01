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
            [0 0 0]              	%Centered Electrode
            [-200 0 0; 200 0 0]      %Transverse pairing
            [-400 0 0; 400 0 0]
            [-100 0 0; 100 0 0]
            %[0 0 -200; 0 0 200]
            [0 -100 -400; 0 100 400] %Longitudinal pairing
            [0 -50  -200; 0 50  200]
            [0 -25  -100; 0 25  100]
            [-200 0 -200; 200 0 200] %Diagonal pairing
            }
        TISSUE_RESISTIVITY = [1211 1211 175]
    end
    
    methods (Static)
        function create_log_data()
            
            %NEURON.reproductions.Hokanson_2013.create_log_data
            
            obj = NEURON.reproductions.Hokanson_2013;
            
            n_electrode_pairings = length(obj.ALL_ELECTRODE_PAIRINGS);
            for iPair = 1:n_electrode_pairings
                for iDiameter = 1:length(obj.ALL_DIAMETERS)
                    current_diameter = obj.ALL_DIAMETERS(iDiameter);
                    fprintf('Running Pairing: %d\n',iPair);
                    fprintf('Current Diameter: %d\n',iDiameter);
                    options = {...
                        'electrode_locations',obj.ALL_ELECTRODE_PAIRINGS{iPair},...
                        'tissue_resistivity',obj.TISSUE_RESISTIVITY};
                    xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
                    cell_obj  = xstim_obj.cell_obj;
                    cell_obj.props_obj.changeFiberDiameter(current_diameter);
                    xstim_obj.sim__getThresholdsMulipleLocations({-500:20:500 -500:20:500 -500:20:500});
                end
            end
            
            %s = xstim_obj.sim__getLogInfo;
            %s.simulation_data_obj.fixRedundantOldData
            
            
        end
    end
    
end

