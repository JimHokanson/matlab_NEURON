function init_system
    %init_system
    %
    %   Should be called on startup to initialize system.
    %
    %   FULL PATH:
    %       NEURON.init_system

    NEURON.comm_obj.java_comm_obj.init_system_setup;

    if ispc
        user32.init();
        NET.addAssembly('System');
        NEURON.comm_obj.windows_comm_obj.init_system_setup;
    end
end