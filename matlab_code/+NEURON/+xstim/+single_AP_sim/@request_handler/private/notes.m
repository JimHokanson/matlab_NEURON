%TODO: Flush this out ...
%
%1) Prediction mechanism (solver)
%2) Algorithm for determining next things to solve (make a
%class)
%3) Full solution solver
%
%   Other classes:
%   -----------------------------------
%   1) Results class

%1) Prediction
%- Inputs
%       - locations to solve
%           - only provide unsolved points as inputs
%           - let request handler merge with previously known
%               points
%
%2) Learned points
%    - responsible for saving itself
%    - provides new points
%    - perhaps some timing information
%          - i.e. some performance info
%          - error from estimate
%    - how does this get seen by end user
%


%Steps
%1) Initialize each object
%
%    - maybe just predictor then predictor initializes its
%own properties
%
%
%2) Predictor, validate options (i.e. grouping may not make
%sense, maybe have this first or provide set methods only
%through the predictor)
%
%
%       Have the predictor upon initialization
%populate relevant props ...
%
%
%
%3)



%Predictor Code
%--------------------------------------------------------------
%1) Get applied stimuli if necessary
%
%   - method of superclass which calls request method
%
%2) Find matches based on stimuli (if desired)






%METHODS OF REQUEST HANDLER TO FLUSH OUT
%--------------------------------------------------------------
%1) Given a set of locations, flush out the applied stimuli
%       This is moved to a class that is meant to handle this
%2) Log results
%       - save to a temporary file ...
%       - the logged_data will handle merges if this fails ...




%IMPORTANT: The goal here is to instantiate basic options
%and then to allow the user to manipulate them by returning
%the object before calling getSolution()