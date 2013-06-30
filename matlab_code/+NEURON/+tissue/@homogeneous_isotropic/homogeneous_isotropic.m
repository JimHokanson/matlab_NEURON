classdef homogeneous_isotropic < NEURON.tissue
    %
    %   CLASS: NEURON.tissue.homogeneous_isotropic
    
    properties
        resistivity
    end
    
    %SET METHODS    =================================================
    methods
        function set.resistivity(obj,value)
            if isempty(value)
                obj.resistivity = [];
            elseif length(value) == 1
                obj.resistivity = value;
            else
                error('resistivity must be a single value for a homogenous-isotropic tissue medium')
            end
        end
    end
    
    methods
        function obj = homogeneous_isotropic(resistivity)
            obj.resistivity = resistivity;
        end
        function v_ext = computeAppliedVoltageToCellFromElectrode(obj,cell_xyz_all,elec_xyz,I_stim)
            %computeIsoField  Computes voltage in isotropic field
            %
            %     v_ext = extracellular_stim.computeIsoField(rho,xyz_all,elec_xyz,I_stim)
            
            
            r = pdist2(cell_xyz_all,elec_xyz);
            
            %Ensure sizes for bsxfun and subsequent linearization of v_ext
            if size(I_stim,2) > 1
                I_stim = I_stim';
            end
            
            if size(r,1) > 1
                r = r';
            end
            
            scale_factor = 10*obj.resistivity/(4*pi);
            
            v_ext = bsxfun(@rdivide,I_stim.*scale_factor,r);
        end
        function logger = getLogger(obj)
            logger = NEURON.tissue.homogeneous_isotropic.logger.getInstance(obj);
        end
    end
end

