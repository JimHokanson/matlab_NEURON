classdef Bourbeau_2011
    %
    %
    %   Goal for this class is to reproduce Bourbeau 2011 paper ...
    %
    %
    %   DATA SOURCES:
    %   =============================================================
    %   1) Experimental data from Gaunt et al 2009
    %       JAH 10/2/2012 NOTE: The code I used to generate the 2009
    %       results are currently a HUGE mess and not in our current DB
    %       These results are currently hardcoded ... (WHERE?)    
    %
    %   2) M. Risling, H. Aldskogius, C. Hildebrand, and S. Remahl,
    %   “Effects of sciatic nerve resection on L7 spinal roots and dorsal
    %   root ganglia in adult cats,” Exp Neurol, vol. 82, no. 3, pp.
    %   568–580, 1983.
    %       NOTE: Used 
    %
    %   3) I. Nilsson and C. H. Berthold, “Axon classes and internodal
    %   growth in the ventral spinal root L7 of adult and developing cats,”
    %   Journal of Anatomy, vol. 156, pp. 71–96, 1988. 
    %
    %   4) C. C. McIntyre, A. G. Richardson, and W. M. Grill, “Modeling the
    %   excitability of mammalian nerve fibers: influence of
    %   afterpotentials on the recovery cycle.,” Journal of
    %   neurophysiology, vol. 87, no. 2, pp. 995–1006, Feb. 2002.
    %
    %   5) Y. S. Suh, K. Chung, and R. E. Coggeshall, “A study of
    %   axonal diameters and areas in lumbosacral roots and nerves in the
    %   rat.,” The Journal of comparative neurology, vol. 222, no. 4, pp.
    %   473–81, Mar. 1984.
    %   NOTE: Yields a scaling factor of 1.4 This isn't completely accurate
    %   given their description ...
    
    properties
       %Source 4
       unique_fiber_diameters_MRG   = [5.7 7.3 8.7 10 11.5 12.8 14 15 16];
       
       %sum 10850
       number_fibers_at_diameter    = [1780 1730 1160 1920 1270 1370 630 990];  
       
       %Source 3 (& 4)
       %Verification of numbers matching MRG #s
       %Dennis' quoted source, Nillson & Berthold
       %5.7, 500 - 2*35 + 70.5*6 + 2*3 - 499, close enough ...  
       internode_lengths_for_fibers = [500 750 1000 1150 1250 1350 1400 1450 1500]; 
    end
    
    methods
    end
    
end

