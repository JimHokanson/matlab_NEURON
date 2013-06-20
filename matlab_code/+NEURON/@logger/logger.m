classdef logger < dynamicprops
    %
    %
    %   Class:
    %   NEURON.logger
    %
    %   Known Helper Subclasses
    %   --------------------------------------------------------
    %   NEURON.logger.auto_logger
    %
    %
    %   Known implementations (for quick browsing)
    %   -------------------------------------------------------------------
    %   NEURON.simulation.extracellular_stim.electrode.elec_logger
    
    %{
    This class will be extended by tissue, xstim, and cell
    It provides the methods save, load, compare, and update.
    
    1) Lets find out how info is currently being serialized/saved/loaded.
        a) Disect findMatch
    %}
    
    %TODO: We might need to prefix these
    properties (Abstract, Constant)
        LOGGER__VERSION     %Each logger should change the version if the data
        %they are logging changes. This will require creation of an update
        %method, called updateObj
        %
        %
        LOGGER__CLASS_NAME  %If a subclass of a class, then this should be the
        %fully resolved name of the super class. When not subclassed, then
        %this should just be the name of the class itself.
        %
        %   Examples:
        %   ---------------------------------------------------------------
        %   class: NEURON.tissue.homogeneous_anisotropic
        %   CLASS_NAME => NEURON.tissue
        %
        %   class: NEURON.simulation.extracellular_stim.electrode
        %   CLASS_NAME => NEURON.simulation.extracellular_stim.electrode
        LOGGER__TYPE  %(numeric), this can be used to distinguish between different
        %subclass types. See definiton in ID object
    end
    
    properties
        %         log
        %.logger()
        LOGGER__n_trials = 0 %This should be internally maintained via add and remove
        %methods.
        LOGGER__parent %Reference to loggable parent
    end
    
    %Shared Methods         ===============================================
    methods (Hidden)
        function next_match_id = updateIdCount(obj)
            %
            %   next_match_id = updateIdCount(obj)
            %
            %   Updates internal ID and returns the new value ...
            %
            %   Updates property: LOGGER__n_trials
            %
            
            next_match_id        = obj.LOGGER__n_trials + 1;
            obj.LOGGER__n_trials = next_match_id;
        end
    end
    methods
        function obj = logger(parent)
            obj.LOGGER__parent = parent;
        end
        
        function editParent(obj,parent)
            obj.LOGGER__parent = parent;
        end
        
        %Adding a new entry outline:
        %--------------------------------------------------------
        
        %3) obj.saveHelper();
        %
        %   This next step is optional but typical ...
        %
        %4) ID = obj.getID(next_match_id);
        %
        %NOTE: It would be nice to wrap this into a function that takes a
        %save handle and evaluates it ...
        %TODO: Implement this ...
        
        function ID = updateIDandSave(obj,save_fh)
            next_match_id = obj.updateIdCount;
            feval(save_fh);
            ID = obj.getID(next_match_id);
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
            %                matching entry, if no match is found an empty
            %                represents a null id
            %
            %    FULL PATH:
            %    NEURON.logger.getID
            
            if ~exist('match_index','var')
                match_index = [];
            end
            
            ID = NEURON.logger.ID(obj.LOGGER__CLASS_NAME, obj.LOGGER__TYPE, match_index);
        end
    end
    
    %Saving/Loading/Pathing ===============================================
    methods
        %NOTE: Instead of being helpers, they could be the main
        %implenentation as long as we specify properties that chould change
        %their behavior, like properties not to save ...
        %
        %For example, when saving the auto_logger, we don't need to save
        %the AUTO_INFO property
        %         function saveHelper(obj,properties_remove)
        %             %
        %             %
        %             %   This function converts the object to a structure and saves it.
        %             %   By saving the object as a structure we ensure that we can load
        %             %   it on any computer, regardless of whether the class definition
        %             %   code exists or not.
        %
        %             w = warning('off','MATLAB:structOnObject');
        %             s = struct(obj);
        %             warning(w);
        %
        %             %Very important line ...
        %             if isfield(s,'LOGGER__parent')
        %                 s = rmfield(s,'LOGGER__parent');
        %             end
        %
        %             if exist('properties_remove','var')
        %                 s = rmfield(s,properties_remove);%#ok<NASGU>
        %             end
        %
        %             save_path = obj.getSaveDataPath;
        %             save(save_path,'s');
        %         end
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
        %                 if obj.LOGGER__VERSION ~= s.LOGGER__VERSION
        %                     s = obj.update(s);
        %                 end
        %
        %                 result = sl.struct.toObject(obj,s); %#ok<NASGU>
        %                 %NOTE: result will eventually be a class that dictactes
        %                 %what happens, since the input class is a handle, the props
        %                 %are assigned in the function, and we don't need to do
        %                 %anything with the output class
        %                 %
        %                 %result.raiseError - not yet implented ...
        %             end
        %         end
        function save_base_path = getClassPath(obj)
            %getClassPath
            %
            %   save_base_path = getClassPath(obj)
            %
            %  Returns a path for saving data that is specific to the
            %  particular subclass of logger that is requesting the data.
            
            %NOTE: We may eventually change this to point to a user
            %specified data logging base path ...
            base_path        = sl.dir.getMyBasePath('',3);
            
            class_name_parts = regexp(class(obj),'\.','split');
            
            save_base_path   = sl.dir.createFolderIfNoExist(base_path,'data',class_name_parts{2:end});
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
    
    methods (Abstract)
        id = find(obj,create_if_not_found)
        
        %NOTE: Create new abstract methods as they are needed
        
        
        
        
        %deleteIndices(obj, indices)
        
        %while developing... See:
        % NEURON.simulation.extracellular_stim.sim_logger.matcher.stim
        % NEURON.simulation.extracellular_stim.sim_logger.matcher.cell_props.getMatchingEntries
        
        %The RNEL function that allows for comparison within a certain
        %epsilon may or maynot be useful... :P I would like for this
        %function to maintain some way of determining some margin for
        %the values to be considered not just the same but similar so
        %we can add code later to handle non-exact matches
        
        
        
        
        % This function will update the loaded obj to the newer version
        % specifications...
    end
end