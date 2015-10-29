classdef results_path_manager < NEURON.sl.obj.handle_light
    %
    %
    %
    %
    
    properties
    end
    
    methods (Static)
        function base_path = getMyBasePath(my_obj)
            %
            %   base_path = NEURON.xstim.results_path_manager.getMyBasePath(my_obj)
            %
            %   base_path = NEURON.xstim.results_path_manager.getMyBasePath(class_name)
            %   
            %   INPUTS
            %   ===========================================================
            %   my_obj : Reference to class for which to get the base path.
            %       This is not an instance of this particular class ...
            %   class_name : Instead of passing in the class you can
            %       also pass in the fully qualified class name ...
            %
            %
            %   FULL PATH:
            %   NEURON.xstim.results_path_manager.getMyBasePath
            
            if ischar(my_obj)
                class_name = my_obj;
            else
                class_name = class(my_obj);
            end
            
            u = NEURON.user_options.getInstance;
            
            %TODO: Provide error checking in options object
            %
            %Allow link to providing more results ...
            root = u.xstim_results_base_path;
            if isempty(root)
                error('results base path must be specified in options')
            end

            switch class_name
                case 'NEURON.xstim.single_AP_sim.logged_data'
                    base_path = fullfile(root,'single_AP_threshold','logged_data');
                case 'NEURON.xstim.single_AP_sim.new_solution'
                    base_path = fullfile(root,'single_AP_threshold','new_data');
                otherwise
                    error('class: %s, not yet handled',class_name)
            end
            
            NEURON.sl.dir.createFolderIfNoExist(base_path);
            
        end
    end
    
end

