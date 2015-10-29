classdef props < NEURON.sl.obj.handle_light
    %
    %   Class: NEURON.cell.axon.generic.props
    %
    %   Relevant NEURON files:
    %   ===================================================================
    %       create_generic_axon.hoc - see method
    %                   NEURON.cell.axon.generic.createCellInNeuron()
    
    
    
    properties (Hidden)
        parent          %Class: NEURON.cell.axon.generic
        spatial_obj     %Class: NEURON.cell.axon.generic.spatial_info
    end
    
    properties
        props_up_to_date_in_NEURON = false
        %Set true by placeVariablesIntoNEURON
        %Set false by? populateDependentVariables. Should probably set
        %properties to private access with a change function that will set
        %this property to false
    end
    
    %Initial properties based loosely on McNeal 1976 ======================
    properties
        
        % Node props
        %------------------------------------------------------------------
        number_internodes = 20
        node_length            = 1   %(um)     (Neuron property - L)
        node_axial_resistivity = 110 %(ohm-cm) (Neuron property - Ra) - Stampfli, year?
        node_capacitance       = 1   %(uF/cm2) (Neuron property - cm)
        
        % Myelin props
        %------------------------------------------------------------------
        myelin_n_segs = 9 %# of segments per internode.
        
        myelin_conductance = 0 % (S/cm2), perfectly insulating ...
        myelin_capacitance = 0 % (uF/cm2)
        %rename to internode_axial_resistivity
        internode_axial_resistivity = 110% Ra (ohm-cm)
        
        %Fiber Properties
        %------------------------------------------------------------------
        fiber_diameter = 1% (um)
        
        node_membrane_dynamics = 'fh' %string hh, fh, etc
    end
    
    properties (Constant)
        MEMBRANE_DYNAMICS_OPTIONS = {'hh' 'fh' 'crrss'} %etc
    end
    
    %TODO: make dependent
    properties
        node_dynamics  %Numeric value of
    end
    
    properties
        %FIBER DIAMETER DEPENDENT PROPERTIES
        myelin_length = 500     %(um)
        node_diameter = 0.75    %(um) aka axon diameter, usually some fraction of fiber diameter
        
        % Electrical props
        v_init = -70; % mV
    end
    
    methods
        function obj = props(parent_obj,spatial_info_obj)
            obj.parent      = parent_obj;
            obj.spatial_obj = spatial_info_obj;
            obj.populateDependentVariables();
        end
        
        function set.node_membrane_dynamics(obj,value)
            %TODO: Add validity check here ...
            
            obj.node_membrane_dynamics = value;
            %node_dynamics
            populateDependentVariables(obj);
        end
    end
    
    
    
    methods
        function populateDependentVariables(obj) % There might not be many for a generic axon...
            obj.node_dynamics = find(strcmpi(obj.MEMBRANE_DYNAMICS_OPTIONS,obj.node_membrane_dynamics),1);
            if isempty(obj.node_dynamics)
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
                % case 'Sweeney_1987'
                % set_Sweeney_1987(obj)
                case 'McNeal_1976'
                    set_McNeal_1976(obj)
                case 'Rattay_1987'
                    set_Rattay_1987(obj)
                otherwise
                    error('Option not yet implemented')
            end
        end
    end
    
    %PAPER SETTINGS  --------------------------
    methods (Hidden)
        %function set_Sweeney_1987(obj)
        %Document the specific props used there ....
        %19 compartments
        %node length - 1.5 um
        %0.6 ratio
        %L/D 100
        
        %end
        function set_Rattay_1987(obj)
            %
            %SIM PROPS
            %temp = 27
            %
            %TISSUE PROPS
            %resistivity - 300
            %
            %STIM PROPS
            %stim pulse - 0.1 ms long, cathodal (negative), monophasic
            
            obj.fiber_diameter = 2.4; % 2.4 um, also used 9.6 um
            
            obj.node_axial_resistivity = 100; % 100
            obj.node_capacitance = 1; % 1 uF/cm^2
            obj.node_diameter = obj.fiber_diameter;
            % node length, use default
            obj.node_membrane_dynamics = 'fh'; % calls populateDependentVariables, currently this only sets property node_dynamics (an integer interpreted by hoc code)
            
            obj.internode_axial_resistivity = obj.node_axial_resistivity;
            obj.myelin_conductance = 0;
            obj.myelin_capacitance = 0;
            
            %NOTE: This isn't that realistic but it wasn't all that critical
            %for their results ...
            obj.myelin_length = 1000; % 1 mm - see pg 344 (delta x reference)
            %                           see also figure 6 caption
            
        end
        
        function set_McNeal_1976(obj)
            % axoplasm resistivity = 110 ohm-cm
            obj.node_axial_resistivity = 110;
            obj.internode_axial_resistivity = 110;
            %membrance capacitiance/area (FH) = 2 uF/cm2
            obj.node_capacitance = 2;
            % nodal gap width (Dodge & Frankenhaeuser) = 2.5 um
            obj.myelin_length  = 2.5;
            % myelin perfectly insulating
            obj.myelin_conductance = 0; % (S/cm2)
            obj.myelin_capacitance = 0; % (uF/cm2)
            
            obj.node_membrane_dynamics = 'fh';
            % membrane dynamics must be set before fiber_diameter
            % ratio of internodal space to fiber diameter = 100
            obj.fiber_diameter = obj.myelin_length/100;
            % ratio of axon and fiber diamters = 0.7
            obj.node_diameter = 0.7*obj.fiber_diameter;
            
            
            % membrance conductance/area = 30.4 mmho/cm2
            % external medium resistivity = 300 ohm-cm
        end
    end
    
end

