function obj = create_standard_sim(varargin)
%create_standard_sim
%
%   obj = create_standard_sim(varargin)
%
%   This static method will initialize all objects necessary to run a 
%   simulation of extracellular stimulation.
%
%   OPTIONAL INPUTS
%   =======================================================================
%   Simulation:
%   -----------------------------------------------------------------------
%   xstim_options : see NEURON.simulation.extracellular_stim.options
%
%   Tissue:
%   -----------------------------------------------------------
%   tissue_resistivity : (default 500 Ohm-cm, Units: Ohm-cm),
%        currently either a 1 or 3 element vector for isotropic or
%        anisotropic tissue
%
%   Cell Properties
%   -----------------------------------------------------------------------
%   cell_center  : (default [0 0 0])
%   cell_type    : (default 'MRG'), see NEURON.neural_cell.create_cell
%           - MRG
%           - generic
%           - generic_unmyelinated
%
%   Electrode Properties
%   -----------------------------------------------------------------------
%   electrode_locations : (default [0 100 0]), rows indicate different
%                         electrodes.
%
%   FULL PATH:
%   NEURON.simulation.extracellular_stim.create_standard_sim


%Simulation properties:
%--------------------------------------------------------------------------
in.xstim_options         = NEURON.simulation.extracellular_stim.options;

%Tissue properties:
%--------------------------------------------------------------------------
in.tissue_resistivity    = 500;

%Cell properties:
%--------------------------------------------------------------------------
in.cell_center           = [0 0 0];
in.cell_type             = 'MRG';

%Electrode properties:
%--------------------------------------------------------------------------
in.electrode_locations   = [0 100 0];
in = NEURON.sl.in.processVarargin(in,varargin);

%--------------------------------------------------------------------------
obj = NEURON.simulation.extracellular_stim(in.xstim_options);

set_Tissue(obj,NEURON.tissue.createHomogenousTissueObject(in.tissue_resistivity));

obj.set_Electrodes(NEURON.simulation.extracellular_stim.electrode.create(in.electrode_locations,obj));

set_CellModel(obj,NEURON.neural_cell.create_cell(obj,in.cell_type,in.cell_center))

end