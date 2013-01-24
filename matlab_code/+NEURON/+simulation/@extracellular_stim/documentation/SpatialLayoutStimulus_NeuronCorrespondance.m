%{

Spatial Layout Stimulus - NEURON correspondance

SUMMARY
===========================================================================
The goal of this document is to clarify how the stimulus is applied to a
cell in a spatially correct manner. When creating a cell for extracellular
stim modeling it is important that the xyz order matches the order that is
given to NEURON for the stim section list, so that the first segment of the
first section is xyz(1,:), the second segment is xyz(2,:), the 1st segment
of the second section is xyz(n_segs_section_1+1,:), etc.

MORE DETAILS
===========================================================================
1) The cell creates a list of sections for extracellular stimulation. See:
        NEURON.cell.extracellular_stim_capable.create_stim_sectionlist
2) Each cell class must define a matrix of 3d spatial positions which correspond
to each segment with each section in the section list. This is set in the
variable .xyz_all of the extracellular_stim_capable class.

3) The stimulus is created by extracellular stim in relation to these 3d
points and sent to NEURON. When applying the stimulus, NEURON transverses 
the stim section list, created by step 1. For each segment in the section
the next point in the stimulus matrix is applied.

Here is some pseudocode:

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