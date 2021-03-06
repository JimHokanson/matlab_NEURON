classdef Peterson_2011 < handle
    %
    %   Class: NEURON.reproductions.Peterson_2011
    %
    %   ??? - does this model support anodic excitation prediction?
    
    %Abbreviations:
    %EAS
    %MDF
    
    properties (Hidden)
        
        %Why were these hardcoded here ????
        all_fiber_diameters = 4:2:20 %microns
        all_pulse_durations = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5] %ms
        
        eleven_electrode_amps = {0.4 -1 0.7 -1 0.7 -1 0.7 -1 0.7 -1 0.4} % defined in fig 1d
        
        resistivity_transverse   = 100/0.083 % S/m -> ohm cm
        resistivity_longitudinal = 100/0.33
        
        %NOTE: Nodes are
        %mdf2 %pulse duration, diameter, node
        %Model expects 21 nodes ...
        
        %        %Precomputed for us
        %        %.diameter
        %        %.pulse duration
        %        %.ve
        %        %.mdf_output
        %        mdf1_thresholds
        %        mdf2_thresholds
    end
    
    properties (Hidden)
        
    end
    
    properties
        %.ve (cell array of arrays, [diameters pulsewidths])
        %.mdf
        %.diameters - unique diameters for indexing
        %.pulse_widths - unique pulse widths for indexing
        mdf1
        
        
        %NOTE: Nodes are
        mdf2 %pulse duration, diameter, node
        %Model expects 21 nodes ...
        
        weights % for use with mdf2.
        % NOTE: While mdf1 and mdf2 are populated in constructor from CSV
        % files, weights is populated from mat file the first time
        % getWeights is called
    end
    
    methods
        %NEURON.reproductions.Peterson_2011
        function obj = Peterson_2011
            %TODO: Populate mdf2
            %
            %    p = NEURON.reproductions.Peterson_2011;
            
            obj.loadCSVdata;
            
        end
        function options = getDefaultOptions(obj)
            options = {...
                'tissue_resistivity', [obj.resistivity_transverse obj.resistivity_transverse obj.resistivity_longitudinal]};
        end
        
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
        
        function [v,m] = getVM(obj,method,fiber_diameter,pulse_width)
            
            if method == 1 % mdf1
                temp = obj.mdf1;
            elseif method == 2 % mdf2
                temp = obj.mdf2;
            else
                error('Invalid option, only 1 & 2 supported')
            end
            
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
    
    methods (Static)
        function thresh_error = thresholdError(I_predicted,I_simulated)
           % Percent error (eqn 4)
           
           if isrow(I_simulated) % fix dimension mismatch
               I_simulated = I_simulated';
           end
           
           thresh_error = ((I_predicted - I_simulated)./I_simulated)*100;
        end
    end
    
    methods
        %This is old code that needs to be updated ...
        %-------------------------------------------------------------------
        function options = getElevenElectrodeStimOptions(obj,adjacent_spacing,stim_duration,eas)
            %See page 4
            %Adjacent electrode spacing - 400:100:1500 um
            %EAS held at 200 um
            
            %EAS = 200;
            STIM_START_TIME = 0.1;
            
            stim_scales  = [0.4 -1 0.7 -1 0.7 -1 0.7 -1 0.7 -1 0.4];
            stim_centers = -adjacent_spacing*5:adjacent_spacing:adjacent_spacing*5;
            
            electrode_locations = zeros(11,3);
            electrode_locations(:,1) = eas;
            electrode_locations(:,3) = stim_centers;
            
            options = {...
                'electrode_locations',   electrode_locations,...
                'stim_scales',           num2cell(stim_scales),...
                'stim_durations',        num2cell(stim_duration*ones(1,11)),...
                'stim_start_times',      STIM_START_TIME*ones(1,11)};
            
        end
    end
    
end

