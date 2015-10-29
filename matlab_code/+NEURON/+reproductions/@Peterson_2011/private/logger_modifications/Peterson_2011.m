classdef Peterson_2011 < NEURON.sl.obj.handle_light
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        mdf
        trainer
        parent %? will this be needed a lot?
    end
    
    methods
        function obj = Peterson_2011(sim, method)
            obj.parent = sim;
            log     = sim.getLogger;
            xIDs    = log.find_partial('elec_objs','tissue_obj');
            %xID     = log.find(true);
            %WE DONT HAVE TO DO THIS HERE! Given we are already in the peterson method
            %means that this was not already solved and that xID should be the last
            %value in here b/c this call was already done somewhere else higher up.
            
            %This still is not all the processing that we want on the xIDs,
            %we also want to make sure there is a match for the stimulus...
            
            obj.trainer = NEURON.reproductions.Peterson_2011.MDF_trainer.getInstance(obj);
            set = obj.trainer.getSet(method, xIDs);
            obj.loadCSVdata(set);
        end
        
        function loadCSVdata(obj,set)
            mdf_path = fullfile(getMyPath,'private',set,'mdf_thresholds.csv');
            data = readDelimitedFile(mdf_path,',','header_lines',3);
            obj.mdf = helper__processData(data); %that code wasn't changed
        end
    end
    
    methods
        function MDF = computeMDF1(obj,V,n_use)
            % Calculate MDF1
            % MDF = MDF1(V) calculates the MDF at all nodes from voltage
            % vector V and returns a vector of MDF values
            % MDF = MDF1(V,n_use) calculates MDF at node(s) n from voltage vector
            % (V)
            %
            % NOTE: This was previously a static method, but has been
            % changed for consistency with computeMDF2
            
            N = length(V);
            
            if ~exist('n_use','var')    
                n_use = 2:N-1; % all nodes except ends
            end
            
            if any(n_use == 1) || any(n_use == N)
                error('MDF cannot be computed at the ends of an axos (nodes 1 and N).')
            end
            
            MDF = zeros(1,length(n_use));
            
            i_n_use = 0;
            for n = n_use
                i_n_use = i_n_use + 1;
                MDF(i_n_use) = V(n-1) - 2*V(n) + V(n+1);
            end            
        end
        
        function [v,m] = getVM(obj,fiber_diameter,pulse_width)
            
            temp = obj.mdf;            
            % lookup mdf threshold data
            I_fiber = find(abs(temp.diameters - fiber_diameter) < 2*eps,1);
            J_pw = find(abs(temp.pulse_widths - pulse_width) < 2*eps,1); % was getting a weird floating point error, this fixes it
            
            %I_fiber = find(temp.diameters == fiber_diameter,1);
            %J_pw = find(temp.pulse_widths == pulse_width,1);
            % Ve, MDF
            v = temp.ve{I_fiber,J_pw};
            m = temp.mdf{I_fiber,J_pw};
            
            [v,I] = sort(v);
            m = m(I);
            
            v = -v; % negate, v's should be negative
            
            % simplify and sort
            simp = sigp.dpsimplify([v(:) m(:)],eps);
            v = simp(:,1);
            m = simp(:,2);
            %End of move to function ...
            %--------------------------------------
        end
        
        function MDF = computeMDF2(obj,V,PW,d,n_use)
            % Calculate MDF2
            % MDF = MDF2(V,PW,d) calculates the MDF at all nodes from voltage
            % vector V and returns a vector of MDF values
            % MDF = MDF2(V,PW,d,n) calculates MDF at node n from voltage vector
            % (V)
            %
            % required inputs:
            % V : voltage at each node (vector)
            % PW: pulse width
            % d : fiber diameter
            
            W = obj.getWeights(PW,d);
            N = length(V);
            
            if ~exist('n_use','var')
                n_use = 2:N-1; % all nodes except ends
            end
            
            if any(n_use == 1) || any(n_use == N)
                error('MDF cannot be computed at the ends of an axon (nodes 1 and N).')
            end
            
            MDF = zeros(1,length(n_use));
            
            i_n_use = 0;
            for n = n_use
                i_n_use = i_n_use + 1;
                for j = 2:N-1
                    k = abs(n-j);
                    if k > 10 % weights only exist for k = 0:10
                        continue
                    end
                    MDF(i_n_use) = MDF(i_n_use) + W(k+1)*(V(j-1) - 2*V(j) + V(j+1));
                end
            end
            
        end
    end
    
end

