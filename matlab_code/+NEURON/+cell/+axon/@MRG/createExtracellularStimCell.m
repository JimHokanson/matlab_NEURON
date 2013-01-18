function createExtracellularStimCell(obj)

    %NEURON.cell.axon.MRG.createCellInNEURON
    cell_defined = obj.createCellInNEURON();
    
    %??? How do we know if we need to reinitialize the spatial info????
    
    %NOTE: I think we currently have a potential error case
    %If we recompute the xstim setup, but we don't change
    %the spatial info, then we might not recompute the stimlus
    %even though our vectors have been redefined in NEURON
    %
    %TODO: Fix this ...
    %
    %For now, link to neuron creation ...
    if cell_defined
        cmd_obj = obj.cmd_obj;
        %NEURON.cell.extracellular_stim_capable.runDefaultXstimSetup
        obj.runDefaultXstimSetup(cmd_obj);
    end

end