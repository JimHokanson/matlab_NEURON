classdef threshold_predictor < NEURON.sl.obj.handle_light
    %
    %
    %   CLASS:
    %       NEURON.simulation.extracellular_stim.threshold_predictor
    %
    %   NOTE: Could eventually subclass with different implementations
    %
    %   METHODS IN OTHER FILES
    %   ===================================================================
    %   NEURON.simulation.extracellular_stim.threshold_predictor.getGroups
    %   NEURON.simulation.extracellular_stim.threshold_predictor.predictThresholds
    %
    %   METHODS
    %   ===================================================================
    %   1) Given new stimuli and locations, break up into reasonable groups
    %      for testing
    %   2)
    
    properties
        opt__n_sims_per_group = 20
        opt__PCA_THRESHOLD    = 0.99 %Careful, this isn't the typical variance
        %cutoff that is typically used. Instead this indicates the
        %accounted for variance after subtracting the first dimension and
        %normalizing by the remaining max. In other words, how many of the
        %remaining dimensions need to be retained to account for a certain
        %percentage of the remaining variance. The loose thought behind
        %this was that the first dimension can account for a large amount
        %of the variance and I wanted to make sure we got just a few more
        %dimensions than we might normally get, as these higher dimensions
        %might actually prove to be important.
        opt__TESTING_PERCENTAGE_SPACING = 0.05; %For obtaining testing groups
        %we currently choose points that are furthest away from known
        %points. Each time we choose this point, we take the unknown
        %distance that it removes (distance from it to cloest known point)
        %and add it to some running value. Choosing the points makes it "known".
        %After we have done this for all
        %points, we can see how much each point reduced the total unknown
        %distance, viewed as a cumulative distribution (CD). In general by
        %definition the first points will contribute more to this CD than
        %will later points as at the time of their picking they are now closer to known
        %points. Given this CD we break up it up into percentage chunks.
        %The chunk size is determined by this value. After each chunk we
        %update our predictions regarding the next chunk. If we make this
        %value too small, we may spend too much time predicting values.
        %Roughly speaking the prediction algorithms take up some fixed time
        %T, with some other factor that is dependent on the # of inputs
        %total_time = T + T2*number_of_points
        %In general we might expect that T2 is small such that there
        %isn't much of a penalty with using a large # of points.
        %THIS IS A CRAPPY EXPLANATION
        %However if we make this value too large, we never update
        %our predictions which means it takes longer to get our answers as
    end
    
    %PCA props ============================================================
    properties (Hidden)
        coeff
        data_mean   %Mean of old and new stimuli combined ...
        n_pcs_keep
    end
    
    properties
       %.threshold_predictor()
       cell_locations_old
       cell_locations_new
       old_thresholds   %(row vector)
        
       old_stimuli       = []
       new_stimuli       = []
       
       %.reduceDimensions()
       low_d_old_stimuli = []
       low_d_new_stimuli = []
       
    end
    
    properties (Dependent)
       n_new
       n_old 
    end
    
    methods 
        function value = get.n_new(obj)
           value = size(obj.new_stimuli,1); 
        end
        function value = get.n_old(obj)
            value = size(obj.old_stimuli,1);
        end
    end
    
    methods
        function obj = threshold_predictor(...
                new_stim,...
                old_stim,...
                cell_locations_old,...
                cell_locations_new,...
                old_thresholds)
            %
            %
            %   obj = threshold_predictor(new_stim,old_stim)
            %   
            %   INPUTS
            %   ===========================================================
            %   new_stim - 
            %   old_stim -
            %
            %   IMPROVEMENT
            %   =================================================
            %   1) Expose options in constructor 
            
            obj.cell_locations_old = cell_locations_old;
            obj.cell_locations_new = cell_locations_new;
            obj.old_thresholds     = old_thresholds;
            
            obj.old_stimuli = old_stim;
            obj.new_stimuli = new_stim;
            
            obj.reduceDimensions();
        end        

        
    end
    
end

