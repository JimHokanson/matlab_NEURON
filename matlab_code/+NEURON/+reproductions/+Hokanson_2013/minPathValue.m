function [value, valuesOnPath, path] = minPathValue(nodeValues, ...
    startSubs, endSubs, cost_fh, verbose)
    %
    %   MINPATHVALUE
    %
    %   INPUTS
    %   ===================================================================
    %   nodeValues : 3d array
    %   startSubs  : 3d indices [x y z]
    %   endSubs    : 
    %   cost_fh : optional
    %   verbose
    %
    %   ...
    %
    %   REQUIREMENTS
    %   - FEX/"Advanced Dijkstra's Minimum Path Algorithm" by Joseph Kirk.
    %
    %   NOTES
    %   - Start and End nodes values are taken into account, but could be
    %     discarded, e.g. by user with max(valuesOnPath(2:end-1)).
        
    if nargin < 4 || isempty(cost_fh),  cost_fh = @(x) 10.^(x.^2) ;  end
    
    if nargin < 5,  verbose = false ;  end
    
    % - Determine FID, SID.
    if ~iscell(startSubs),  startSubs = num2cell(startSubs) ;  end
    
    SID = sub2ind(size(nodeValues), startSubs{:}) ;
    
    if ~iscell(endSubs),  endSubs = num2cell(endSubs) ;  end
    
    FID = sub2ind(size(nodeValues), endSubs{:}) ;
    
    if verbose,  fprintf('SID: %d, SID: %d\n', SID, FID) ;  end
    % - Build array of linear indices.
    
    linId = reshape(1:numel(nodeValues), size(nodeValues)) ;
    
    if verbose,  fprintf('linId:\n') ;  disp(linId) ;  end
    % - Build vertices.
    
    sz = size(linId) ;  nD = length(sz) ;  vertices = [] ;
    for d = 1 : nD
        subsN1 = arrayfun(@(k)1:sz(k)-(k==d), 1:nD, 'UniformOutput', false) ;
        subsN2 = arrayfun(@(k)(k==d)+1:sz(k), 1:nD, 'UniformOutput', false) ;
        vertices = [vertices; reshape(linId(subsN1{:}), [], 1), ...
                    reshape(linId(subsN2{:}), [], 1)] ;
    end
    
    vertices = [vertices; fliplr(vertices)] ;       % + Reverse directions.
    
    % - Build cost/distances.
    buffer  = max(nodeValues(vertices(:,1)), nodeValues(vertices(:,2))) ;
    weights = cost_fh(buffer) ;
    
    % - Build Dijkstra inputs and call.
    nNodes = numel(nodeValues);
    
    C = sparse(vertices(:,1), vertices(:,2), weights, nNodes, nNodes) ;
    
    A = C ~= 0 ;
    
    [~, path] = NEURON.reproductions.Hokanson_2013.dijkstra(A, C, SID, FID) ;
    
    if verbose,  fprintf('path (lin.):\n') ;  disp(path) ;  end
    % - Build outputs (convert lin. path to array of subs).
    valuesOnPath = nodeValues(path) ;
    value        = max(valuesOnPath) ;
    buffer       = cell(nD, 1) ;
    [buffer{:}]  = ind2sub(size(nodeValues), path) ;
    path         = cell2mat(buffer).' ;
end
 

% % I tested it on your first 2D example, my 2D example, and the following 3D example, which all seem to be fine. I guess that what should be really over thought is this cost function that I threw without too much analytical justification. But here is the 3D example:
% % 
% %  nodeValues = 4 * ones(3, 5, 3) ;
% %  nodeValues(1,:,1) = 3 ;
% %  nodeValues(2,:,2) = 1 ;
% %  nodeValues(2,3,2) = 4 ;
% %  nodeValues(2,1,1) = 2 ;
% %  nodeValues(2,5,1) = 2
% %  startSubs = [2, 2, 2] ;
% %  endSubs   = [2, 4, 2]
% %  [value, valuesOnPath, path] = minPathValue(nodeValues, ...,
% %      startSubs, endSubs, [], true)