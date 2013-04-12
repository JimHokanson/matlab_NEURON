classdef Peterson_2011
    %
    %   Class: NEURON.reproductions.Peterson_2011
    %   
    %   ??? - does this model support anodic excitation prediction?
    
    %Abbreviations:
    %EAS
    %MDF
    
    properties (Hidden)
        
       all_fiber_diameters = 4:20 %microns
       all_pulse_durations = [0.01 0.02 0.05 0.1 0.5 1 2 5] %ms
       %Careful: the stimulus specification code expects microseconds
       
       resistivity_transverse   = 100/0.083 % S/m -> ohm cm
       resistivity_longitudinal = 100/0.33
       
       %Precomputed for us
       %.diameter
       %.pulse duration
       %.ve
       %.mdf_output
       mdf1_thresholds
       mdf2_thresholds
    end
    
    properties (Hidden)
        
    end
    
    properties
       mdf1
       
       
       %NOTE: Nodes are 
       mdf2 %pulse duration, diameter, node
       %Model expects 21 nodes ... 
    end
    
    methods
        %NEURON.reproductions.Peterson_2011
        function obj = Peterson_2011
           %TODO: Populate mdf2 
           %
           %    obj = NEURON.reproductions.Peterson_2011;
           
           obj.loadCSVdata;
           
        end
        function options = getDefaultOptions(obj)
           options = {...
               'tissue_resistivity', [obj.resistivity_transverse obj.resistivity_transverse obj.resistivity_longitudinal]};
        end
        
        %This is old code that needs to be updated ...
        %-------------------------------------------------------------------
        function options = getElevenElectrodeStimOptions(obj,adjacent_spacing,stim_duration,eas)
           %See page 4
           %Adjacent electrode spacing - 400:100:1500 um
           %EAS held at 200 um
           
           %EAS = 200;
           STIM_START_TIME = 0.1;
           
           stim_scales  = [0.4 -1 0.7 -1 0.7 -1 0.7 -1 0.7 -1 0.4];
           stim_centers = -adjacent_spacing*5:adjacent_spacing:adjacent_spacing*5;
           
           electrode_locations = zeros(11,3);
           electrode_locations(:,1) = eas;
           electrode_locations(:,3) = stim_centers;
           
           options = {...
               'electrode_locations',   electrode_locations,...
               'stim_scales',           num2cell(stim_scales),...
               'stim_durations',        num2cell(stim_duration*ones(1,11)),...
               'stim_start_times',      STIM_START_TIME*ones(1,11)};
           
        end
        %OUT OF DATE ...
        function figure7(obj)
           %7a not yet implemented ...
           
           %10 um diameter fiber
           %NOTE: I Think at least 7b and 7c, maybe 
           %7a were done with a 8.7 um diameter fiber or
           %a 10 um diameter fiber with less than 20 internodes
           
           
           ADJACENT_ELECTRODE_SPACING_7b = 500;
           ADJACENT_ELECTRODE_SPACING_7c = 1000;
           EAS = 200;
           
           %FIGURE 7B
           %===============================================================
           adjacent_electrode_spacing = [ADJACENT_ELECTRODE_SPACING_7b ADJACENT_ELECTRODE_SPACING_7c];
           for iPlot = 1:2
              subplot(2,1,iPlot)
              stim_options = getElevenElectrodeStimOptions(obj,adjacent_electrode_spacing(iPlot),1,EAS);
              all_options = [stim_options obj.getDefaultOptions];
              xstim = NEURON.simulation.extracellular_stim.create_standard_sim(all_options{:});
              xstim.plot__AppliedStimulus(1);
           end
           
        end
    end
    
end

