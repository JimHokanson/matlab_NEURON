classdef solver < handle
    %
    %   Class:
    %   NEURON.xstim.single_sim.solver
    
    %See for reference
    %   NEURON.xstim.single_AP_sim.solver
    
    properties
        old_data
        new_data
        xstim
        is_unique
        source_I
        is_old_source
    end
    
    methods
        function obj = solver(old_data,new_data,xstim,new__is_unique,new__source_I,is_old_source)
            obj.old_data = old_data;
            obj.new_data = new_data;
            obj.xstim = xstim;
            
            %This is sort of awkward ...
            %- could maybe have code here or hold all of this info
            %in a class of its own ...
            obj.is_unique = new__is_unique;
            obj.source_I = new__source_I;
            obj.is_old_source = is_old_source;
        end
        function getSolutions(obj)
            %removing 
            h__solve(obj)
            
            %This shouldn't be done, otherwise 
            %we'll get redundant entries
            %when we call this again in the result hanlder
            %
            %ideally we would move the merging code here ...
            %obj.old_data.addEntries(obj.new_data);
        end
    end
end

function h__solve(obj)

unique_mask = obj.is_unique;

I_tests = find(obj.is_unique);
%SETUP 
%--------------------------------------------------------------------------
cell_locations = obj.new_data.cell_locations(unique_mask,:);
scales = obj.new_data.tested_scales(unique_mask);

xstim_local = obj.xstim;
cell_local = xstim_local.cell_obj;

n_tests  = length(scales);

nd = obj.new_data;
xstim_local.options.display_time_change_warnings = false;

%How to divide up the display?????

fprintf(2,'Running %d new simulations\n',n_tests);

for i = 1:n_tests
    if mod(i,10) == 0
        %save
        fprintf(2,'%d,',i);
    else
        fprintf(2,'.');
    end

    if mod(i,50) == 0
        fprintf(2,'\n')
    end

    %Move cell
    cell_local.moveCenter(cell_locations(i,:));

    %NEURON.simulation.extracellular_stim.sim__determine_threshold
    %NEURON.simulation.extracellular_stim.threshold_analysis.determine_threshold
    
    %TODO: push this option higher ...
    AUTO_EXPAND = true;
    result_obj = xstim_local.sim__single_stim(scales(i),AUTO_EXPAND);
    
    %We'll dump right into r.the solution ...
    I = I_tests(i);
    r = result_obj;
    nd.solved(I) = true;
    nd.success(I) = r.success;
    nd.tissue_fried(I) = r.tissue_fried;
    nd.initial_stim_time(I) = r.initial_simulation_time;
    nd.final_stim_time(I) = r.final_simulation_time;
    nd.membrane_potential{I} = r.membrane_potential;
    nd.ap_propagated(I) = r.ap_propagated;
    nd.solve_dates(I) = now;
    
    if mod(i,50) == 0
        nd.saveToDisk();
    end
end


end
