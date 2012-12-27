function [u,uI,varargout] = unique2(A)
%unique2 Returns groupings for each unique element
%
%   [u,uI,I_final] = unique2(A)
%
%   This function is a quicker way of getting the indices which 
%   match a particular unique value.
%
%   INPUTS
%   ============================================================
%   A : must be sortable via sort()
%
%   OUTPUTS
%   ============================================================
%   u  : unique values
%   uI : (cell array), each entry holds the indices of A which match u
%   I_final : there might be a better name for this ...
%             - indices are 1:1 with original input
%             - values represent index in final matrix
%             i.e. u(I_final) = A
%
%   EXAMPLE
%   ============================================================
%   [u,uI] = unique2([3 5 3 5 5])
%   u => [3 5]
%   uI{1} => [1 3];
%   uI{2} => [2 4 5];
%
%   NOTE: u(#) has the same value as all A(uI{#})



%   SPEED NOTE
%   ==========================================
%   r = randi(100,1,100000);
%
%     METHOD 1 - takes time T
%     [u,uI] = unique2(r);
% 
%     METHOD 2 - takes time 3T
%     [u2,~,J] = unique(r);
%     uI2 = cell(1,length(u2));
%     for iChan = 1:length(u2)
%         uI2{iChan} = strfind(J,u2(iChan));
%     end
% 
%     METHOD 3 - takes time 5T
%     [u3,~,J] = unique(r);
%     uI3 = cell(1,length(u3));
%     for iChan = 1:length(u3)
%         uI3{iChan} = find(J == u3(iChan));
%     end

%Add error checking
%1) input must be number
%2) NaN handling

if isempty(A)
   u = [];
   uI = {};
   return
elseif length(A) == 1
   u = A;
   uI = {1};
   return
end

%JAH TODO: Document code
[Y,I2] = sort(A(:));

if isnumeric(Y)
    %NOTE: Should add on -Inf and Inf test ...
    if isnan(Y(end)) %NaN will always be at end ...
        %What about Inf and -Inf ...
        error('NaN handling not yet supported')
    end
    Itemp = find(diff(Y) ~= 0);
else
    %could add case sensitivity
    Itemp = find(~strcmp(Y(1:end-1),Y(2:end)));  
end

Istart = [1; Itemp+1];
Iend   = [Itemp; length(A)]; 

u = Y(Istart);

%Handling row vectors, note that matrices will come out
%as column vectors, just like for unique()
rows = size(A,1);
cols = size(A,2);
if (rows == 1) && (cols > 1)
   u  = u'; 
   I2 = I2';
end

%Population of uI
%-----------------------------
uI = cell(1,length(u));
for iUnique = 1:length(u)
   uI{iUnique} = I2(Istart(iUnique):Iend(iUnique));
end

if nargout == 3
   
%    tic
%    temp = zeros(1,length(A));
%    temp(Istart) = 1;
%    temp = cumsum(temp);
%    final_indices2 = zeros(1,n_unique);
%    final_indices2(I2) = temp;
%    toc
   
%    tic
   %NOTE: This seems to be faster
   %Although it might depend on 
   n_unique      = length(u);
   final_indices = zeros(1,n_unique);
   for iU = 1:n_unique
      final_indices(uI{iU}) = iU; 
   end
   varargout{1} = final_indices;
%    toc
end


