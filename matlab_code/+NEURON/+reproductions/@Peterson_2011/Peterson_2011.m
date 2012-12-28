classdef Peterson_2011
    %
    %   Class: NEURON.reproductions.Peterson_2011
    %   
    
    
    %Abbreviations:
    %EAS
    %MDF
    
    properties
       all_fiber_diameters = 4:20 %microns
       all_pulse_durations = [0.01 0.02 0.05 0.1 0.5 1 2 5] %ms
       %Careful: the stimulus specification code expects microseconds
       
       %NOTE: Nodes are 
       mdf2 %pulse duration, diameter, node
       %Model expects 21 nodes ...
       
       %Precomputed for us
       %.diameter
       %.pulse duration
       %.ve
       %.mdf_output
       mdf1_thresholds
       mdf2_thresholds
    end
    
    methods
        %NEURON.reproductions.Peterson_2011
        function obj = Peterson_2011
           %TODO: Populate mdf2 
           %
           %    obj = NEURON.reproductions.Peterson_2011;
           
        end
        function options = getElevenElectrodeStimOptions(obj,adjacent_spacing,stim_duration)
           %See page 4
           %Adjacent electrode spacing - 400:100:1500 um
           %EAS held at 200 um
           
           EAS = 200;
           STIM_START_TIME = 0.1;
           
           stim_scales  = [0.4 -1 0.7 -1 0.7 -1 0.7 -1 0.7 -1 0.4];
           stim_centers = -adjacent_spacing*5:adjacent_spacing:adjacent_spacing*5;
           
           electrode_locations = zeros(11,3);
           electrode_locations(:,1) = EAS;
           electrode_locations(:,3) = stim_centers;
           
           options = {...
               'electrode_locations',   electrode_locations,...
               'stim_scales',           num2cell(stim_scales),...
               'stim_durations',        num2cell(stim_duration*ones(1,11)),...
               'stim_start_times',      STIM_START_TIME*ones(1,11)};
           
        end
        function figure7(obj)
           %7a not yet implemented ...
           
           
           %FIGURE 7B
           %===============================================================
           stim_options = getElevenElectrodeStimOptions(obj,500,1);
           all_options = [stim_options 'cell_center' [0 0 0]];
           xstim = NEURON.simulation.extracellular_stim.create_standard_sim(all_options{:});
           xstim.plot__AppliedStimulus(1);
           
        end
    end
    
end

