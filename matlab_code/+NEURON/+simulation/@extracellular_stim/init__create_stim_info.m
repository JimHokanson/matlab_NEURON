function init__create_stim_info(obj)
%
%   init__create_stim_info(obj)
%
%
%   The goal of this function is to create a voltage 
%   profile for stimulation in NEURON
%
%    Writes voltage files for NEURON code to use ...
%
%   IMPROVEMENTS
%   ====================================================================
%   1) Allow ignoring of loading the time vector (if it doesn't change)
%

%Compute stimulus information - populates t_vec and v_all
computeStimulus(obj)

t_vec = obj.t_vec;
v_all = obj.v_all;

%keyboard

%This call allows adjustment of the simulation time in case it is too short or long
adjustSimTimeIfNeeded(obj,t_vec(end))

%Adjust the bounds for threshold testing ...
max_abs_applied_voltage = max(abs(v_all(:)));
obj.threshold_cmd_obj.adjust_max_safe_threshold(max_abs_applied_voltage);


%WRITE DATA TO FILE
%---------------------------------------------------------------------------
%NOTE: For write now we'll make no effort to allow parallel execution
%i.e. change these files based on some hash to prevent file writing
%collisions ...

%TODO: Encapsulate all of this better, see also cleanup_sim
input_dir   = fullfile(obj.cell_obj.getModelRootDirectory,'inputs');
v_file_name = sprintf('%s%s',obj.sim_hash,'v_ext.bin');
t_file_name = sprintf('%s%s',obj.sim_hash,'t_vec.bin');

voltage_filepath = fullfile(input_dir,v_file_name);
obj.cmd_obj.writeVector(voltage_filepath,v_all(:));

%NOTE: Often this doesn't change, could ignore loading this ...
time_filepath    = fullfile(input_dir,t_file_name);
obj.cmd_obj.writeVector(time_filepath,t_vec);



%POPULATE IN NEURON
%---------------------------------------------------------------------------
%xstim__load_data - loads data from file
%xstim__setup_stim_playback - creates vectors for playing stimulation

%obj.cmd_obj.run_command('{xstim__load_data() xstim__setup_stim_playback()}');

%Which one is causing the problem???
obj.cmd_obj.run_command('{xstim__load_data()}');
obj.cmd_obj.run_command('{xstim__setup_stim_playback()}');
end