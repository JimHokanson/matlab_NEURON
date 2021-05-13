classdef homogeneous_isotropic < NEURON.tissue
    %
    %   Class: 
    %   NEURON.tissue.homogeneous_isotropic
    %
    %   See Also
    %   --------
    %   NEURON.tissue.homogeneous_anisotropic
    %   NEURON.tissue.homogeneous_isotropic.logger
    
    properties
        resistivity %ohm-cm
        scale_type = 0
        %0 - full sphere
        %1 - half sphere
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
            
            %
            %   - applied potential =   rho*I
            %                         ---------
            %                         4*pi*dist
            %   
            %   Units
            %   -----
            %
            %                   Convert numerator to um
            %
            %   ohm-cm * uA     uV-cm
            %   -----------  => -----  Goal convert to mV
            %       um           um   
            %
            %   uV*cm   10000 um     1 mV        
            %   ----- * -------   * -------   =>  10*value => mV
            %    um       1 cm      1000 uV
            %
            
            
            r = pdist2(cell_xyz_all,elec_xyz);
            
            %Ensure sizes for bsxfun and subsequent linearization of v_ext
            if size(I_stim,2) > 1
                I_stim = I_stim';
            end
            
            if size(r,1) > 1
                r = r';
            end
            
            if obj.scale_type == 0
                scale_factor = 10*obj.resistivity/(4*pi);
            elseif obj.scale_type == 1
                scale_factor = 10*obj.resistivity/(2*pi);
            else
                error('unexpected scale type') 
            end
            
            v_ext = bsxfun(@rdivide,I_stim.*scale_factor,r);
        end
        function logger = getLogger(obj)
            logger = NEURON.tissue.homogeneous_isotropic.logger.getInstance(obj);
        end
    end
end

