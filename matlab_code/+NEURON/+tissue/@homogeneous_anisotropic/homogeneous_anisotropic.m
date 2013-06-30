classdef homogeneous_anisotropic < NEURON.tissue
    %
    %   CLASS: NEURON.tissue.homogeneous_anisotropic
    %
    
    %NOTE: Could allow conductivity and then set to resistivity
    %or provide static method for converting
    
    properties
        resistivity  %Ensure on setting that it is a 3 element row vector
    end

    methods
        function obj = homogeneous_anisotropic(resistivity)
            if length(resistivity) ~= 3
                error('Invalid resisitivity, expecting 3 elements')
            end
            obj.resistivity = resistivity;
        end
        function v_ext = computeAppliedVoltageToCellFromElectrode(obj,cell_xyz_all,elec_xyz,I_stim)
            %computeAppliedVoltageToCellFromElectrode  Computes voltage in anisotropic field
            %
            %
            %   OUTPUTS
            %   ====================================================================
            %   v_ext : (   , units - mV)
            %
            %   INPUTS
            %   ====================================================================
            %   cell_xyz_all : [n x 3]
            %   elec_xyz     : [1 x 3]
            %
            %
            %   Callers:
            %   ??????
            %
            %   See Also:
            %       NEURON.simulation.extracellular_stim
            
            %      [resistivity]^0.5
            %  =      ------------
            %            4*pi
            
            %TODO: Document the 10 ...
            
            scale_factor = 10*sqrt(prod(obj.resistivity))/(4*pi);
            
            %TODO: Above would be better as:
            %=> 10 * sqrt(prod(obj.resistivity)
            
            %scale_factor = 10*obj.resistivity/(4*pi);
            
            %COMPUTING THE DISTANCE
            %-----------------------------------------------------------------------
            %[rho(1)*(x_a - x_e)^2 + rho(2)*(y_a - y_e)^2 + rho(3)*(z_a -z_e)^2]^0.5
            
            r = bsxfun(@minus,cell_xyz_all,elec_xyz).^2;
            %size n x 3
            r = sqrt(sum(bsxfun(@times,r,obj.resistivity),2));
            %size n x 1
            
            %COMBINING EVERYTHING
            %------------------------------------------------------------------------
            if size(I_stim,2) > 1
                I_stim = I_stim';
            end
            
            v_ext = bsxfun(@rdivide,I_stim.*scale_factor,r');
            
        end
        function logger = getLogger(obj)
            logger = NEURON.tissue.homogeneous_anisotropic.logger.getInstance(obj);
        end
        
    end
end
    
