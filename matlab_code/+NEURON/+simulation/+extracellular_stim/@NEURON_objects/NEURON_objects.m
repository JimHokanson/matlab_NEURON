classdef NEURON_objects < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.simulation.extracellular_stim.NEURON_objects
    %
    %   This class is meant to document the objects that are used for
    %   extracellular stimulation in NEURON.
    
    properties (Hidden)
        cmd  %Class: NEURON.cmd
    end
    
    properties
       all_sectionlist  %(SectionList)
       node_sectionlist %(SectionList)   
    end
    
    methods
        function obj = NEURON_objects(cmd)
           obj.cmd = cmd; 
           
           %TODO: In the middle of finishing this function
           error('Not yet implemented')
           
        end
    end
    
end

