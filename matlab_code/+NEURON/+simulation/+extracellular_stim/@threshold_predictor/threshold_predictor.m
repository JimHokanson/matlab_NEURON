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
    end
    
    properties
        coeff
        data_mean   %Mean of old and new stimuli combined ...
        n_pcs_keep
    end
    
    properties
       old_stimuli       = []
       new_stimuli       = []
       %.reduceDimensions()
       low_d_old_stimuli = []
       low_d_new_stimuli = []
       
       all_stimuli_sorted
       is_old_matrix     
    end
    
    methods
        function obj = threshold_predictor(new_stim,old_stim)
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
                obj.low_d_old_stimuli = scores_temp(1:
            else
                n_new = size(new_stim,1);                
                temp_data = [new_stim; old_stim];
                obj.data_mean = mean(temp_data,1);
                [obj.coeff,scores_both,latent] = princomp(temp_data,'econ');
                scores_new = scores_both(1:n_new,:);
                scores_old = scores_both(n_new+1,:);
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
        
        function getStimuliMatches(obj)
           %
           %    NOTE: The goal of placing this method in this object is
           %    that this class gets to decide what the same is.
           %
            
           %1) Redundant old stimuli 
           %2) Redundant new stimuli
           %3) Redundant stimuli between new and old ...
        end
    end
    
end

