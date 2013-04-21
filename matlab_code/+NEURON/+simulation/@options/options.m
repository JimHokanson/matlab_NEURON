classdef options
    %
    %   Class:
    %       NEURON.simulation.options
    
    %Class Options    %====================================================
    properties
        cmd_options   = NEURON.cmd.options  %
    end
    
    %Permanent Properties   %==============================================
    properties
        %Time Changing properties
        %------------------------------------------------------------------
        autochange_run_time   = true %Set this to false to prevent
        %the class from automatically changing the duration of the run
        %time. This is set to false if the user changes the duration of the
        %simulation (tstop in NEURON.simulation.props)
        
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
        launch_NEURON_process_during_initialization = true;  %If false the
        %simulation will not launch a NEURON window
        
        run_inspector = true; %If true a class will be launched that helps
        %to summarize current NEURON variables. It adds a small bit of 
        %overhead on startup and is only really necessary for debugging ...
    end
end

