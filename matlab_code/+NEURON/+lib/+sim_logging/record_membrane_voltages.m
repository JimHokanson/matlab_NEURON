function record_membrane_voltages(cmd_obj,section_list_in,list_name_out)
%record_membrane_voltages  Record membrane voltage for a given section list
%
%   record_membrane_voltages(cmd_obj,section_list_in,list_name_out)
%
%   In NEURON this takes a list of sections and says that for each section
%   NEURON should record the membrane potential of that section over time.
%
%   INPUTS
%   =======================================================================
%   cmd_obj         : Class: NEURON.cmd
%   section_list_in : Name of section list of sections where membrane voltage
%                     should be recorded
%   list_name_out   : Name of a list which holds references to vectors
%                     which contain the membrane voltage data.
%   
%   FULL_PATH: NEURON.lib.sim_logging.record_membrane_voltages

str = sprintf('%s = sim_logging__record_node_voltages(%s)',list_name_out,section_list_in);
cmd_obj.run_command(str);

