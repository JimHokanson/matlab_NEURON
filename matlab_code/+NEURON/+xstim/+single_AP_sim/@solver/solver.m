classdef solver < handle

    properties
        request_handler
    end
    
    methods(Abstract)
        predictThreshold(obj, sign, cell_locations)
    end
    methods
        function obj = solver(predictor_model, request_handler)
            obj.request_handler = request_handler;
            %{ 
            % should we switch on the predictor models?
            switch (predictor_model)
                
            end
            %}
        end
    end
    %======================================================================
    % Question: Will we need to re-write our old code for the matching
    % stimuli predictor algorithm or can we just edit what we have to work
    % with this framework instead?
    %
    % ie: once the indices to the unknown cell_loctation is reteived as well
    % as the applied_stimuli, what are the significant differences in  
    % implementation from before to now when we predict using our current 
    % algorithm?
    %
    % We were interested in adding modularitiy to the implementaion of how
    % we chose to determine which points to learn. This variations however
    % can be defined (but constant) in the particular predictor.
    %
    % in theory the matcher only needs: the cell_locations and the stim
    % we can still regenerate both. Should we then edit codes to manage them
    % accordinng to this new framework... ?
end