classdef logger < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.logger
    %
    %   Known Helper Subclasses
    %   --------------------------------------------------------
    %   NEURON.logger.auto_logger
    %   NEURON.logger.ID_logger
    %
    %   Known implementations (for quick browsing)
    %   -------------------------------------------------------------------
    %   NEURON.simulation.extracellular_stim.electrode.elec_logger
    %
    %   IMPROVEMENTS:
    %   ===================================================================
    %   1) Needs significant documentation updates
    %   2) Remove long names ...
    %   3) Change name of find to be more appropriate
    %   4) Remove dynamicprops => NEURON.sl.obj.handle_light
    %
    %   See Also:
    %   NEURON.logger.auto_logger
    %   NEURON.logger.ID_logger
    %   NEURON.logger.ID
    
    properties (Hidden)
       MAIN_LOGGER_VERSION = 1 
    end
    
    properties (Abstract, Constant)
        VERSION  %Each logger should change the version if the data
        %they are logging changes. This will require creation of an update
        %method, called update.
        %
        %
        CLASS_NAME  %If a subclass of a class, then this should be the
        %fully resolved name of the super class. When not subclassed, then
        %this should just be the name of the class itself. This should
        %refer to the class being logged (the loggable class), not the
        %logger class.
        %
        %   Examples:
        %   ---------------------------------------------------------------
        %   class: NEURON.tissue.homogeneous_anisotropic
        %   CLASS_NAME => NEURON.tissue
        %
        %   class: NEURON.simulation.extracellular_stim.electrode
        %   CLASS_NAME => NEURON.simulation.extracellular_stim.electrode
        %
        TYPE  %(numeric), this can be used to distinguish between different
        %subclass types. See definiton in ID object
    end
    
    properties (Dependent)
        n_trials  %Depends on id_creation_dates
    end
    
    methods
        function value = get.n_trials(obj)
            value = length(obj.id_creation_dates);
        end
    end
    
    properties
        id_creation_dates %Matlab time for when id was created
        parent %Reference to loggable parent
    end
    
    %Constructor methods ==================================================
    methods
        function obj = logger(parent)
            obj.parent = parent;
        end
        function editParent(obj,parent)
            obj.parent = parent;
        end
    end
    
    methods (Static)
        function [obj,p_logger] = getInstanceHelper(c_handle,p_logger,varg_input)
            %
            %
            %   [obj,p_logger] = getInstanceHelper(c_handle,p_logger,varg_input)
            %
            %   This method was written to facilitate singleton
            %   object construction ...
            %
            %   INPUTS
            %   ===========================================================
            %   c_handle : Constructor function handle
            %   p_logger : Reference to persistent variable ...
            
            %Generic function
            if isempty(p_logger)
                obj = c_handle(varg_input{:});
                p_logger = obj;
            else
                p_logger.editParent(varg_input{:});
            end
            obj = p_logger;
        end
    end
    
    %Data access methods
    %======================================================================
    methods
        function ID = getInstanceID(obj,varargin)
            %
            %   This is meant to be the public facing method ...
            %
            %   See Also:
            %   NEURON.logger.auto_logger.find
            %   NEURON.logger.ID_logger.find
            
            in.new_ok = true;
            in = NEURON.sl.in.processVarargin(in,varargin);

            ID = obj.find(in.new_ok);
        end
    end
    
    
    %Saving ===============================================================
    methods (Access = protected)
        function ID = updateIDandSave(obj,save_fh)
            %
            %   ID = updateIDandSave(obj,save_fh)
            %
            %   OUTPUTS
            %   ===========================================================
            %   ID      : NEURON.logger.ID
            %
            %   INPUTS
            %   ===========================================================
            %   save_fh : function handle to save function
            %
            %   See Also:
            %       #OBJ.getID
            %       #OBJ.updateIdCount
            %
            %   FULL PATH:
            %   NEURON.logger.updateIDandSave
            
            obj.id_creation_dates = [obj.id_creation_dates now];
            feval(save_fh);
            ID = obj.getID(obj.n_trials);
        end
        function ID = getID(obj,match_index)
            %getID
            %
            %    ID = getID(obj,*match_index)
            %
            %    ID = getID(obj)
            %
            %    INPUTS
            %    ===========================================================
            %    match_index : (default []), typically the row of the
            %                matching entry,
            %
            %                [] => NULL ID (i.e. match not found)
            %
            %   See Also:
            %   #OBJ.updateIDandSave
            %
            %    FULL PATH:
            %    NEURON.logger.getID
            
            if ~exist('match_index','var')
                match_index = [];
            end
            
            if isempty(match_index)
                creation_date = [];
            else
                creation_date = obj.id_creation_dates(match_index);
            end
            
            ID = NEURON.logger.ID(obj.CLASS_NAME, obj.TYPE, match_index,creation_date);
        end
    end
    
    %Saving/Loading/Pathing ===============================================
    methods (Access = protected)
        %         function loadHelper(obj)
        %             %
        %             %
        %             %   loadHelper(obj)
        %             %
        %             %   NOTE: We might be able to update the toObject code
        %             %   to not try and assign constant properties ...
        %
        %             save_path = obj.getSaveDataPath;
        %             if exist(save_path,'file')
        %                 h = load(save_path);
        %                 s = h.s;
        %
        %                 if obj.VERSION ~= s.VERSION
        %                     s = obj.update(s);
        %                 end
        %
        %                 result = NEURON.sl.struct.toObject(obj,s); %#ok<NASGU>
        %                 %NOTE: result will eventually be a class that dictactes
        %                 %what happens, since the input class is a handle, the props
        %                 %are assigned in the function, and we don't need to do
        %                 %anything with the output class
        %                 %
        %                 %result.raiseError - not yet implented ...
        %             end
        %         end
        function addPropsAndSave(obj,s)
            %
            %    INPUTS
            %    ===========================================================
            %    s : (structure), should only have logger properties in its
            %    top level, not loggable class properties
            
            s.VERSION             = obj.VERSION;
            s.MAIN_LOGGER_VERSION = obj.MAIN_LOGGER_VERSION;
            s.id_creation_dates   = obj.id_creation_dates;
            save_path = obj.getSaveDataPath;
            save(save_path,'s');
        end
        function s = getStructure(obj)
            save_path = obj.getSaveDataPath;
            if ~exist(save_path,'file')
                s = struct([]);
            else
                h = load(save_path);
                s = h.s;
                
                if obj.MAIN_LOGGER_VERSION ~= s.MAIN_LOGGER_VERSION
                   error('Not yet implemented') 
                end
                
                obj.id_creation_dates = s.id_creation_dates;
                
                if obj.VERSION ~= s.VERSION
                    s = obj.update(s);
                end
            end
        end
        function save_base_path = getClassPath(obj)
            %getClassPath
            %
            %   save_base_path = getClassPath(obj)
            %
            %  Returns a path for saving data that is specific to the
            %  particular subclass of logger that is requesting the data.
            
            %NOTE: We may eventually change this to point to a user
            %specified data logging base path ...
            %
            %   i.e. see NEURON.user_options
            base_path        = NEURON.sl.stack.getMyBasePath('','n_dirs_up',3);
            
            class_name_parts = regexp(class(obj),'\.','split');
            
            save_base_path   = NEURON.sl.dir.createFolderIfNoExist(base_path,'data',class_name_parts{2:end});
        end
        function file_path = getSaveDataPath(obj)
            file_path = fullfile(obj.getClassPath,'data.mat');
        end
    end
    
    %Optional methods subclasses might overload ===========================
    methods
        %FORMAT: new_data_struct_handle = update(obj,old_data_struct_handle)
        %
        %   This method needs to be implemented if a subclass changes its
        %   version number
        function new_data_struct_handle = update(~,~) %#ok<STOUT>
            error('update() implementation needed in subclass')
        end
    end
    
    %Abstract methods =====================================================
    methods (Abstract)
        %TODO: Change this name, it is not good ...
        id = find(obj)
    end
end