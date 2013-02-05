classdef props < handle_light
    %
    %
    %   Class: NEURON.cell.axon.generic_unmyelinated.props
    %
    % Relevant NEURON files:
    % create_generic_axon.hoc - see method
    % NEURON.cell.axon.generic.createCellInNeuron()
    %
    %   NEURON UNITS
    %   =================================================
    %   Section Units
    %   L      - microns
    %   diam   - microns
    %   Ra     - ohm-cm
    
    properties (Hidden)
        parent % Class: NEURON.cell.axon.generic_unmyelinated
        spatial_obj % Class: NEURON.cell.axon.generic_unmyelinated.spatial_info
        axon_dynamics
    end
    
    properties (Constant)
        MEMBRANE_DYNAMICS_OPTIONS = {'hh' 'fh'} %etc
    end
    
    properties
        props_up_to_date_in_NEURON = false
        
        membrane_dynamics = 'hh';
        axon_capacitance  = 1 % (uF/cm2)
        axial_resistivity = 110 % (ohm-cm)
        axon_length       = 20000 % um = 20 mm
        axon_diameter     = 10 % um
        n_segs            = 500
    end
    
    methods
        function obj = props(parent_obj,spatial_info_obj)
            obj.parent = parent_obj;
            obj.spatial_obj = spatial_info_obj;
            obj.populateDependentVariables();
        end
        
        function set.membrane_dynamics(obj,value)
            obj.membrane_dynamics = value;
        end
        function populateDependentVariables(obj)
            obj.axon_dynamics = find(strcmpi(obj.MEMBRANE_DYNAMICS_OPTIONS,obj.membrane_dynamics));
            if isempty(obj.axon_dynamics)
                error('membrane_dynamics invalid')
            end
            
            obj.props_up_to_date_in_NEURON = false;
            obj.spatial_obj.spatialPropsChanged();
            obj.parent.props_populated = true;
        end
        
    end
    
    methods
        function setPropsByPaper(obj,paper_option)
            switch paper_option
                case 'Rattay_1987'
                    %SIM PROPS
                    %temp = 27
                    %
                    %TISSUE PROPS
                    %resistivity - 300
                    %
                    %STIM PROPS
                    %stim pulse - 0.1 ms long, cathodal (negative), monophasic
                    
                    obj.membrane_dynamics = 'hh';
                    obj.axon_capacitance = 1; % uF/cm^2
                    obj.axial_resistivity = 100;
                    obj.axon_diameter = 9.6; % 38.4 um also used
                otherwise
                    error('Option not yet implemented')
            end
        end
    end
    
    
end
