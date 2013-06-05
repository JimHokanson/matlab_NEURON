classdef  logger < handle_light

    %{
    This superclass will be extended by tissue, xstim, and cell
    It provides the methods save, load, compare, and update.
    These methods may however be extend4ed in the subclasses
    
    1) Lets find out how info is currently being serialized/saved/loaded.
        a) Disect findMatch
        b) Is there a nice way to know what subclass you are using from the
            parent class? This could get ugly... most of the code will then
            need to be handled in the child class... to what extand will it
            be maintained in this one? Short of making this an abstract 
            class...
            - This'll need to be saved uniquely. Perhaps having a type name
                wouldn't be too bad... That's just is not elegant :P
            - The current version id might need to be accesssable without 
                actually instantiated a class. Is this feasable/resonable? 
                Where should it be maintained then?  
    %}
    
    
    properties
        %%----------------- Should I just break down cell_props/stim?
        %data_linearization --- these would not be defined in the
        %superclass anyway
        %current_data_instance 
        
        VERSION = 1; % actully this should be in the subclasses...
        % right? do we want to be able to tell that the subclasses are of a
        % different version here? no...
    end
    
    methods
        
        function save(obj)
            %can I cast things?????
            
        end
        
        function obj = load()
        end
        
        function similarity = compare(logger1, logger2)
            %these need to be of the same subclass... I dont see where it
            %would occur that a tissue would be compared with an electrode
            %but nonetheless...
            
            %while developing... See:
            % NEURON.simulation.extracellular_stim.sim_logger.matcher.stim
            % NEURON.simulation.extracellular_stim.sim_logger.matcher.cell_props.getMatchingEntries
            
            %The RNEL function that allows for comparison within a certain
            %epsilon may or maynot be useful... :P I would like for this
            %function to maintain some way of determining some margin for
            %the values to be considered not just the same but similar so
            %we can add code later to handle non-exact matches 
        end
        
        function obj = update(obj)
            % This function will update the loaded obj to the newer version
            % specifications... 
            %
        end
        
    end
end


