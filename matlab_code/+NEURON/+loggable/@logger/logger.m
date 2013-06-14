classdef logger < dynamicprops
    %
    %
    %   Class:
    %   NEURON.loggable.logger
    %
    %{
    This class will be extended by tissue, xstim, and cell
    It provides the methods save, load, compare, and update.
    
    1) Lets find out how info is currently being serialized/saved/loaded.
        a) Disect findMatch
    %}
    
    
    properties (Abstract, Constant)
        VERSION
    end
    
    properties
        log
        parent
    end
    
    
    methods
        %         function [a,b] = load(obj)
        %             path = getLoggerPaths(obj); %write this code;
        %             %only xstim_logger will not directly refernce this function.
        %             load(path);
        %         end
        
        %This could probably be moved somewhere else... I'm writing it to
        %use for comparing the loggers but there is a chance we might want
        %to use it somewhere else too...
        %What does he do?
        function same(floatA, floatB, maxDiff)
            
        end
    end
    
    methods
        %NOTE: Instead of being helpers, they could be the main
        %implenentation as long as we specify properties that chould change
        %their behavior, like properties not to save ...
        %
        %For example, when saving the auto_logger, we don't need to save
        %the AUTO_INFO property
        function saveHelper(obj,properties_remove)
            %
            %
            %   This function converts the object to a structure and saves it.
            %   By saving the object as a structure we ensure that we can load
            %   it on any computer, regardless of whether the class definition
            %   code exists or not.
            
            
            w = warning('off','MATLAB:structOnObject');
            s = struct(obj);
            warning(w);
            
            if exist('properties_remove','var')
                s = rmfield(s,properties_remove);%#ok<NASGU>
            end
            
            save_path = obj.getSaveDataPath;
            save(save_path,'s');
        end
        function loadHelper(obj,variables_not_to_assign)
            %
            %
            %   NOTE: We might be able to update the toObject code
            %   to not try and assign constant properties ...
            
            save_path = obj.getSaveDataPath;
            if exist(save_path,'file')
                h = load(save_path);
                
                if obj.VERSION ~= h.VERSION
                    obj.updateObj()
                end
                
                result = sl.struct.toObject(obj,h.s,'VERSION');
                %result.raiseError - not yet implented ...
            end
        end
        function save_base_path = getClassPath(obj)
            base_path = sl.dir.getMyBasePath('',3);
            
            class_name_parts = regexp(class(obj),'\.','split');
            
            save_base_path = sl.dir.createFolderIfNoExist(base_path,'data',class_name_parts{2:end});
        end
        
        
        function file_path = getSaveDataPath(obj)
            file_path = fullfile(obj.getClassPath,'data.mat');
        end
        
    end
    
    methods (Abstract)
        save(obj)
        
        id = find(obj)
        
        deleteIndices(obj, indices)
        
        %while developing... See:
        % NEURON.simulation.extracellular_stim.sim_logger.matcher.stim
        % NEURON.simulation.extracellular_stim.sim_logger.matcher.cell_props.getMatchingEntries
        
        %The RNEL function that allows for comparison within a certain
        %epsilon may or maynot be useful... :P I would like for this
        %function to maintain some way of determining some margin for
        %the values to be considered not just the same but similar so
        %we can add code later to handle non-exact matches
        
        update(obj)
        % This function will update the loaded obj to the newer version
        % specifications...
    end
end