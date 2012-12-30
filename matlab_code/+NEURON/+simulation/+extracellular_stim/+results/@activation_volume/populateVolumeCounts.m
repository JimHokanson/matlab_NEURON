function populateVolumeCounts(obj,stim_levels,varargin)
%
%
%
%   IMPROVEMENTS
%   ================================================
%   1) Handle threshold detection better ...
%
%
%   CURRENT ASSUMPTIONS
%   =================================
%   1) Constant step size in X & Y
%
%
%   TODO
%   ================================================
%   1) Handle +/- threshold, currently this is ambiguous
%   2) Clean up function
%
%
%   ALGORITHM
%   =======================================================
%   Do linear interpolation using threshold values actually calculated
%   and a 1 um square size ...  Take into account redundancy in z direction
%   

if isempty(stim_levels)
    error('stim_levels can not be empty')
end


in.max_memory         = 500; %MB  %NOT CURRENTLY USED ...
in.interp_method      = 'cubic';  %NOT CURRENTLY USED ...
in = processVarargin(in,varargin);



%Algorithm, grab sets in x and y by all of z
%Do halfs to integrate ...

tm = obj.thresh_matrix;

%NOTE: These are the points we solved for, should be evenly spaced, see
%tests below
x_all = obj.x_solution;
y_all = obj.y_solution;
z_all = obj.z_solution;

nX = length(x_all);
nY = length(y_all);

if any(abs(diff(x_all) - (x_all(2) - x_all(1))) > 0.000001)
    error('Step size in x must currently be constant')
end

if any(abs(diff(y_all) - (y_all(2) - y_all(1))) > 0.000001)
    error('Step size in x must currently be constant')
end


%Consider making this a local method ...
xstim_obj_local = obj.xstim_obj;


%ARG, ...
node_spacing    = round(getNodeSpacing(xstim_obj_local.cell_obj)); %NOTE: I need it to be an integer

%================================================================================
%NOTE: It would be faster to not do this
%but we need to take into account the node spacing overlap
%perhaps we can speed this up later
%
%Here we duplicate data in Z if we were previously only solving for half
if z_all(1) == 0
    tm     = cat(3,flipdim(tm,3),tm(:,:,2:end));
    z_all = [-1*z_all(end:-1:2) z_all]; %don't duplicate 0
end


xi_final = (x_all(1)+0.5):1:(x_all(end)-0.5);
yi_final = (y_all(1)+0.5):1:(y_all(end)-0.5);
zi_final = (z_all(1)+0.5):1:(z_all(end)-0.5);


%=====================================================================================
%Setup for grabbing in node of Ranvier steps ...
%Indices for grabbing x & y shaped same as interpolation size



nStim          = length(stim_levels);
stim_counts_xy = zeros(x_all(end)-x_all(1),y_all(end)-y_all(1),nStim); %Populate over all x & y



%NOTE: Might also need to hold on
%by x - y space in case of trying to do neural probabilities ...

%nLoopsTotal = (nX-1)*(nY-1);

curLoopCount = 0;

for iX = 1:nX-1
    x_i = x_all(iX:iX+1);
    x_indices = find(xi_final > x_i(1) & xi_final < x_i(2));
    for iY = 1:nY-1
        curLoopCount = curLoopCount + 1;
        
        y_i       = y_all(iY:iY+1);
        y_indices = find(yi_final > y_i(1) & yi_final < y_i(2));
        
        
        %Now for the ugly inputs ...
        [Xg_o,Yg_o,Zg_o] = meshgrid(x_i,y_i,z_all);
        [Xg_i,Yg_i,Zg_i] = meshgrid(xi_final(x_indices),yi_final(y_indices),zi_final);
        
        temp_data  = interp3(Xg_o,Yg_o,Zg_o,tm(iX:iX+1,iY:iY+1,:),Xg_i,Yg_i,Zg_i,'*linear');
        
        %This is a mask we will use to test for activation at a given node
        %offset
        nX_i = length(x_indices);
        nY_i = length(y_indices);
        node_index_3    = ones(nX_i,nY_i,1);
        node_index_3(:) = 1:numel(node_index_3);
        offset_per_z = numel(node_index_3); %Amount to add on each increment
        nz = length(zi_final);

        temp_stim_count = zeros(nX_i,nY_i);
        
        for iStim = 1:nStim
            cur_stim = stim_levels(iStim);
            if cur_stim < 0
                mask = temp_data >= cur_stim & temp_data < 0;  %Might need to change this 
            else
                mask = temp_data <= cur_stim & temp_data > 0;  %Might need to change this 
            end
            
            %Examines counts given restrictions on replication in Z
            stim_count_this_loop = helper__getCountsPerStep(temp_stim_count,mask,offset_per_z,nz,node_spacing,node_index_3);
            
            if ~all(sign(stim_levels)) < 0
               error('Code below needs to be fixed if we do positive stim levels')
               %
            end
            if sum(stim_count_this_loop(:)) == 0
                break %Nothing higher, don't bother ...
            end
            
            stim_counts_xy(x_indices,y_indices,iStim) = stim_count_this_loop;
        end
        
        %fprintf('Finished %d/%d Y\n',iY,nY-1);
    end
    fprintf('Finished %d/%d X\n',iX,nX-1);
