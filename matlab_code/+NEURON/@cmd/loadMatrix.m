function data = loadMatrix(filePath)
%loadMatrix Reads a binary matrix file from Neuron
%
%   data = NEURON.cmd.loadMatrix(filePath)
%
%   WARNING: Only doubles currently supported ...
%
%   Assumes usage of vector's vwrite functionality in NEURON
%
%   This can also be used to read vectors as well.
%
%   FILE FORMAT:
%   ---------------------------------------------------------------
%   1) # of values in vector (uint32)
%   2) data type (NOT HANDLED) - 4 is a double (code does check for this)
%   http://www.neuron.yale.edu/neuron/static/docs/help/neuron/general/classes/vector/vect.html#vwrite
%   3) data
%   1 - 3 are then repeated for each vector (THIS IS NOT CHECKED)
%
%   See Also:
%   NEURON_model.writeVector

if ~exist(filePath,'file')
    error('Specified file does not exist')
end

fid  = fopen(filePath,'r','ieee-le');

fseek(fid,0,1);
n_bytes = ftell(fid);
fseek(fid,0,-1);

n_values = fread(fid,1,'uint32');
type    = fread(fid,1,'uint32');

if type ~= 4
    error('Unexpected data type, code only currently supports doubles')
end

bytes_per_double = 8;
n_cols = n_bytes/bytes_per_double/(n_values + 1); %NOTE the + 1 is because the specification takes up 8 bytes

if floor(n_cols) ~= n_cols
    error('File does not have enough data for an even # of columns given the # of bytes in the first')
end

%Actual reading of the data
data = fread(fid,[n_values inf],[int2str(n_values) '*double'],8);

fclose(fid);