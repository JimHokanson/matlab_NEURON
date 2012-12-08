function neuronPaths = NEURON_getPaths(model,hocFileName,variable_file_name)
%NEURON_getPaths Handles pathing ...
%
%   JAH TODO: Needs to be broken up into the constituent parts
%
%   KNOWN CALLING INSTANCES:
%   ==========================================================
%   1) NEURON_runNeuron
%   neuronPaths = NEURON_getPaths(model,hocFileName,variable_file_name)
%
%   2) 
%   
%   See file and folder assumptions in: NEURON_layoutNotes
%   
%   OUTPUTS
%   ===========================================================
%   GENERIC STUFFS
%   --------------------------------------
%   neuronPaths.exe_path        -
%   neuronPaths.models_root     - 
%   neuronPaths.c.root_install  -  
%   neuronPaths.c.bash          -
%   neuronPaths.c.bashStartFile -
%   neuronPaths.c.mknrndll      -
%   
%   MODEL SPECIFIC
%   ----------------------------------------
%   neuronPaths.model_dir -
%   neuronPaths.mod_dir   -
%   neuronPaths.data_dir  -
%
%   HOC CODE SPECIFIC: NOTE: _n indicates a path that can be used in Neuron
%   ------------------------------------------------------------------------
%   neuronPaths.hoc_path    = hocFilePath;
%   neuronPaths.hoc_path_n  = NEURON_createNeuronPath(neuronPaths.hoc_path);
%   neuronPaths.hoc_start_dir        - 
%   neuronPaths.hoc_start_dir_n      -
%   neuronPaths.variable_file_path   -
%   neuronPaths.variable_file_path_n -
%   
%
%   CONSTANTS USED
%   ===========================================================
%   NEURON_EXE_PATH    : path to neuron executable
%   NEURON_MODELS_ROOT : path to models root in analysis code
%
%   See Also:
%       NEURON_layoutNotes
%       NEURON_createNeuronPath

persistent neuronPathsTemp modelTemp hocFileNameTemp variableFileNameTemp

%NOTE: At some point I decided this was slow
%and apparently tried to speed it up ...

NEURON_CODE_DIR = 'neuron_code';
NEURON_MOD_DIR  = 'mod_files';
NEURON_DATA_DIR = 'data';
DEFAULT_VARIABLE_FILE_NAME = 'variables.hoc';

if ~exist('model','var')
   model = ''; 
end

if ~exist('hocFileName','var')
   hocFileName = ''; 
end

%NOTE: This forces a path, maybe change to numeric later
%Effects:
%NEURON_readParamsFile
%NEURON_runNeuron
if ~exist('variable_file_name','var') || isempty(variable_file_name)
   variable_file_name = DEFAULT_VARIABLE_FILE_NAME;
end

if ~isempty(neuronPathsTemp) && strcmp(modelTemp,model) && strcmp(hocFileNameTemp,hocFileName) && strcmp(variableFileNameTemp,variable_file_name)
   neuronPaths = neuronPathsTemp; 
   return
end

modelTemp            = model;
hocFileNameTemp      = hocFileName;
variableFileNameTemp = variable_file_name;

C = getUserConstants({'NEURON_EXE_PATH' 'NEURON_MODELS_ROOT'});

neuronPaths = struct;
neuronPaths.exe_path    = C.NEURON_EXE_PATH;

neuronPaths.c.root_install  = fileparts(fileparts(neuronPaths.exe_path));
neuronPaths.c.bash          = fullfile(neuronPaths.c.root_install,'bin','bash');
neuronPaths.c.bashStartFile = fullfile(neuronPaths.c.root_install,'lib','bshstart.sh');
neuronPaths.c.mknrndll      = fullfile(neuronPaths.c.root_install,'lib','mknrndll.sh');
neuronPaths.models_root     = C.NEURON_MODELS_ROOT;


if isempty(model)
   return 
end

%MODEL PATH INFORMATION
%=================================================================================
model_dir = fullfile(neuronPaths.models_root,model);
if ~exist(model_dir,'dir')
    error('Specified model directory: "%s" does not exist',model_dir)
end

neuron_code_dir       = fullfile(model_dir,NEURON_CODE_DIR);
neuronPaths.model_dir = neuron_code_dir;
neuronPaths.mod_dir   = fullfile(neuron_code_dir,NEURON_MOD_DIR);
neuronPaths.data_dir  = fullfile(neuron_code_dir,NEURON_DATA_DIR);


%SPECIFIC HOC CODE PATH INFO
%=================================================================================
if ~isempty(hocFileName)
    hocFilePath = getDirectoryTree(neuron_code_dir,'',true,hocFileName,'files');

    if isempty(hocFilePath)
        error('Unable to find requested hoc file: %s',hocFileName)
    end
    hocFilePath = hocFilePath{1};
    neuronPaths.hoc_path    = hocFilePath;
    neuronPaths.hoc_path_n  = NEURON_createNeuronPath(neuronPaths.hoc_path);
    
    neuronPaths.hoc_start_dir   = fileparts(neuronPaths.hoc_path);
    neuronPaths.hoc_start_dir_n = NEURON_createNeuronPath(neuronPaths.hoc_start_dir);
    neuronPaths.variable_file_path   = fullfile(neuronPaths.hoc_start_dir,variable_file_name);
    neuronPaths.variable_file_path_n = NEURON_createNeuronPath(neuronPaths.variable_file_path); 
    
    
end

neuronPathsTemp = neuronPaths;

