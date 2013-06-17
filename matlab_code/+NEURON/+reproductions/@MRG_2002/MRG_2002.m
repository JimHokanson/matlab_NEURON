classdef MRG_2002 < handle
    %
    %   TODO? - inherit from testing class?
    %
    %   PAPER
    %   ===================================================================
    %   C. C. McIntyre, A. G. Richardson, and W. M. Grill, “Modeling the
    %   excitability of mammalian nerve fibers: influence of afterpotentials
    %   on the recovery cycle.,” Journal of neurophysiology, vol. 87, no. 2,
    %   pp. 995–1006, Feb. 2002.
    %
    %
    %   STATUS
    %   ===================================================================
    %   1) figure_8c - nearly finished
    %   2) Other figures not yet started
    %   3) Need to implement testing suite to ensure validity throughout
    %       code updates
    %
    
    properties
    	TISSUE_RESISTIVITY = [1200 1200 300]; %See Stimulation Procedure Section
    end
    
    methods (Static)
       figure_8c
    end
    
end

