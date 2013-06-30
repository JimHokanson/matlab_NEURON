classdef logged_data < sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.logged_data
    %
    %
    % This class is in charge of saving/loading each data instance and
    % maintaining which predictor is being used to generate this information
    % especially useful for testing, we are going to want to insure that the
    % different predictor methods do not generate different outcomes.
    %
    %
    %   Questions:
    %   ======================================================
    %   1) 

    properties
        sign
        
        %Old values
        %----------------------------------------------
        cell_locations
        pos_thresholds
        neg_thresholds
    end 
    
    properties
        predictor
        parent
    end
    
    properties
        stim_base
        stim_old
        thresholds_old
        cell_locations_old
    end
    
    properties(Constant)
        VERSION = 1;
    end
    
    methods
        function obj = logged_data(xstim,sign,xstim_id)
            % populates properties 
            obj.parent = xstim;
            % log = xstim.getLogger();
            obj.sign = sign;
        end
        function load_data(obj)
            %I'm not exactly sure what form the output should take, but
            %this would return the cell_locations of previously run trials
            %as well as the sign they were run with
            % opens from path and reformats
            h = load(savePath);
            if (h.VERSION ~= obj.VERSION)
                %throw an error
            end
            obj.thresholds_old     = h.thresholds_old;
            obj.stim_base          = h.stim_base;
            %obj.recreateStimuli();
            obj.cell_locations_old = h.cell_locations_old;
        end
        function save_data(obj)
            %called by request_handler thru predictor_obj?
            % saves at right path
            savePath = get_savePath();
            h = struct;
            h.VERSION            = obj.VERSION;
            h.stim_base          = obj.stim_base;
            h.thresholds_old     = obj.thresholds_old;
            h.cell_locations_old = obj.cell_locations_old;
            save(savePath, h);
        end
        function get_savePath(obj)
            % may or may not actually be necessary here...
        end
        function recreateStimuli(obj)
            % should be called from predictor
             linear_elec = obj.stim_base;
             stim = [];
%             %==================================================
%             % part of how we might generate the stim_old
%             %==================================================
%             index = 1;
%             len = length(linear_elec);
%             while index > len
%                 n_elec = linear_elec(index);
%                 elec_top = index + 1;
%                 elec_end = index + 3*n_elec;
%                 temp = linear_elec(elec_top:elec_end);
%                 xyz_all = reshape(temp,3,n_elec)';
%                 stim_temp = mergeStimTimes(xyz_all); 
%                 % that code ^ will need alterations...and getLogData???
%                 stim = [stim stim_temp];
%                 index = elec_end + 1;
%             end
            obj.stim_old = stim; 
        end
        
        %{
        %          Not Sure Yet Where This Will Go
        %===================================================
        %    part of how we might generate the stim_base
        %===================================================
        n_electrodes = length(electrodes);
        xyz_all = [];
        
        for iElec = 1:n_electrodes
            xyz_all = [xyz_all electrodes(iElec).xyz];
        end
        elec_data = [n_electrodes xyz_all];
        obj.stim_base = [obj.stim_base elec_data];      
        %} 
        
    end

end