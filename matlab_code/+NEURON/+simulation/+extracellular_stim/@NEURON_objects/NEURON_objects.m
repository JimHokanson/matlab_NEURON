classdef NEURON_objects < NEURON.sl.obj.handle_light
    %
    %   Class:
    %       NEURON.simulation.extracellular_stim.NEURON_objects
    %
    %   This class is meant to document the objects that are used for
    %   extracellular stimulation in NEURON.
    
    properties (Hidden)
        cmd_obj  %Class: NEURON.cmd
    end
    
    properties
       all_sectionlist  %(SectionList)
       node_sectionlist %(SectionList)   
    end
    
    methods
        function obj = NEURON_objects(cmd_obj)
           obj.cmd_obj = cmd_obj; 
           
           %TODO: In the middle of finishing this function
           
        end
    end
    
end

