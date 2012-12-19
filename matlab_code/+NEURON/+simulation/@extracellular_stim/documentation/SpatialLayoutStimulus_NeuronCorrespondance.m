%{

The goal of this document is to clarify how the stimulus is applied to a
cell in a spatially correct manner.

1) The cell creates a list of sections for extracellular stimulation. See:
NEURON.cell.extracellular_stim_capable.create_stim_sectionlist
2) Each cell must define a matrix of 3d spatial positions which correspond
to each segment with each section in the section list
3) Extracellular stim computes the applied voltage and then does the
following to apply the stimulus (roughly speaking)

xstim__all_secs - list of all sections in the cell

for each section in xstim__all_secs
    for each segment in the current section
        cur_index = cur_index + 1
        %NOTE: It is here that the xyz_all should match what would be
        %observed for xyz_all(cur_index)
        apply_stimulus(stimulus_vector(cur_index))
    end
end

%}