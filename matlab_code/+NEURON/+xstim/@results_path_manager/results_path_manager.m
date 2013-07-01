classdef results_path_manager < sl.obj.handle_light
    %
    %
    %
    %
    
    properties
    end
    
    methods (Static)
        function base_path = getMyBasePath(my_obj)
            %
            %   base_path =
            %   NEURON.xstim.results_path_manager.getMyBasePath(my_obj)
            %   
            %   FULL PATH:
            %   NEURON.xstim.results_path_manager.getMyBasePath
            
            class_name = class(my_obj);
            
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
                otherwise
                    error('class: %s, not yet handled',class_name)
            end
            
            sl.dir.createFolderIfNoExist(base_path);
            
        end
    end
    
end

