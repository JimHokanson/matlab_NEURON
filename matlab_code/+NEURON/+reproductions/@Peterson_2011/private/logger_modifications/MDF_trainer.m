classdef MDF_trainer < handle_light
    % This class is intened to handle the sets of xIDs and map them to the
    % appropriate set of traininng data. The reason it maps a set is sso
    % 
    %
    % Some simulations may have been predicted with another method other
    % than the Peterson eresion. if/when this is the case When you find a
    % partial match, some of them may be logged with the trainer as a match
    % for a certain set of data, while some may not even though they are...
    % You only need to find one that matches for them all to... But at that
    % point ya might wanna log 'em anyway... OR maybe not is we can trust
    % that the first will always exist and all of the sets have unique
    % members.
    
    properties
        parent
        xID_sets %col1 xidset, col2 mdf1, col3 mdf2, col4 weights?
        %^ that is a cell_array
    end
    properties
        VERSION = 1;
    end
    %Constructor ==========================================================
    methods(Access = private)
        function obj = MDF_trainer()
            loadIDset(obj)
        end
    end
    %Static Getter ========================================================
    methods(Static)
        function obj = getInstance(parent)
            % this function is only called in the constructor of the
            % predictor, which is why we just reset the parent.
            persistent train
            if isempty(train)
                train = @NEURON.reproductions.Peterson_2011.MDF_trainer;
            end
            obj = train;
            obj.parent = parent;
        end
    end
    %Save/load and Add functionality ======================================
    methods
        function loadIDset(obj)
            s = load(path);
            if s.VERSION == obj.VERSION
                obj.xID_sets = s.xID_sets;
            else
                error('VERSION error, implement an update function')
            end
        end
        function saveIDset(obj)
            s = struct;
            s.VERSION   = obj.VERSION;
            s.xID_sets  = obj.xID_sets;
            save(path, s);
        end        
    end
    %Training Code ========================================================
    methods
        function setName = train(obj, xIDs, method, iRow)
            % Might make this private, it should nto be called by the user,
            % only by getSet...
            %
            % in this code we are going to need to be able to regenerate a
            % sample simulation and vary it, to appropraitely create the
            % lookup table and save it under 'setName'
            temp = struct;
            temp.method = method;
            temp.diameters = [5.7 7.3 8.7 10 11.5 12.8 14 15 16]; %um
            if method == 1
                temp.pulse_width = [.02 .05 .1 .2 .5 1 2 5 10];
            elseif method == 2
                temp.pulse_width = [.02 .05 .1 .2 .5 1 2];
            else
                error('Invalid option, only 1 & 2 supported')
            end
            
            
            %is there a means to alter the pulse_width in our electrode
            %model???
            %For our trianig data will we too use a monophasic square
            %pulse?
            
            %I'm not exaclty sure what strategy we can use to regereate the
            % unique V/M values...
            
            
            %now assuming we have the needed V,M values...
            temp.ve = V;
            temp.mdf = M;
            setName = datestr(now, 'yyyymmddTHHMMSSFFF');
            
            %add set to xID_set
            
            if isnan(iRow)
                %create a new cell entry
            else
                met = method + 1;
                obj.xIDset{iRow, met} = setName;
            end
            saveIDset(obj)            
            save(path,temp) % its path is generated for the setName...
            %see loadCSV
            
            obj.parent.mdf = temp;
            
        end
        function setName = getSet(obj, method, xIDs)
            % obtains the name of the data_set for the given xIDs such that
            % it can be loaded into the parent
            %input xIDS is a cell_array of xIDs... lets extract teh row
            %number from the MIMs logger from them, and use tht to sort
            %through these... perhaps we only have a vector of numbers that
            %repressnt the MIMs row number for the set of XIDs in the
            %xid_set property.
            %
            % Improvements: if we can make sure the values are always
            % sorted in the sets... xIDs will be sorted... but I'm not sure
            % about the ones in xID_sets property
            
            xID_tags = zeros(1, length(xIDs));
            for iTag = 1:length(xIDs)
                xID_tags(iTag) = xIDs(iTag).getTrialRow; %does this exists? no. :P
            end
            
            %find set in the cell_array of sets. Again we are assuming that
            %the sets contain unique members...
            rows = length(obj.xID_sets);
            
            found = false;
            for iRow = 1:rows
                set = obj.xID_sets{iRow,1};                 %ummm syntax???
                matches = ismember(xID_tags, set); 
                if matches
                    %new_match = find(~matches);
                    set = [set, xID_tags(~matches)];                %#ok
                    found = true;
                    obj.xID_sets{iRow,1} = set;                    %syntax?
                    break; %do i want this or continue???           syntax
                end
            end
            
            if found
                if method == 1
                    setName = obj.xID_sets{iRow, 2};                %syntax
                    if ismepty(setName)
                        setName = obj.train(xIDs,1,iRow);
                    end
                elseif method ==2
                    setName = obj.xID_sets{iRow, 3};                %syntax
                    if ismepty(setName)
                        setName = obj.train(xIDs,2,iRow);
                    end
                else
                    error('Invalid option, only 1 & 2 supported')
                end                
            else
                setName = obj.train(xIDs,method,nan);
            end                        
        end
    end

end