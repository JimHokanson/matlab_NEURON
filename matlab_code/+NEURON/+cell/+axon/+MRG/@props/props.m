classdef props < handle_light
    %props
    %
    %   CLASS: NEURON.cell.axon.MRG.props
    %
    %   Relevant NEURON files:
    %   ==================================
    %   create_mrg_axon.hoc - see method ....MRG.createCellInNEURON()
    %
    %
    %TODO: Still finishing this class
    %
    %   NEURON UNITS
    %   =================================================
    %   Section Units
    %   L      - microns
    %   diam   - microns
    %   Ra     - ohm-cm
    %
    %   NOTE: Most of these props should be private
    %   with a method that allows changing them
    %   On change, update simulation dirty bit ...
    %
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Documentation
    %   2) n_segs should be n_internodes
    %   3) Change properties method
    %
    
    %DIRTY INFORMATION
    %======================================================================
    %1) props_up_to_date_in_NEURON
    %2) Spatial information changes - notify spatial_obj of changes to
    %   spatial parameters
    %3)
    
    
    %NOTE: Values without defaults are calculated based on the dependent variables
    
    properties (Hidden)
        parent       %Class: NEURON.cell.axon.MRG
        spatial_obj  %Class: NEURON.cell.axon.MRG.spatial_info
    end
    
    properties
        props_up_to_date_in_NEURON = false
    end
    
    properties (SetAccess = private)
        %morphological parameters -----------------------------------------
        fiber_diameter    = 10 %um choose from 5.7, 7.3, 8.7, 10.0, 11.5, 12.8, 14.0, 15.0, 16.0
        node_diameter          %um
        paranode_diameter_1    %um
        paranode_diameter_2    %um
        axon_diameter          %um
        
        node_length       = 1  %um  %PAPER: Node length
        paranode_length_1 = 3  %um  %PAPER: MYSA length
        paranode_length_2      %um
        internode_length       %um
        stin_seg_length        %um
        
        number_lemella         %#
        space_p1 = 0.002       %um, %PAPER: MYSA periaxonal space width
        space_p2 = 0.004       %um, %PAPER: FLUT periaxonal space width
        space_i	 = 0.004       %um, %PAPER: STIN perixaonal space width
        
        %DONT CHANGE THIS YET ....
        %see function create_mrg_axon.hoc
        n_STIN   = 6      %In this model, each internode is broken up into parts
        
        %NOTE: In general it is desirable to make this even, as this
        %provides an odd number of nodes (given terminating nodes on both
        %ends) which allows for a "center" node
        %NOTE: This parameter is CRUCIAL in terms of execution time
        n_internodes   = 20     %# of internodes
        %n_nodes = n_internodes + 1
        
        %Electrical Parameters --------------------------------------------
        %NOTE: Careful about changing this since the model dynamics
        %will impose force this to be v_rest, given sufficient time
        v_init      = -80     %mV       %PAPER: Rest Potential
        
        cap_nodal      = 2     %uF/cm2         %PAPER: Nodal capicitance
        cap_internodal = 2     %uF/cm2         %PAPER: Internodal capicitance
        cap_myelin     = 0.1   %uF/cm2/lamella %PAPER: Myelin capacitance
        
        g_myelin    = 0.001;   %S/cm2   %PAPER: Myelin conductance
        g_1         = 0.001;   %S/cm2   %PAPER: MYSA conductance
        g_2         = 0.0001;  %S/cm2   %PAPER: FLUT conductance
        g_i         = 0.0001;  %S/cm2   %PAPER: STIN conductance
        
    end
    
    %Fiber Diameter Dependent Variables ==============================
    properties
        %morphological parameters -----------------------------
        
        %electrical parameters ----------------------------------
        rho_axial_node = 70    %Ohm-cm   %PAPER: Axoplasmic Resistivity
        rho_periaxonal = 70    %Ohm-cm   %PAPER: Periaxonal Resistivity
        rho_axial_i            %Ohm-cm
        rho_axial_1            %Ohm-cm
        rho_axial_2            %Ohm-cm
        
        cm_i         %uF/cm2
        cm_1         %uF/cm2
        cm_2         %uF/cm2
        
        %PASSIVE MECHANISM VARIABLES -----------------------------
        g_pas_i
        g_pas_1
        g_pas_2
        
        %Mohms/cm
        xraxial_node
        xraxial_1
        xraxial_2
        xraxial_i
        
        %mho/cm2
        xg_node = 1e10  %Why? Does this make sense????
        xg_1
        xg_2
        xg_i
        
        %uF/cm2
        xc_node = 0
        xc_1
        xc_2
        xc_i
        
    end
    
    methods
        function obj = props(parent_obj)
            obj.parent = parent_obj;
            obj.populateDependentVariables(obj)
        end
        function populateSpatialInfoObj(obj,spatial_info_obj)
            obj.spatial_obj = spatial_info_obj;
        end
        function changeFiberDiameter(obj,new_fiber_diameter)
           %TODO: Add check on range
           
           obj.fiber_diameter = new_fiber_diameter;
           obj.populateDependentVariables();
           obj.props_up_to_date_in_NEURON = false;
           obj.spatial_obj.spatialPropsChanged();
        end
    end
    
    methods
        %NOTE: Could build in mechanism which allows overriding these values
        %NOTE: This function needs a lot of work ...
        function populateDependentVariables(obj)
            %See Table 1 in paper
            
            %NOTE: Matt has replaced this with regression equations ...
            
            fiber_diameter_all       = [5.7      7.3     8.7     10      11.5    12.8    14      15      16];
            
            FIBER_INDEX = find(fiber_diameter_all == obj.fiber_diameter,1);
            if isempty(FIBER_INDEX)
                error('Unable to find specifications for given fiber size')
            end
            
            %FROM TABLE 1 - MODEL GEOMETRIC PARAMETERS =================================================
            internode_length_all     = [500      750     1000    1150    1250    1350    1400    1450    1500];
            number_lemella_all       = [80       100     110     120     130     135     140     145     150];
            %node_length             CONSTANT
            node_diameter_all        = [1.9      2.4     2.8     3.3     3.7     4.2     4.7     5.0     5.5];
            %paranode_length_1       CONSTANT
            paranode_diameter_1_all  = [1.9      2.4     2.8     3.3     3.7     4.2     4.7     5.0     5.5];
            %space_p1                CONSTANT
            paranode_length_2_all    = [35       38      40      46      50      54      56      58      60];
            paranode_diameter_2_all  = [3.4      4.6     5.8     6.9     8.1     9.2     10.4    11.5    12.7];
            %space_p2                CONSTANT
            %STIN LENGTH             DEPENDENT - delta_x_all,paranode_length_1,paranode_length_2_all,n_STIN
            axon_diameter_all        = [3.4      4.6     5.8     6.9     8.1     9.2     10.4    11.5    12.7];
            %space_i                 CONSTANT
            
            
            %Not used even though defined ... ?????
            %g_all                    = [0.605    0.630   0.661   0.690  	0.700   0.719   0.739   0.767   0.791];
            
            
            obj.internode_length     = internode_length_all(FIBER_INDEX);
            obj.number_lemella       = number_lemella_all(FIBER_INDEX);
            obj.node_diameter        = node_diameter_all(FIBER_INDEX);
            obj.paranode_diameter_1  = paranode_diameter_1_all(FIBER_INDEX);
            obj.paranode_length_2    = paranode_length_2_all(FIBER_INDEX);
            obj.paranode_diameter_2  = paranode_diameter_2_all(FIBER_INDEX);
            obj.stin_seg_length      = (obj.internode_length - obj.node_length - 2*obj.paranode_length_1 - 2*obj.paranode_length_2)/obj.n_STIN;
            obj.axon_diameter        = axon_diameter_all(FIBER_INDEX);
            
            %Electrical parameters  %---------------------------------------
            
            %NOTE: I have to think about this ...
            f_OVER_a__diameter_ratio  = obj.fiber_diameter/obj.axon_diameter;
            f_OVER_p1__diameter_ratio = obj.fiber_diameter/obj.paranode_diameter_1;
            f_OVER_p2__diameter_ratio = obj.fiber_diameter/obj.paranode_diameter_2;
            
            obj.rho_axial_i = obj.rho_axial_node*f_OVER_a__diameter_ratio^2;
            obj.rho_axial_1 = obj.rho_axial_node*f_OVER_p1__diameter_ratio^2;
            obj.rho_axial_2 = obj.rho_axial_node*f_OVER_p2__diameter_ratio^2;
            
            %NOTE: I don't think these are right,
            obj.cm_i  = obj.cap_internodal/f_OVER_a__diameter_ratio;
            obj.cm_1  = obj.cap_internodal/f_OVER_p1__diameter_ratio; %Should this use nodal????
            obj.cm_2  = obj.cap_internodal/f_OVER_p2__diameter_ratio;
            
            %http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/mech.html#pas
            %NOTE: Why the scaling factor?????
            obj.g_pas_i = obj.g_i/f_OVER_a__diameter_ratio;
            obj.g_pas_1 = obj.g_1/f_OVER_p1__diameter_ratio;  %NOTE using node ...
            obj.g_pas_2 = obj.g_2/f_OVER_a__diameter_ratio;
            
            populateExtracellularParameters(obj)
            
            obj.props_populated = true;
        end
        
        function populateExtracellularParameters(obj)
            %
            %
            %    NEURON:
            %    http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/mech.html#extracellular
            %
            
            %GET TO: MOhm/cm  GIVEN: Ohm-cm/um^2
            %Conversion:
            %
            %    1/um^2 * 1 um^2/1e-8cm^2 * 1e-6 MOhm/Ohm
            %
            %    I get multiply by 100 ...
            
            %Static function calls ...
            node_space_area = obj.calcSpaceArea(obj.node_diameter,obj.space_p1); %NOTE use of space p1
            p1_space_area   = obj.calcSpaceArea(obj.paranode_diameter_1,obj.space_p1);
            p2_space_area   = obj.calcSpaceArea(obj.paranode_diameter_2,obj.space_p2);
            i_space_area    = obj.calcSpaceArea(obj.axon_diameter,obj.space_i);
            
            %PARAMETER: xraxial MOhm/cm
            %NOTE: Not sure why I am scaling this, need to think about this ...
            obj.xraxial_node = 100*obj.rho_periaxonal/node_space_area;
            obj.xraxial_1    = 100*obj.rho_periaxonal/p1_space_area;
            obj.xraxial_2    = 100*obj.rho_periaxonal/p2_space_area;
            obj.xraxial_i    = 100*obj.rho_periaxonal/i_space_area;
            
            %PARAMETER: xg S/cm2
            %NOTE: This doesn't know thickness, so we have to correct for it
            %The x2 seems to be double correcting for the area
            %Since the model is assuming a cylinder ...
            obj.xg_1 = obj.g_myelin/(obj.number_lemella*2); %Is the *2 correct????
            obj.xg_2 = obj.xg_1;
            obj.xg_i = obj.xg_1;
            
            %PARAMETER: xc uF/cm2
            obj.xc_1 = obj.cap_myelin/(obj.number_lemella*2);
            obj.xc_2 = obj.xc_1;
            obj.xc_i = obj.xc_1;
            
        end
    end
    
    methods (Static)
        function out = calcSpaceArea(section_diam,extra_space)
            r = section_diam/2;
            out = pi*((r + extra_space)^2 - r^2);
        end
    end
    
end

