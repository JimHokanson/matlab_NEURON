classdef intracellular_stim < NEURON.simulation
    %
    %   Class:
    %       NEURON.simulation.intracellular_stim
    %
    %
    %   OUTLINE
    %   -------------------------------------------------------------------
    %   1) Create cell
    %   2) place electrodes - single electrode for now ... ?
    %           - how to handle location
    %
    %
    %   TODO:
    %   --------------------------------------------------------
    
    
    properties
        cell_obj
        elec_obj
    end
    
    methods (Access = private)
        function obj = intracellular_stim(istim_options)
            %
            %
            %
            %
            
            if ~exist('istim_options','var')
                istim_options = NEURON.simulation.intracellular_stim.options;
            end
            
            obj@NEURON.simulation(istim_options);
        end
        function init__simulation(obj)
           %1) Create cell
           %2) Create stimulation info
        end
    end
    
    methods (Static)
        function obj = create_standard_sim(varargin)
            
            
            in.istim_options = NEURON.simulation.intracellular_stim.options;
            
            
            in = NEURON.sl.in.processVarargin(in,varargin);
            
            obj = NEURON.simulation.intracellular_stim(in.istim_options);
            
            
        end
    end
    
end

