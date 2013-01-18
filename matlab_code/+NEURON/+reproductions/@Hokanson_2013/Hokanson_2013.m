classdef Hokanson_2013
    %
    %
    %   Work on my unpublished stimulus interaction paper.
    %
    
    properties
        
    end
    
    properties (Constant)
       ALL_ELECTRODE_PAIRINGS = {
           [-200 0 0; 200 0 0] %Transverse pairing
           [0 0 0]             %Longitudinal pairing
           [0 0 -200; 0 0 200] %Longitudinal pairing
           [-200 0 -200; 200 0 200]
           }
       TISSUE_RESISTIVITY = [1211 1211 175]
    end
    
    methods (Static)
        function create_log_data()
           
           %NEURON.reproductions.Hokanson_2013.create_log_data
           
           obj = NEURON.reproductions.Hokanson_2013;
           
           n_electrode_pairings = length(obj.ALL_ELECTRODE_PAIRINGS);
            
           
           for iPair = 1:n_electrode_pairings
              options = {...
               'electrode_locations',obj.ALL_ELECTRODE_PAIRINGS{iPair},... 
               'tissue_resistivity',obj.TISSUE_RESISTIVITY};
               xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
               xstim_obj.sim__create_logging_data;
           end
           
           
           
%            %Two Electrodes - 400 apart in X 
%            
%            
%            
%            
%            %Single Electrode
%            options = {...
%                'electrode_locations',[0 0 0]};
%            xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
%            xstim_obj.sim__create_logging_data;
%            
%            %Two Electrodes Longitudinal
%                       options = {...
%                'electrode_locations',[0 0 -200; 0 0 200]};
%            xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
%            xstim_obj.sim__create_logging_data;
%            
%            options = {...
%                'electrode_locations',[-200 0 -200; 200 0 200]};
%            xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
%            xstim_obj.sim__create_logging_data;
        end
    end
    
end

