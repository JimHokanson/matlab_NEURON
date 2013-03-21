classdef user_options < handle_light
    %
    %   This class is meant to handle parsing of user defined variables.
    %
    %   Class:
    %   NEURON.user_options
    %
    %   The user options
    %
    %
    %   IMPROVEMENTS
    %   ==============================================================
    %   1) Provide GUI for updating properties
    %   2) Provide method for writing properties to file
    %   3) Describe rules for properties and organization in file
    
    
    %Required Properties
    %----------------------------------
    properties
        temp_data_base_path %(dir) This base path is used for having a location
        %to send data to NEURON and back again. The contents are not
        %critical and can be deleted at any time.
    end
    
    properties (Hidden)
        %NOTE: It is important that this location is maintained.
        required_properties  %Populated dynamically based on position.
    end
    
    %Class Required Properties
    %----------------------------------
    properties
        sim_logger_root_path  %(dir)
    end
    
    %Optional Properties
    %----------------------------------------------------------------------
    properties
        hoc_editor  %(file_dir) Path to hoc editor. If the editor doesn't support
        %filenames as an input, then perhaps we could expand this to a
        %function handle.
    end
    
    properties (Hidden)
        defined_properties
    end
    
    properties (Hidden,Constant)
       DEFAULT_FILE_NAME = 'options.txt' 
    end
    
    
    methods (Access = private)
        function obj = user_options()
            %
            %
            %    Private constructor
            %
            %    Retrieve the object singleton using:
            %        NEURON.user_options.getInstance
            %
            
            obj.initialize
        end
    end
    
    methods (Hidden)
        function initialize(obj)
            
            %Getting required properties
            %---------------------------------------------------------------
            temp_meta  = ?NEURON.user_options;
            p          = temp_meta.PropertyList;
            prop_names = {p.Name};
            I = find(strcmp(prop_names,'required_properties'),1);
            obj.required_properties = prop_names(1:I-1);
            
            %Getting filepath
            %---------------------------------------------------------------
            options_file_filepath = obj.getFilePath;
            
            %Reading filepath
            %---------------------------------------------------------------
            file_data = getPropFileAsStruct(options_file_filepath,':');
            
            %Assignment of properties
            %---------------------------------------------------------------
            fn          = fieldnames(file_data);
            
            keep_fields_mask = ismember(fn,fieldnames(obj));
            bad_fields_I     = find(~keep_fields_mask);
            good_fields_I    = find(keep_fields_mask);
            
            for iField = good_fields_I(:)'
                cur_field_name = fn{iField};
                obj.(cur_field_name) = file_data.(cur_field_name);
            end
            
            %Other stuff
            %---------------------------------------------------------------
            obj.defined_properties = fn(good_fields_I);
            
            is_present = ismember(obj.required_properties,obj.defined_properties);
            
            if ~all(is_present)
                %Currently this requires manual fixing
                %TODO: provide GUI for fixing this
                missing_properties = obj.required_properties(~is_present);
                error(['Not all required properties are specified in the options text\n' ...
                    'missing properties include:\n%s\n'],cellArrayToString(missing_properties,'\n'))
            end
            
            %TODO - if not empty display more info
            if ~isempty(bad_fields_I)
                bad_field_names = fn(bad_fields_I); %#ok<NASGU>
                fprintf(2,'Bad fields are presents in the NEURON options file\n');
            end
        end
    end
    
    methods (Hidden, Static)
        function options_file_filepath = getFilePath(obj,missing_file_ok)
            %
            %
            %
            %
            
            if ~exist('missing_file_ok','var')
               missing_file_ok = false; 
            end
            
            options_dir  = filepartsx(getMyPath,3);
            
            %Change to wildcard on extension
            options_file = fullfile(options_dir,'options*');
            
            d_struct = dir(options_file);
            if isempty(d_struct)
                if missing_file_ok
                    options_file_filepath = fullfile(options_dir,obj.DEFAULT_FILE_NAME);
                else
                    %TODO: launch GUI
                    error('options file needed, currently manual creation required')
                end
            elseif length(d_struct) ~= 1
                error('Expecting singular match for options* in repository root')
            else
                options_file_filepath = fullfile(options_dir,d_struct.name);
            end
            
            
        end
    end
    
    %=======================   PUBLIC METHODS =============================
    
    methods
        %Not yet impelemented
%         function writeObjectToFile(obj)
%            getFilePath 
%         end
        function reset(obj)
            initialize(obj)
        end
        function defined_flags = checkPropsDefined(obj,props_to_check)
            %checkPropsDefined
            %
            %   defined_flags = checkPropsDefined(obj,props_to_check)
            
            if ischar(props_to_check) || length(props_to_check) == 1
                defined_flags = strcmp(obj.defined_properties,props_to_check);
            else
                defined_flags = ismember(props_to_check,obj.defined_properties);
            end
        end
    end
    
    methods (Static)
        function obj = getInstance()
            persistent uniqueInstance
            if isempty(uniqueInstance)
                obj = NEURON.user_options;
                uniqueInstance = obj;
            else
                obj = uniqueInstance;
            end
        end
    end
    
end

