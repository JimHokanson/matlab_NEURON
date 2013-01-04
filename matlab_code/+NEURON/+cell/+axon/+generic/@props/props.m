classdef props < handle_light
    %
    %
    %   Class: NEURON.cell.axon.generic.props
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
        parent %Class: NEURON.cell.axon.generic
        spatial_obj %Class: NEURON.cell.axon.generic.spatial_info
    end
    
    properties
        props_up_to_date_in_NEURON = false
        %Set true by placeVariablesIntoNEURON
        %Set false by?
    end
    
    %Initial properties based loosely on McNeal 1976
    properties

       % Node props
       number_internodes = 20 % general design situation
       
       node_length = 1% (um)
       node_axial_resistivity = 110 % Ra (ohm-cm) - Stampfli, year?
       node_capacitance = 2% cm (uF/cm2) 
       
       % Myelin props]
       myelin_n_segs = 9
        %myelin_n_segs = 10 %Default value, could change this via settings
       %for the different implementations in different papers
       %This will be important for determining spatial info
       %In general we only have 1 segment for nodes. We tend to have many
       %more for myelin
       
       myelin_conductance = 0 % (S/cm2), perfectly insulating ...
       myelin_capacitance = 0 % (uF/cm2)
       %rename to internode_axial_resistivity
       myelin_axial_resistivity = 110% Ra (ohm-cm)
       
       % fiber props
       fiber_diameter % (um)
       
       node_membrane_dynamics = 'fh' %string ????, hh, fh, etc
       node_dynamics % an integer representing the above
       % implement a way to convert string to a number that can be sent to
       % NEURON? integer will be variable membrane_dynamics. Do this in
       % populateDependentVariables?
       % NOTE: in addition to being easier for the user to change, the
       % string can be used to load the correct dll file in
       % createCellInNEURON

    end
    
    methods 
        function obj = props(parent_obj,spatial_info_obj)
           obj.parent = parent_obj;
           obj.spatial_obj = spatial_info_obj;
           obj.populateDependentVariables();
        end
        
        function set.fiber_diameter(obj,value)
           obj.fiber_diameter = value;
           populateDependentVariables(obj);
        end
    end
    
    %FIBER DIAMETER DEPENDENT PROPERTIES
    properties
       myelin_length % (um)
       node_diameter % (um) aka axon diameter, usually some fraction of fiber diameter
    end
    
    properties (Constant)
       MEMBRANE_DYNAMICS_OPTIONS = {'hh' 'fh'} %etc  
    end
    
    methods
        function setPropsByPaper(obj,paper_option)
           switch paper_option
              % case 'Sweeney_1987'
                  % set_Sweeney_1987(obj)
               case 'McNeal_1976'
                   set_McNeal_1976(obj)
               otherwise
                   error('Option not yet implemented')
           end
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
    
    %PAPER SETTINGS  --------------------------
    methods (Hidden)
        %function set_Sweeney_1987(obj)
           %Document the specific props used there ....
           %19 compartments
           %node length - 1.5 um
           %0.6 ratio
           %L/D 100
           
        %end
        function set_McNeal_1976(obj)
            % axoplasm resistivity = 110 ohm-cm
             obj.node_axial_resistivity = 110;
             obj.myelin_axial_resistivity = 110;
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

