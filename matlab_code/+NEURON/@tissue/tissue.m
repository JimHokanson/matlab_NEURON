classdef tissue < handle
    %
    %   CLASS: NEURON.tissue
    %
    %   Abstract class.
    %
    %   
    %
    %   KNOWN IMPLEMENTATIONS
    %   NEURON.tissue.homogeneous_anisotropic
    %   NEURON.tissue.homogeneous_isotropic
    
    properties
       configuration = 1;
    end
    
    %MAIN ACCESS METHOD
    %======================================================================
    methods (Static)
        function obj = createHomogenousTissueObject(resistivity)
           if length(resistivity) == 1
               obj = NEURON.tissue.homogeneous_isotropic(resistivity);
           else
               obj = NEURON.tissue.homogeneous_anisotropic(resistivity);
           end
        end
    end
    
    methods (Abstract)
        %NOTE: I put this here because I think of the tissue as being a
        %transfer function class, it connects the electrode and the cell
        %together...
        v_ext = computeAppliedVoltageToCellFromElectrode(obj,cell_xyz_all,elec_xyz,I_stim)
    end
    
    methods
        function [hasChanged,latest_configuration] = hasConfigurationChanged(obj,lastConfiguration)
           latest_configuration = obj.configuration;
           if isempty(lastConfiguration)
               hasChanged = true;
           else
               hasChanged = obj.configuration ~= lastConfiguration;
           end
        end
    end
    
end

