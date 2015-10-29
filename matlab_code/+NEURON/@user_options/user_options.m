classdef user_options < NEURON.sl.obj.handle_light
    %
    %   This class is meant to handle parsing of user defined variables.
    %
    %   Class:
    %   NEURON.user_options
    %
    %   SINGLETON: 
    %       Use NEURON.user_options.getInstance
    %
    %   OPTION DEFINITIONS
    %   ===================================================================
    %
    %   IMPROVEMENTS
    %   ==============================================================
    %   1) Provide GUI for updating properties
    %   2) Provide method for writing properties to file
    %   3) Describe rules for properties and organization in file
    
    
    %Required Properties   %===============================================
    properties
        temp_data_base_path %(dir) This base path is used for having a location
        %to send data to NEURON and back again. The contents are not
        %critical and can be deleted at any time.
        neuron_exe_path %path to neuron executable:
        %For windows, point to nrniv.exe
        %For mac, point to nrniv path
    end
    
%     properties (Hidden)
%         %NOTE: It is important that this location is maintained.
%         required_properties  %Populated dynamically based on position.
%     end
    
    %======================================================================
    %Class Required Properties   %=========================================
    properties
        sim_logger_root_path  %(dir)  See class: 
        %NEURON.simulation.extracellular_stim.sim_logger
        %
        %   This will soon be obsolete ...
        %
        xstim_results_base_path %(dir)
        %NEURON.xstim.single_AP_sim.logged_data
        %
        %   This is where data from simulations is saved ...
    end
    
    %======================================================================
    %Optional Properties   %===============================================
    properties
        hoc_editor  %Path to hoc editor. If the editor doesn't support
        %filenames as an input, then perhaps we could expand this to a
        %function handle. See NEURON.s.editHoc
    end
    
%     properties (Hidden)
%         defined_properties  %When implemented properly this will be used
%         %in conjunction with the meta class ?, to grab all properties above
%         %and save their current values to file
%     end
    
    properties (Hidden,Constant)
       DEFAULT_FILE_NAME = 'options.txt'
       FILE_DELIMITER = '='
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
            
            options_data = NEURON.sl.io.readDelimitedFile(obj.getFilePath,obj.FILE_DELIMITER);

            keys = strtrim(options_data(:,1));
            values = strtrim(options_data(:,2));
            
            m = containers.Map(keys,values);
            
            obj.neuron_exe_path = m('neuron_exe_path');
            
            scratch_path = m('scratch_path');
            
            if ~exist(scratch_path,'dir')
                error('The scratch path must already exist')
            end
            
            fh = @NEURON.sl.dir.createFolderIfNoExist;
            obj.temp_data_base_path = fh(scratch_path,'temp_folder__ok_to_delete');
            obj.sim_logger_root_path = fh(scratch_path,'sim_logger_results');
            obj.xstim_results_base_path = fh(scratch_path,'xstim_results');
                        
% % % % %             %Getting required properties
% % % % %             %---------------------------------------------------------------
% % % % %             temp_meta  = ?NEURON.user_options;
% % % % %             p          = temp_meta.PropertyList;
% % % % %             prop_names = {p.Name};
% % % % %             I = find(strcmp(prop_names,'required_properties'),1);
% % % % %             obj.required_properties = prop_names(1:I-1);
% % % % %             
% % % % %             %Getting filepath
% % % % %             %---------------------------------------------------------------
% % % % %             options_file_filepath = obj.getFilePath;
% % % % %             
% % % % %             %Reading filepath
% % % % %             %---------------------------------------------------------------
% % % % %             file_data = getPropFileAsStruct(options_file_filepath,obj.FILE_DELIMITER);
% % % % %             
% % % % %             %Assignment of properties
% % % % %             %---------------------------------------------------------------
% % % % %             fn          = fieldnames(file_data);
% % % % %             
% % % % %             keep_fields_mask = ismember(fn,fieldnames(obj));
% % % % %             bad_fields_I     = find(~keep_fields_mask);
% % % % %             good_fields_I    = find(keep_fields_mask);
% % % % %             
% % % % %             for iField = good_fields_I(:)'
% % % % %                 cur_field_name = fn{iField};
% % % % %                 obj.(cur_field_name) = file_data.(cur_field_name);
% % % % %             end
% % % % %             
% % % % %             %Other stuff
% % % % %             %---------------------------------------------------------------
% % % % %             obj.defined_properties = fn(good_fields_I);
% % % % %             
% % % % %             is_present = ismember(obj.required_properties,obj.defined_properties);
% % % % %             
% % % % %             if ~all(is_present)
% % % % %                 %Currently this requires manual fixing
% % % % %                 %TODO: provide GUI for fixing this
% % % % %                 missing_properties = obj.required_properties(~is_present);
% % % % %                 error(['Not all required properties are specified in the options text\n' ...
% % % % %                     'missing properties include:\n%s\n'],cellArrayToString(missing_properties,'\n'))
% % % % %             end
% % % % %             
% % % % %             %TODO - if not empty display more info
% % % % %             if ~isempty(bad_fields_I)
% % % % %                 bad_field_names = fn(bad_fields_I); %#ok<NASGU>
% % % % %                 fprintf(2,'Bad fields are presents in the NEURON options file\n');
% % % % %             end
        end
    end
    
    methods (Hidden, Static)
        function options_file_filepath = getFilePath(missing_file_ok)
            %
            %
            %   options_file_filepath = getFilePath(*missing_file_ok)
            %
            
            if ~exist('missing_file_ok','var')
               missing_file_ok = false; 
            end
            
            options_dir  = NEURON.sl.dir.filepartsx(NEURON.sl.stack.getMyBasePath(),3);
            
            %Change to wildcard on extension
            options_file = fullfile(options_dir,'options*');
            
            d_struct = dir(options_file);
            if isempty(d_struct)
                options_file_filepath = fullfile(options_dir,NEURON.user_options.DEFAULT_FILE_NAME);
                if ~missing_file_ok
                    %TODO: launch GUI
                    error('options file needed, currently manual creation required at: %s',options_file_filepath)
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
        function defined_flags = checkPropsDefined(obj,props_to_check)
            %checkPropsDefined
            %
            %   defined_flags = checkPropsDefined(obj,props_to_check)
            %
            %   TODO: Expand to optionally throw errors if not defined ...
            %   
            
            if ischar(props_to_check) || length(props_to_check) == 1
                defined_flags = strcmp(obj.defined_properties,props_to_check);
            else
                defined_flags = ismember(props_to_check,obj.defined_properties);
            end
        end
    end
    
    methods (Static)
        function reset()
            %
            %
            %   NEURON.user_options.reset();
            
            obj = NEURON.user_options.getInstance;
            initialize(obj)
        end
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

