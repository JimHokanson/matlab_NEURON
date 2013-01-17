function obj = create_standard_sim(varargin)
%
%   This static method will initialize all objects necessary to
%   run a simulation of extracellular stimulation.
%
%    obj = create_standard_sim(varargin)
%
%    OPTIONAL INPUTS
%    ===========================================================
%    Simulation:
%    -----------------------------------------------------------
%    launch_neuron_process : (default true), if false the NEURON
%        process will not be started, which can save some time if
%        only executing functions locally in Matlab
%    debug                 : (default false), if true all
%        communication with NEURON will be printed
%
%    Tissue:
%    -----------------------------------------------------------
%    tissue_resistivity : (default 500 Ohm-cm, Units: Ohm-cm),
%        either a 1 or 3 element vector ...
%
%
%    FULL PATH:
%       NEURON.simulation.extracellular_stim.create_standard_sim
%
%    TODO: Finish documenting optional inputs that are below
%

%Simulation properties:
%----------------------------------------------
in.launch_neuron_process = true;
in.debug                 = false;
in.celsius               = 37;

%Tissue properties:
%--------------------------------------------------------
in.tissue_resistivity    = 500;

%Cell properties:
%--------------------------------------------------------
in.cell_center           = [0 0 0];
in.cell_type             = 'MRG';
in.cell_options          = {};

%Electrode properties:
%--------------------------------------------------------
in.electrode_locations   = [0 100 0];     %Array, rows are entries ...
in.stim_scales           = [-1 0.5];      %vector, matrix, or Cell array of arrays
in.stim_durations        = [0.2 0.4];     %" "  "  "
in.stim_start_times      = 0.1;           %Singular value or vector
in = processVarargin(in,varargin);

%--------------------------------------------------------------
obj = NEURON.simulation.extracellular_stim(...
    'launch_NEURON_process',in.launch_neuron_process,'debug',in.debug);

% if celsius is changed, must be changed in both the sim obj and in NEURON
if obj.props_obj.celsius ~= in.celsius
   changeProps(obj.props_obj,'celsius',in.celsius);
    %obj.celsius = in.celsius;
   %obj.changeSimulationVariables;
end

set_Tissue(obj,NEURON.tissue.createHomogenousTissueObject(in.tissue_resistivity));

%stimulation electrode ---------------------------------
e_objs = NEURON.extracellular_stim_electrode.create(in.electrode_locations);
n_electrodes = length(e_objs);

%I don't like this being down here but I'll leave it for now ...
in = helper__handleStimOptions(in,n_electrodes);

for iElectrode = 1:n_electrodes
    setStimPattern(e_objs(iElectrode),...
        in.stim_start_times(iElectrode),...
        in.stim_durations{iElectrode},...
        in.stim_scales{iElectrode});
end
set_Electrodes(obj,e_objs);

%cell ---------------------------------------------------
switch in.cell_type   
    case 'MRG'
        set_CellModel(obj,NEURON.cell.axon.MRG(in.cell_center))
    case 'generic'
        set_CellModel(obj,NEURON.cell.axon.generic(in.cell_center))
        options.paper = [];
        options = processVarargin(options,in.cell_options);
        if isempty(options.paper)
            error('Must define paper to pull cell properties from')
        else
           setPropsByPaper(obj.cell_obj.props_obj,options.paper)
        end
    otherwise
        error('Unhandled cell type')
end

end

function in = helper__handleStimOptions(in,n_electrodes)

%Start times 
%-------------------------------------------------------------
if length(in.stim_start_times) == 1
    if n_electrodes == 1
        %do nothing
    else
        %replicate for each electrode'
        in.stim_start_times = in.stim_start_times*ones(1,n_electrodes);
    end
elseif length(in.stim_start_times) ~= n_electrodes
    error('# of electrodes:%d, does not equal the # of stim start times:%d',...
        n_electrodes,length(in.stim_start_times))
end

%Stim scales
%--------------------------------------------------------------
in.stim_scales    = helper2__handleStimCellArrayOption(in.stim_scales,'stim_scales',n_electrodes);
in.stim_durations = helper2__handleStimCellArrayOption(in.stim_durations,'stim_durations',n_electrodes);

%TODO: Ensure that all lengths match ...
if ~all(cellfun('length',in.stim_scales) == cellfun('length',in.stim_durations))
    error('Mismatch in length between stim scales and stim durations')
end

end

function value_out = helper2__handleStimCellArrayOption(value_in,prop_name,n_electrodes)
   if iscell(value_in)
      if length(value_in) ~= n_electrodes
         %TODO: Improve
         error('Mismatch in length for prop: %s',prop_name);
      end
      value_out = value_in;
   elseif size(value_in,1) == 1
      %replicate 
      if n_electrodes == 1
         value_out = {value_in};
      else
         value_out(1:n_electrodes) = {value_in};
      end
   elseif size(value_in,1) == n_electrodes
       value_out = cell(1,n_electrodes);
       for iElec = 1:n_electrodes
          value_out{iElec} = value_in(iElec,:); 
       end
   else
       error('Unhandled cased for property: %s',prop_name);
   end
end