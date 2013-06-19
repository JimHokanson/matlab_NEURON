classdef MRG_logger < NEURON.logger.auto_logger
    %
    %
    %   Class:
    %   NEURON.cell.axon.MRG.MRG_logger
    %
    %   This is one way of implementing it... I don't like it though. Way
    %   too many variables, but this will work...
    
    properties(Constant)
        LOGGER__VERSION = 1;
        LOGGER__CLASS_NAME = 'NEURON.cell.axon.MRG.MRG_logger';
        LOGGER__TYPE  = 1;
    end
    
    properties(Constant)
        AUTO_LOGGER__IS_SINGULAR_OBJECT = true;
        AUTO_LOGGER__INFO = {...
            'props_obj'             'class'        'class'
            'xyz_all'               'cellFP'       'numeric'
            'xyz_center'            'vectorFP'     'numeric'
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
        function obj = MRG_logger(varargin)
            obj@NEURON.logger.auto_logger(varargin{:});
        end
    end
    methods(Static)
        function obj = getLogger(varargin)
            persistent m_logger
            if isempty(m_logger)
                obj = NEURON.cell.axon.MRG.MRG_logger(varargin{:});
                m_logger = obj;
            else
                m_logger.editParent(varargin{:});
            end
            obj = m_logger;
        end
    end
end