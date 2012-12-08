function record_node_voltages(cmd_obj,section_list_in,list_name_out)
%record_node_voltages
%
%   record_node_voltages(cmd_obj,list_name)
%   
%   CLASS: NEURON.lib.sim_logging.record_node_voltages
%

str = sprintf('%s = sim_logging__record_node_voltages(%s)',list_name_out,section_list_in);
cmd_obj.run_command(str);

