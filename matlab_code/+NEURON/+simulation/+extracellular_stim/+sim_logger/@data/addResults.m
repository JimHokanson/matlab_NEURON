function addResults(obj,applied_stimuli,thresholds,xyz_centers)
%
%   addResults(obj,applied_stimuli,thresholds)
%
%   INPUTS
%   =======================================================================
%   applied_stimuli : observations x [space x time]
%   thresholds      : stimulus thresholds in uA (sort of)
%
%   FULL PATH:
%   

%???? - Should I always just append or waist time
%saving and loading empty entries?????
%Not sure ...
%Growth currently implemented ...

%Growth, if necessary
%--------------------------------------------------------------
n_entries = length(thresholds);
if n_entries + obj.current_index > obj.n_entries_allocated
    obj.n_entries_allocated = obj.n_entries_allocated + obj.GROW_SIZE;
    %TODO: Finish this part ...
    
    obj.applied_stimulus_matrix = [obj.applied_stimulus_matrix; zeros(obj.GROW_SIZE,size(applied_stimuli,2))];
    obj.threshold_values        = [obj.threshold_values         zeros(1,obj.GROW_SIZE)];
    obj.xyz_center              = [obj.xyz_center;              zeros(obj.GROW_SIZE,3)];
    obj.creation_time           = [obj.creation_time            zeros(1,obj.GROW_SIZE)];
    obj.stimulus_setup_id       = [obj.stimulus_setup_id        zeros(1,obj.GROW_SIZE)];
    
end

%Updating results
%--------------------------------------------------------------
new_indices = obj.current_index+1:obj.current_index+n_entries;


obj.applied_stimulus_matrix(new_indices,:) = applied_stimuli;
obj.creation_time(new_indices)             = now;
obj.stimulus_setup_id(new_indices)         = obj.current_stimulus_setup_id;
obj.threshold_values(new_indices)          = thresholds;
obj.xyz_center(new_indices,:)              = xyz_centers;

%Saving to disk
%--------------------------------------------------------------
%asdfkjasdkfjaksdfjslkdfj
n_points_per_cell       = obj.n_points_per_cell; %#ok<*NASGU>

current_index           = obj.current_index;
n_entries_allocated     = obj.n_entries_allocated;

applied_stimulus_matrix = obj.applied_stimulus_matrix;
threshold_values        = obj.threshold_values;
xyz_center              = obj.xyz_center;

creation_time           = obj.creation_time;

stimulus_setup_id       = obj.stimulus_setup_id;
stimulus_setup_objs     = obj.stimulus_setup_objs;

save(obj.data_path,...
    'n_points_per_cell',...
    'current_index',...
    'n_entries_allocated',...
    'applied_stimulus_matrix',...
    'threshold_values',...
    'xyz_center',...
    'creation_time',...
    'stimulus_setup_id',...
    'stimulus_setup_objs')


end