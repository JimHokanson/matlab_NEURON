classdef extracellular_stim_capable < handle
    %
    %   Put in cells to enforce support for extracellular_stim simulations
    %   
    
    properties (Abstract,SetAccess = private)
        xyz_all
    end
    
    methods (Abstract)
        getAverageNodeSpacing(obj) %Needed for methods that determine 
        %activation volume that take into account redundancy via node
        %repetitions in the longitudinal direction ...
        %NOTE: I don't like this because of the assumptions it makes ...
        
        moveCenter(obj, newCenter) %Needed for getCurrentDistanceCurve
        
        %createCellInNEURON - abstract of neural_cell, not needed here ...
    end
    
end

