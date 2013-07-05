
% options = {'electrode_locations'  [1 2 3], ...
%           'tissue_resistivity'   obj.tissue_resistivity};
       
sim     = NEURON.simulation.extracellular_stim.create_standard_sim(options);
obj = Peterson_2011(sim);

function Peterson_2011(sim)
    log     = sim.getLogger;
    xIDs    = log.find_partial('elec_objs','tissue_obj');
    %xID     = log.find(true);
%WE DONT HAVE TO DO THIS HERE! Given we are already in the peterson method
%means that this was not already solved and that xID should be the last
%value in here b/c this call was already done somewhere else higher up.
    
    obj.loadCSVdata(set);
end

function loadCSVdata(obj,set)    
    mdf_path = fullfile(getMyPath,'private',set,'mdf_thresholds.csv');
    data = readDelimitedFile(mdf_path,',','header_lines',3);
    obj.mdf = helper__processData(data);
end



%It might be best if the Peterson model maintains the connection from the
%IDs and the Logged data. 

obj.solve(xIDs); %this would be call from sim.sim__getThresholdsMulipleLocations()

function thresholds = solve(obj, xIDs,cell_locs, method)
    data = obj.trainer_manager.find(xIDs); %code should prolly load the mdf
    if isempty(data)
        obj.trainAndLoad(xIDs, true); %load it up/don't call finda again
        %obj.trainer_manager.find(xID); %data isn't really used
    end
    thresholds = obj.computeThresholdMultipleLocations(sim,cell_locs,method);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% first thing I would ask trainer_manager to do is to check if the trainer
% the obj already has access to is the one for the current ID, if so
% return. If not look through the xstim_IDs for a match with this trainer.

%Trainer_manager works with the MIMs? It maps a set of xstim_IDs to
%the address of the training data. When a match is found it loads the 
%appropriate data into the obj (ie the MDF1/MDF2/weights?)

%During the train step we create a new entry in the 