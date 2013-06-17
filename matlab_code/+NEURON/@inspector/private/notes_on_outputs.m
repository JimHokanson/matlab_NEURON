%{

%FILENAME: notes_on_outputs.m

Inspector examples: (for later parsing)

 %   [~,str] = c.run_command('allobjects()');
    %   Example Output:
    %   --------------------------------
    % SectionList[0] with 1 refs
    % SectionList[1] with 1 refs
    % StringFunctions[0] with 1 refs
    % List[0] with 1 refs
    % List[1] with 1 refs
    % List[2] with 1 refs
    % List[3] with 1 refs
    % List[4] with 1 refs
    % List[5] with 1 refs
    % List[6] with 1 refs
    % List[7] with 1 refs
    % Vector[0] with 1 refs
    % Vector[1] with 1 refs
    % CVode[0] with 2 refs
    % NumericalMethodPanel[0] with 2 refs
    % 0
    %   [~,str] = c.run_command('allobjects("SectionList")');
    %   SectionList[0] with 1 refs
    %   SectionList[1] with 1 refs
    %   0
    %
    %[~,str] = c.run_command('allobjectvars()');
    %obp hoc_obj_[0] -> NULL
    % obp hoc_obj_[1] -> NULL
    % obp hoc_sf_[0] -> StringFunctions[0] with 1 refs.
    % obp clipboard_file[0] -> NULL
    % obp clipboard_file[1] -> NULL
    % obp tempobj[0] -> NULL
    % obp cvode[0] -> CVode[0] with 2 refs.
    % obp movie_timer[0] -> NULL
    % obp movierunbox[0] -> NULL
    % obp tobj[0] -> NULL
    % obp tobj1[0] -> NULL
    % obp nrnmainmenu_[0] -> NULL
    % obp numericalmethodpanel[0] -> NumericalMethodPanel[0] with 2 refs.
    %    obp atoltool_[0] -> NULL
    %    obp b1[0] -> NumericalMethodPanel[0] with 2 refs.
    %    obp b[0] -> NULL
    %    obp this[0] -> NumericalMethodPanel[0] with 2 refs.
    %    obp cvode[0] -> CVode[0] with 2 refs.
    % obp graphList[0] -> List[0] with 1 refs.
    % obp graphList[1] -> List[1] with 1 refs.
    % obp graphList[2] -> List[2] with 1 refs.
    % obp graphList[3] -> List[3] with 1 refs.
    % obp graphItem[0] -> NULL
    % obp flush_list[0] -> List[4] with 1 refs.
    % obp fast_flush_list[0] -> List[5] with 1 refs.
    % obp tempobj2[0] -> NULL
    % obp xstim__all_sectionlist[0] -> SectionList[0] with 1 refs.
    % obp xstim__node_sectionlist[0] -> SectionList[1] with 1 refs.
    % obp xstim__stim_vector_list[0] -> List[7] with 1 refs.
    % obp xstim__v_ext_in[0] -> Vector[0] with 1 refs.
    % obp xstim__t_vec[0] -> Vector[1] with 1 refs.
    % obp xstim__node_vm_hist[0] -> List[8] with 1 refs.
    % 	0
    %
    %
    %   objref scobj
    %   scobj = new SymChooser()
    %   scobj.run()
    %

%}