classdef options
    %
    %   Class:
    %       NEURON.simulation.options
    
    %Class Options    %====================================================
    properties
        nrn_options = NEURON.options
    end
    
    %Permanent Properties   %==============================================
    properties
        %Time Changing properties
        %------------------------------------------------------------------
        autochange_run_time   = true %Set this to false to prevent
        %the class from automatically changing the duration of the run
        %time.
        
        display_time_change_warnings = true %Set this to false to not display
        %the warnings that the time is changing to account for events
        
        time_after_last_event = 0.4 %Amount of time to wait after the 
        %last event. This is used for simulations to ensure that the simulation runs
        %long enough. See also the method adjustSimTimeIfNeeded() 
        
        display_NEURON_steps = false %This can be intepreted by the 
        %specific implementation of the simulation. It was originally
        %written for extracellular_stim to display the status of the
        %creation of various objects.
        
    end
    
    %Startup Properties   %================================================
    properties
        launch_NEURON_process_during_initialization = true;
    end
end

