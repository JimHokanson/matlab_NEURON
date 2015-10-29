classdef sectionlist < NEURON.sl.obj.handle_light
    %
    %   Class:
    %       NEURON.classes.sectionlist
    %
    %   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/classes/seclist.html#SectionList
    %
    %   IMPROVEMENTS
    %   ========================================
    %   1) Provide method for summarizing sections available
    %   2) Provide the ability to get a section from the sectionlist    
    
    properties (Hidden)
        cmd_obj
    end
    
    properties
        name            %(string) Name used in NEURON to refer to SectionList
        section_names   %(cellstr, column vector) Name of all sections
        n_sections
        %unique_prefixes  %Could show how many of each type are available
        %What if entries are missing????? - perhaps do a number range
        % 0 - 39 or if missing 0 - 10 15-20 etc
    end
    
    methods
        function obj = sectionlist(cmd_obj,name)
            %sectionlist
            %
            %   obj = sectionlist(cmd_obj,name)
            %
            %   INPUTS
            %   ============================================
            %   cmd_obj : NEURON.cmd
            %   name    : name of this sectionlist
            %
            %   FULL PATH:
            %   NEURON.classes.sectionlist
            
            obj.cmd_obj = cmd_obj;
            obj.name    = name;
            update(obj)
        end
        function update(obj)
           populateNames(obj) 
        end
    end
    
    methods (Hidden)
        %NEURON => .printnames()
        function populateNames(obj)
            %populateNames
            %
            %   populateNames(obj)
            %   
            
            
            cmd_str = sprintf('{%s.printnames()}',obj.name);
            
            [~,result] = obj.cmd_obj.run_command(cmd_str);
            
            obj.section_names = regexp(result,'\n','split');
            obj.n_sections = length(obj.section_names);
            
        end
    end
    
end

