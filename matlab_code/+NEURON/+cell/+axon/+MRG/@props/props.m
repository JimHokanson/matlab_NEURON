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
    %   IMPROVEMENTS
    %   ===================================================================
    %   1) Documentation
    %   2) Change properties method
    
    %DIRTY INFORMATION
    %======================================================================
    %1) props_up_to_date_in_NEURON
    %2) Spatial information changes - notify spatial_obj of changes to
    %   spatial parameters.
    %   obj.spatial_obj.spatialPropsChanged();
    %3)
    
    %METHODS IN OTHER FILES
    %======================================================================
    %NEURON.cell.axon.MRG.props.getPropertyValuePairing
    %NEURON.cell.axon.MRG.props.placeVariablesInNEURON
    
    
    %PROPERTY CONSISTENCY
    %NOTE: This is not fully implemented, specifically the property 
    %changing methods are not implemented
    %======================================================================
    %1) Any change to a property that is not dependent on fiber will
    %   cause a reevaluation of all property dependent variables
    %2) Changing the fiber diameter will cause a reevaluation of all 
    %   fiber diameter dependent variables
    %3) To manually change fiber diameter dependent variables, these should
    %   be changed after any non-fiber diameter dependent variables
    % 
    %   IMPORTANT: The goal with this setup is to always have the
    %   properties be internally consistent, i.e. never needing to call
    %   populateDependentVariables()
    
    properties (Hidden)
        parent       %Class: NEURON.cell.axon.MRG
        spatial_obj  %Class: NEURON.cell.axon.MRG.spatial_info
    end
    
    properties
        props_up_to_date_in_NEURON = false
        %Set true by: 
        %   .placeVariablesIntoNEURON()
        %Set false by: 
        %   .changeProperty()
        %
        %
    end
    
    properties (SetAccess = private)
        %------------------------------------------------------------------
        %       NOTE: Values without defaults are diameter dependent
        %------------------------------------------------------------------
        
        %==================================================================
        %morphological parameters -----------------------------------------
        %==================================================================
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
        
        %DONT CHANGE THIS YET, see function create_mrg_axon.hoc
        n_STIN   = 6      %In this model, each internode is broken up into 
        %parts instead of a single internode with multiple segments
        
        %NOTE: In general it is desirable to make this even, as this
        %provides an odd number of nodes (given terminating nodes on both
        %ends) which allows for a "center" node
        %NOTE: This parameter is CRUCIAL in terms of execution time
        n_internodes   = 20     %# of internodes
        %NOTE: n_nodes = n_internodes + 1
        
        %Electrical Parameters --------------------------------------------
        %NOTE: Careful about changing this since the model dynamics
        %will impose force this to be v_rest, given sufficient time
        v_init         = -80   %mV              %PAPER: Rest Potential
        
        
        %NOTE: No specified sources for these values ...
        %NOTE: Raspopovic 2011 cites Frijins 1995
        
        
        rho_periaxonal = 70    %Ohm-cm   %PAPER: Periaxonal Resistivity
        
        rho_axial_node = 70    %Ohm-cm   %PAPER: Axoplasmic Resistivity
        rho_axial_i            %Ohm-cm
        rho_axial_1            %Ohm-cm
        rho_axial_2            %Ohm-cm
        
        
        
        cap_nodal      = 2     %uF/cm2          %PAPER: Nodal capicitance
        %Frankenhaeuser & Huxley, 1964
        
        cap_internodal = 2     %uF/cm2          %PAPER: Internodal capicitance
        %Bostock & Sears 1978 
        
        cap_myelin     = 0.1   %uF/cm2/lamella  %PAPER: Myelin capacitance
        
        cm_i         %uF/cm2
        cm_1         %uF/cm2
        cm_2         %uF/cm2
        
        g_myelin    = 0.001;   %S/cm2   %PAPER: Myelin conductance
        g_1         = 0.001;   %S/cm2   %PAPER: MYSA conductance
        g_2         = 0.0001;  %S/cm2   %PAPER: FLUT conductance
        g_i         = 0.0001;  %S/cm2   %PAPER: STIN conductance
        
    end
    
    %Fiber Diameter Dependent Variables ==============================
    properties
        
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
        function obj = props(parent_obj,spatial_info_obj)
            obj.parent = parent_obj;
            obj.spatial_obj = spatial_info_obj;
            obj.populateDependentVariables();
        end
        function changeFiberDiameter(obj,new_fiber_diameter)
           %TODO: Add check on range
           
           obj.fiber_diameter = new_fiber_diameter;
           obj.populateDependentVariables();
           %NOTE: The dependent variables method will
           %set all necessary dirty bits
        end
        function changeProperty(obj,varargin)
           %
           %    INPUTS
           %    ===========================================
           %    props_and_values
           
           props = varargin(1:2:end);
           values = varargin(2:2:end);
           
           if length(props) ~= length(values)
               error('# of properties must equal the # of values')
           end
           
           %TODO: Need to separate order into fiber dependent
           %& non-fiber dependent variables ....
           
           for iProp = 1:length(props)
              cur_prop  = props{iProp};
              cur_value = values{iProp};
              obj.(cur_prop) = cur_value;
           end
           
           
           obj.props_up_to_date_in_NEURON = false;
           obj.populateDependentVariables();
           %TODO: Need to conditionally call this method ...
           
        end
    end
    
    methods
        %NOTE: Could build in mechanism which allows overriding these values
        %NOTE: This function needs a lot of work ...
        function populateDependentVariables(obj)
            %See Table 1 in paper
            
            %NOTE: Matt has replaced this with regression equations ...
            
            %See determineFiberEquations
            
            fiber_diameter_all       = [5.7      7.3     8.7     10      11.5    12.8    14      15      16];
            
            FIBER_INDEX = find(fiber_diameter_all == obj.fiber_diameter,1);
            if isempty(FIBER_INDEX)
                error('Unable to find specifications for given fiber size')
            end
            
            %ROUGH DIAMETER OUTLINE
            %--------------------------------------------------------------
            %FIBER DIAMETER > AXON DIAMETER > NODE DIAMETER
            %AXON DIAMETER = FLUT DIAMETER (PARANODE 2)
            %NODE DIAMETER = MYSA DIAMETER (PARANODE 1)
            
            
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
            
            obj.internode_length     = internode_length_all(FIBER_INDEX);
            obj.number_lemella       = number_lemella_all(FIBER_INDEX);
            obj.node_diameter        = node_diameter_all(FIBER_INDEX);
            obj.paranode_diameter_1  = paranode_diameter_1_all(FIBER_INDEX);
            obj.paranode_length_2    = paranode_length_2_all(FIBER_INDEX);
            obj.paranode_diameter_2  = paranode_diameter_2_all(FIBER_INDEX);
            obj.stin_seg_length      = (obj.internode_length - obj.node_length - 2*obj.paranode_length_1 - 2*obj.paranode_length_2)/obj.n_STIN;
            obj.axon_diameter        = axon_diameter_all(FIBER_INDEX);


            %{
            
            NOTE: I'm working on this code but it at least
            some of the data doesn't match the references cited
            
            %SOME NEW CODE:
            %--------------------------------------------------------------
            fiber_diameter_local = obj.fiber_diameter;
            fiber_poly_2 = [fiber_diameter_local^2 fiber_diameter_local 1]';
            
            internode_length_weights = [-91.1 -20.2 1745.9];
            diameter_weights         = [1   obj.axon_diameter  log10(obj.axon_diameter)]';
            obj.internode_length     = internode_length_weights*diameter_weights;
            
            
            %LOCAL FITS ONLY
            %--------------------------------------------------------------
            obj.number_lemella       = 65.897*log(fiber_diameter_local)-32.66;
            
            obj.node_diameter       = [0.006304 0.2071 0.5339]*fiber_poly_2;
            obj.paranode_diameter_1 = obj.node_diameter;
            
            obj.axon_diameter       = [0.0188 0.4787 0.1204]*fiber_poly_2;
            obj.paranode_diameter_2 = obj.axon_diameter;         
            
            %}
            
            %Electrical parameters
            %--------------------------------------------------------------
            %See extracellular_stim_mechanism.m in extracellular_stim documentation
            
            %NOTE: I have to think about this ...
            f_OVER_a___diameter_ratio = obj.fiber_diameter/obj.axon_diameter;
            f_OVER_p1__diameter_ratio = obj.fiber_diameter/obj.paranode_diameter_1;
            f_OVER_p2__diameter_ratio = obj.fiber_diameter/obj.paranode_diameter_2;
            
            
            %Internal axial resistance
            %--------------------------------------------------------------
            %This is a property of section ...
            %
            %Units: Ohm-cm
            %We are using rho for the node as our basis.
            %Then we assume that the underlying resistivity is the same.
            %NOTE: rho = R*A/L
            %R_node = R_others
            %
            %This suggests that if we want to get a unit length
            %value, we need to simply correct for area differences
            %rho_node/A_node = rho_others/A_others
            %
            %rho_others = rho_node*A_others/A_node
            %
            %
            % LIKELY ERRORS:
            %   1) fiber diameter used instead of other diameters
            %       for the diameters in in the create cell code
            %       instead of the other diameters
            %   2) This code below also uses the fiber diameter
            %      for rho_axial values
            %   3) 
            %
            %   Default values from MRG
            %   node: 70
            %   FLUT: 642
            %   MYSA: 147
            %   INTR: 147
            
            %CURRENT STATUS: matches MRG, not sure if they are right
            rho_axial_local = obj.rho_axial_node;
            obj.rho_axial_i = rho_axial_local*f_OVER_a___diameter_ratio^2;
            obj.rho_axial_1 = rho_axial_local*f_OVER_p1__diameter_ratio^2;
            obj.rho_axial_2 = rho_axial_local*f_OVER_p2__diameter_ratio^2;
            
            %Axonal Membrane Capacitance
            %--------------------------------------------------------------
            %http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/mech.html#capacitance
            %Capacitance Mechansims - auto-inserted into every sectin
            %Let's assume e_r*e_0/d is constant for all of the axon
            %
            %   C1/A1 = C2/A2
            %   
            %   C2 = A2/A1*C1
            %
            %   A = length*diameter*pi
            %   A => diameter (lengths specified in model, pi cancels)
            %   
            %   C2 = d2/d1*C1
            %
            %   QUESTIONS?
            %       1) Shouldn't the ratios be flipped?
            %              They are, as written in my code it is a bit
            %              confusing - 1/(A1/A2) = A2/A1
            %       2) Why is this referenced to fiber diameter and not to
            %       axon diameter?
            
            obj.cm_i  = obj.cap_internodal/f_OVER_a___diameter_ratio;
            obj.cm_1  = obj.cap_internodal/f_OVER_p1__diameter_ratio; %Should this use nodal????
            obj.cm_2  = obj.cap_internodal/f_OVER_p2__diameter_ratio;
            
            %Axonal Membrane Conductance
            %--------------------------------------------------------------
            %http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/mech.html#pas
            %
            %   g (Units S/cm^2)
            %
            %   g = factor*A
            %
            %   g1/A1 = g2/A2 (equivalent factors)
            %
            %   g2 = g1*A2/A1
            %
            %   Question:
            %       1) This already varies by section, why do a correction
            %       for diameter here? Uh-oh, why are we doing a correction
            %       for anything????
            
            obj.g_pas_i = obj.g_i/f_OVER_a___diameter_ratio;
            obj.g_pas_1 = obj.g_1/f_OVER_p1__diameter_ratio;  %NOTE using node ...
            obj.g_pas_2 = obj.g_2/f_OVER_a___diameter_ratio;
            
            populateExtracellularParameters(obj)
            
            obj.props_up_to_date_in_NEURON = false;
            obj.spatial_obj.spatialPropsChanged();
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
            %
            %This computes the difference in circular area between the
            %axon and the axon plus some small space
            node_space_area = obj.calcSpaceArea(obj.node_diameter,obj.space_p1); %NOTE use of space p1
            %The use of the extracellular mechansism is a bit confusing at
            %the node
            
            p1_space_area   = obj.calcSpaceArea(obj.paranode_diameter_1,obj.space_p1);
            p2_space_area   = obj.calcSpaceArea(obj.paranode_diameter_2,obj.space_p2);
            i_space_area    = obj.calcSpaceArea(obj.axon_diameter,obj.space_i);
            
            %Axial resistance in perixaxonal space
            %--------------------------------------------------------------
            %PARAMETER: xraxial MOhm/cm
            %
            %   NOTE: Here the model only has a concept of length, so we
            %   must handle providing diameter cues
            %
            obj.xraxial_node = 100*obj.rho_periaxonal/node_space_area;
            obj.xraxial_1    = 100*obj.rho_periaxonal/p1_space_area;
            obj.xraxial_2    = 100*obj.rho_periaxonal/p2_space_area;
            obj.xraxial_i    = 100*obj.rho_periaxonal/i_space_area;
            
            
            %"Membrane" conductance in periaxonal space
            %--------------------------------------------------------------
            %PARAMETER: xg S/cm2
            %
            %NOTE: This doesn't know thickness, so we have to correct for it
            %The x2 seems to be double correcting for the area
            %Since the model is assuming a cylinder ...
            obj.xg_1 = obj.g_myelin/(obj.number_lemella*2); %Is the *2 correct????
            obj.xg_2 = obj.xg_1;
            obj.xg_i = obj.xg_1;
            
            %"Membrane" capacitance in periaxonal space
            %--------------------------------------------------------------
            %PARAMETER: xc uF/cm2
            %
            %   Hmm, this seems to instead include the myelin as well
            %   
            %   NOTE: We are not actually using the extracellular
            %   mechanism with two additional layers, only 1. This is
            %   obvious if looking closely at Figure 1 in the MRG paper.
            %
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

