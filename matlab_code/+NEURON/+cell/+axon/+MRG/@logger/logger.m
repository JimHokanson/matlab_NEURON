classdef logger < NEURON.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.cell.axon.MRG.logger
    %
    %   This is one way of implementing it... I don't like it though. Way
    %   too many variables, but this will work...
    
    properties(Constant)
        VERSION = 1;
        CLASS_NAME = 'NEURON.cell.axon.MRG';
        TYPE  = 1;
    end
    
    properties
       props 
    end
    
    properties(Constant)
        IS_SINGULAR_OBJECT = true;
        PROCESSING_INFO = {...
            'xyz_center'            'vectorFP'       ''
            %-----------------------------------------------------------
            'fiber_diameter'        'vectorFP'      @getPropName
            'node_diameter'         'vectorFP'      @getPropName
            'paranode_diameter_1'   'vectorFP'      @getPropName
            'paranode_diameter_2'   'vectorFP'      @getPropName
            'axon_diameter'         'vectorFP'      @getPropName
            'node_length'           'vectorFP'      @getPropName
            'paranode_length_1'     'vectorFP'      @getPropName
            'paranode_length_2'     'vectorFP'      @getPropName
            'internode_length'      'vectorFP'      @getPropName
            'stin_seg_length'       'vectorFP'      @getPropName
            'number_lemella'        'vectorFP'      @getPropName
            'space_p1'              'vectorFP'      @getPropName
            'space_p2'              'vectorFP'      @getPropName
            'space_i'               'vectorFP'      @getPropName
            'n_STIN'                'vectorFP'      @getPropName
            'n_internodes'          'vectorFP'      @getPropName
            'v_init'                'vectorFP'      @getPropName
            'rho_periaxonal'        'vectorFP'      @getPropName
            'rho_axial_node'        'vectorFP'      @getPropName
            'rho_axial_i'           'vectorFP'      @getPropName
            'rho_axial_1'           'vectorFP'      @getPropName
            'rho_axial_2'           'vectorFP'      @getPropName
            'cap_nodal'             'vectorFP'      @getPropName
            'cap_internodal'        'vectorFP'      @getPropName
            'cap_myelin'            'vectorFP'      @getPropName
            'cm_i'                  'vectorFP'      @getPropName
            'cm_1'                  'vectorFP'      @getPropName
            'cm_2'                  'vectorFP'      @getPropName
            'g_myelin'              'vectorFP'      @getPropName
            'g_1'                   'vectorFP'      @getPropName
            'g_2'                   'vectorFP'      @getPropName
            'g_i'                   'vectorFP'      @getPropName
            'g_pas_1'               'vectorFP'      @getPropName
            'g_pas_2'               'vectorFP'      @getPropName
            'g_pas_i'               'vectorFP'      @getPropName
            'xraxial_node'          'vectorFP'      @getPropName
            'xraxial_1'             'vectorFP'      @getPropName
            'xraxial_2'             'vectorFP'      @getPropName
            'xraxial_i'             'vectorFP'      @getPropName
            'xg_node'               'vectorFP'      @getPropName
            'xg_1'                  'vectorFP'      @getPropName
            'xg_2'                  'vectorFP'      @getPropName
            'xg_i'                  'vectorFP'      @getPropName
            'xc_node'               'vectorFP'      @getPropName
            'xc_1'                  'vectorFP'      @getPropName
            'xc_2'                  'vectorFP'      @getPropName
            'xc_i'                  'vectorFP'      @getPropName }
    end
    
    methods(Access = private)
        function obj = logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end
    end
    
    methods
        function value = getPropName(obj,~,prop_name)
           value = obj.props.(prop_name);
        end
    end
    
    methods(Static)
        function obj = getInstance(props_obj,varargin)
            persistent p_logger
            c_handle = @NEURON.cell.axon.MRG.logger;
            [obj,p_logger] = NEURON.logger.getInstanceHelper(c_handle,p_logger,varargin);
            obj.props = props_obj;
        end
    end
end