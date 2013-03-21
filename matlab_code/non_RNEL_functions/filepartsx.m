function path_out = filepartsx(filepath,N)
%filepartsx  Applies fileparts numerous times
%
%   path_out = filepartsx(filepath,N)
%
%   Small function to help clean up stripping of the path.

path_out = filepath;
for iN = 1:N
   path_out = fileparts(path_out); 
end


end