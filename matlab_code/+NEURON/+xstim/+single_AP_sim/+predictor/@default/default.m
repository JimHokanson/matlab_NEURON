classdef default < NEURON.xstim.single_AP_sim.predictor
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.predictor.default
    %
    %
    %   Possible options to support
    %   -------------------------------------------------------------------
    %   1) Threshold prediction based on neighboring spatial locations ...
    %       - use gridfit 3d
    %   2) Determining what to learn next
    %   3) When to stop full solution and just use estimates ...
    %
    %
    %
    %
    %
    %
    
    %OPTIONS - eventually move these to a class
    %----------------------------------------------------------------------
    properties
        
    end
    
    methods
        function [solution,predictor_info] = getThresholdSolutions(obj)
           %OUTPUTS?????
           %1) Solutions
           %2) Predictor specific info ...
           
           
           %1) Get applied potential for known and unknown values ...
           %
           %    Will be done via lazy loading ...
           %
           %2) Initialize all objects
           %    - these objects will have references to this object
           %    - ideally they will reference the parent type
           %    and thus be able to know the data that is available to them
           %
           %
           
            
            
        end
    end
    
end

