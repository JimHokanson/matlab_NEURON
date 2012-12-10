classdef extracellular_stim_capable < handle
    %
    %   Put in cells to enforce support for extracellular_stim simulations
    %   
    
    properties (Abstract)
        xyz_all
    end
    
    methods (Abstract)
        moveCenter(obj, newCenter) %Needed for getCurrentDistanceCurve
        %createCellInNEURON - abstract of neural_cell, not needed here ...
    end
    
end

