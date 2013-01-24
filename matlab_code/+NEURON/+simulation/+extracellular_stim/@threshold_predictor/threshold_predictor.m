classdef threshold_predictor < handle_light
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
        
        opt__score_rounding_precision = 1e-10 %This is on what level we
        %want to compare the low dimensional representations of the old and
        %new stimuli as being equal. Instead of using a 
    end
    
    properties
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
       
%        all_stimuli_sorted_low_d %A sorted version of all stimuli (old and new)
%        %using their low dimensional representation
%        original_index       %index of where the originals are in the sorted stimuli
%        
%        
%        
%        old_stim_index_in_sort  %index is old index, value is new index in sort
%        new_stim_index_in_sort  %"   "
%        
%        %Do I use this ?????
%        is_from_old_matrix   
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
            
            %TODO: Remove inputs and use properties instead ...
            obj.reduceDimensions(new_stim,old_stim);
        end
        
        %I want to get rid of this method ...
        function [new,old] = rereduceDimensions(obj,new_stim,old_stim)
           
            if isempty(new_stim)
                new = [];
            else
                new = bsxfun(@minus,new_stim,obj.data_mean)*obj.coeff;
                new = new(:,1:obj.n_pcs_keep);
            end
            
            if isempty(old_stim)
                old = [];
            else
                old = bsxfun(@minus,old_stim,obj.data_mean)*obj.coeff;
                old = old(:,1:obj.n_pcs_keep);
            end
        end
        
        function reduceDimensions(obj,new_stim,old_stim)
            %
            %   Call this method to reduce the dimensionality of the data
            %
            
            if isempty(old_stim)
                obj.data_mean        = mean(new_stim,1);
                [obj.coeff,scores_new,latent] = princomp(new_stim,'econ');
            else
                n_new = obj.n_new;               
                temp_data = [new_stim; old_stim];
                obj.data_mean = mean(temp_data,1);
                [obj.coeff,scores_both,latent] = princomp(temp_data,'econ');
              
                
            %Fixes:
            %1) Recompute scores based on coefficient
            %2) Round results to certain place
            
%                 temp_data_no_mean = bsxfun(@minus,temp_data,mean(temp_data));
%                 scores_both_2 = temp_data_no_mean*obj.coeff;
%                 scores_new_2 = scores_both_2(1:n_new,:);
%                 scores_old_2 = scores_both_2(n_new+1:end,:);
                
                scores_new = round2(scores_both(1:n_new,:),obj.opt__score_rounding_precision);
                scores_old = round2(scores_both(n_new+1:end,:),obj.opt__score_rounding_precision);
            end
            
            %How much should we keep
            %--------------------------------------------------------------
            csl = cumsum(latent) - latent(1);
            I = find(csl./csl(end) > obj.opt__PCA_THRESHOLD,1);
            
            obj.n_pcs_keep = I;
            
            %Reducing the dimensions
            %--------------------------------------------------------------
            obj.low_d_new_stimuli = scores_new(:,1:obj.n_pcs_keep);
            if ~isempty(old_stim)
                obj.low_d_old_stimuli = scores_old(:,1:obj.n_pcs_keep);
            end
        end
        
    end
    
end

