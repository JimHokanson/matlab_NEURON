classdef threshold_predictor < handle_light
    %
    %
    %
    %   NOTE: Could eventually subclass with different implementations
    %
    %   METHODS
    %   ===================================================================
    %   1) Given new stimuli and locations, break up into reasonable groups
    %      for testing
    %   2)
    
    properties
        opt__n_sims_per_group = 20
    end
    
    properties
       coeff
       data_mean
       n_pcs_keep
    end
    
    methods
        function [new,old] = rereduceDimensions(obj,new_stim,old_stim)
            new = bsxfun(@minus,new_stim,obj.data_mean)*obj.coeff;
            old = bsxfun(@minus,old_stim,obj.data_mean)*obj.coeff;
            new = new(:,1:obj.n_pcs_keep);
            old = old(:,1:obj.n_pcs_keep);
        end
        function [low_d_new,low_d_old] = reduceDimensions(obj,new_stim,old_stim)
            
            PCA_THRESHOLD = 0.99; %Weird threshold definition, see implementation below
%Essentially this is a similar idea as a normal variance cutoff but AFTER
%normalizing everything so that the first PCA is at 0
            
            n_new_stimuli  = size(new_stim,1);
            
            if isempty(old_stim)
                obj.data_mean = mean(new_stim,1);
                [obj.coeff,score,latent] = princomp(new_stim,'econ');
            else
                temp_data = [new_stim; old_stim];
                obj.data_mean = mean(temp_data,1);
                [obj.coeff,score,latent] = princomp(temp_data,'econ');
            end
            
            csl = cumsum(latent) - latent(1);
            I = find(csl./csl(end) > PCA_THRESHOLD,1);
            
            obj.n_pcs_keep = I;
            
            if isempty(old_stim)
                low_d_new = score(:,1:I);
                low_d_old = [];
            else
                low_d_new = score(1:n_new_stimuli,1:I);
                low_d_old     = score(n_new_stimuli+1:end,1:I);
            end
        end
    end
    
end

