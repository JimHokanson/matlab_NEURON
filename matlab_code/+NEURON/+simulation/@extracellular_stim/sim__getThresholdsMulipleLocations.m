function thresholds = sim__getThresholdsMulipleLocations(obj,cell_locations,varargin)
%sim__getThresholdsMulipleLocations
%
%   
%   It just came to my attention that I spelled Multiple wrong :/
%
%
%   sim__getThresholdsMulipleLocations(obj,cell_locations,varargin)
%
%   INPUTS
%   ===========================================================
%   cell_locations : (cell array => {x y z} or [points by x,y,z]
%
%   OPTIONAL INPUTS
%   ===========================================================
%   threshold_sign     : (default 1)
%   reshape_output     : (default true)
%   initialized_logger : (default []), if passed in this
%        can save a decent amount of time between sequential
%        calls as it keeps data in memory instead of loading
%        from disk
%
%   IMPROVEMENTS
%   ===========================================================
%   1) Run a validation step that the passed in sim_logger
%   matches the settings currently applied to this simulation
%   object.
%
%   FULL PATH:
%   NEURON.simulation.extracellular_stim.sim__getThresholdsMulipleLocations

in.threshold_sign     = 1;
in.reshape_output     = true; %The output can either be an enumerated list
%or reshaped to a matrix if the input is a cell array {1 x 3} where the dimensions
%of the matrix are the lengths of the arrays in the cell array.
in.initialized_logger = []; %NO LONGER USED, this was for the old solver
%it saved time on multiple calls ...
in.merge_solvers      = false; %NO LONGER USED, took old solver results
%and put the results into the new solver format
in.use_new_solver     = false; %NO LONGER USED
%This was for when the solver used multiple different configurations
%and tried to merge them, i.e. if the stimulus was from 1 or 10 electrodes,
%as long as the appplied voltage was the same, the results would be the same,
%this ended up being a bit too memory intensive
in = NEURON.sl.in.processVarargin(in,varargin);

% if in.use_new_solver
    r  = obj.sim__getSingleAPSolver('solver','default');
    
    %NEURON.xstim.single_AP_sim.request_handler
    s = r.getSolution(cell_locations,'reshape_output',in.reshape_output);
    %NEURON.xstim.single_AP_sim.solution
    thresholds = s.thresholds;
% else
%     if isempty(in.initialized_logger)
%         sim_logger = NEURON.simulation.extracellular_stim.sim_logger;
%         
%         %NEURON.simulation.extracellular_stim.sim_logger.initializeLogging
%         sim_logger.initializeLogging(obj);
%     else
%         sim_logger = in.initialized_logger;
%     end
%     %NEURON.simulation.extracellular_stim.sim_logger.getThresholds
%     thresholds = sim_logger.getThresholds(cell_locations,in.threshold_sign);
%     
%     if in.merge_solvers
%         r  = obj.sim__getSingleAPSolver('solver','from_old_solver');
%         r.solver.sim_logger = sim_logger;
%         r.getSolution(cell_locations);
%     end
% 
%     if in.reshape_output && iscell(cell_locations)
%         sz = cellfun('length',cell_locations);
%         %Silly meshgrid :/
%         t = reshape(thresholds,[sz(2) sz(1) sz(3)]);
%         thresholds = permute(t,[2 1 3]);
%     end
% end
end