classdef tissue_logger < logger

    %this will again be extended by the specific tissues.. hopefully I can
    %do this without the logger class knowing... :P
    properties
        VERSION = 1%? nope! again this should be in the lowest level, huh?
        %both, jk...
        
        %data_linearization %shall this have one too?
    end
    
    properties
        spec_obj %This will be populated by an instance the subclass
        % SILLY QUESTION: if we are affecting the property directly... 
        % This will change too right? It is a pointer to that object yea? 
    end
    
    methods
        function obj = tissue_logger(spec_obj)
            %which came first the tissue_logger or the specific subclass?
            obj.spec_obj = spec_obj; 
        end
        
        function tissue = prepareUpdate(version)
            %this needs to be compatible with other versions...
            % wait... how am I gunna do that?
            %We will have to discet from it whatever they used to specify
            %that particular class and recreate it right? so we will need
            %to take in the version number separately and then case-by-case
            %reformat the class.
            tissue = 0;
            
            if version ~= Verion
                tissue = 0;
            end
        end
%         
%         function
%         end
        
    end
    
end