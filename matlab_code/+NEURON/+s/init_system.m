function init_system
    %init_system
    %
    %   Should be called on startup to initialize system.
    %
    %   FULL PATH:
    %       NEURON.init_system

    NEURON.comm_obj.java_comm_obj.init_system_setup;

end