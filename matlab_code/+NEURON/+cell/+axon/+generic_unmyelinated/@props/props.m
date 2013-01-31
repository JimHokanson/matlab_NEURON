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
        axon_capacitance
        axial_resistivity
        axon_length
        axon_diameter
        n_segs
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
         % TODO
        end 
    end
    
    
end