end

%Should I do object reflection here ...
%or save for later??? LATER

obj.stim_counts_xy         = stim_counts_xy;
obj.stim_levels_for_counts = stim_levels;
obj.stim_counts_populated  = true;
saveObject(obj)


%TODO:
%1) Clean up code
%2) save results to object ...

end

function temp_stim_count = helper__getCountsPerStep(temp_stim_count,mask,offset_per_z,nz,node_spacing,node_index_3)



%Pass some of the stuffs in here instead of creating out there ...




%Make all this below a helper
%Essentially we are making sure not to double count
%values that are separated by a node of Ranvier

%BOUNDARY TESTING NOTES:
%=======================================
%Below isn't right because saturation will happen
%but that is fine as long as we exceed the node length

%             %NOTE: Error test on saturation
%             all_z_activated = all(mask,3);
%             if any(all_z_activated)
%                 error('Stimulus level ...')
%             end

%NOTE: It might be advantages to keep this in 2d matrix (x-y)
%then see if the matrix saturates at any point




for iOffset = 1:node_spacing
    z_grab = iOffset:node_spacing:nz;
    offset_indices = (z_grab-1)*offset_per_z;
    grab_indices = bsxfun(@plus,node_index_3,permute(offset_indices,[1 3 2]));

    node_at_x_y     = any(mask(grab_indices),3);
    temp_stim_count = temp_stim_count + node_at_x_y;    
end




end


function fHandle = helper__linear_interpolate(Xg_i,Yg_i,Zg_i,Xg_o,Yg_o,Zg_o)
%TODO: Return a handle ...


%NOTE: This code was taken and modified from interp3

%hardcoding of interp3 linear ...
%=================================================================
[nrows,ncols,npages] = size(Xg_o);
mx = numel(Xg_o);
my = numel(Xg_o);
mz = numel(Xg_o);
s = 1 + (Xg_i-Xg_o(1))/(Xg_o(mx)-Xg_o(1))*(ncols-1);
t = 1 + (Yg_i-Yg_o(1))/(Yg_o(my)-Yg_o(1))*(nrows-1);
w = 1 + (Zg_i-Zg_o(1))/(Zg_o(mz)-Zg_o(1))*(npages-1);
nw = nrows*ncols;
ndx = floor(t)+floor(s-1)*nrows+floor(w-1)*nw;

% Compute intepolation parameters, check for boundary value.
if isempty(s), d = s; else d = find(s==ncols); end
s(:) = (s - floor(s));
if ~isempty(d), s(d) = s(d)+1; ndx(d) = ndx(d)-nrows; end

% Compute intepolation parameters, check for boundary value.
if isempty(t), d = t; else d = find(t==nrows); end
t(:) = (t - floor(t));
if ~isempty(d), t(d) = t(d)+1; ndx(d) = ndx(d)-1; end

% Compute intepolation parameters, check for boundary value.
if isempty(w), d = w; else d = find(w==npages); end
w(:) = (w - floor(w));
if ~isempty(d), w(d) = w(d)+1; ndx(d) = ndx(d)-nw; end
%==================================================================

fHandle =  @(arg4)((( arg4(ndx).*(1-t) + arg4(ndx+1).*t ).*(1-s) + ...
    ( arg4(ndx+nrows).*(1-t) + arg4(ndx+(nrows+1)).*t ).*s).*(1-w) + ...
    (( arg4(ndx+nw).*(1-t) + arg4(ndx+1+nw).*t ).*(1-s) + ...
    ( arg4(ndx+nrows+nw).*(1-t) + arg4(ndx+(nrows+1+nw)).*t ).*s).*w);

end
