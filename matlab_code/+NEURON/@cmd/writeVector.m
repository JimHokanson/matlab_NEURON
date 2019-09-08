function writeVector(obj,file_path,v)
   %get pathing 
   %
   %    NEURON.cmd.writeVector(model,file_path,v)
   %
   %    Improvements
   %    ------------
   %    1) Build support for non-double data types 
   
    fid = fopen(file_path,'w+');
    if fid == -1
        %TODO: Improve error message 
        error('Failed to create the file for some reason ...')
    end

    len  = uint32(length(v));
    type = uint32(4);
    if ~isa(v,'double')
        v = double(v);
    end
    fwrite(fid,len,'uint32');
    fwrite(fid,type,'uint32');
    fwrite(fid,v,'double');
    fclose(fid);

end