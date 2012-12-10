function writeVector(obj,filePath,v)
   %get pathing 
   %
   %    NEURON_model.writeVector(model,fileName,v)

    fid      = fopen(filePath,'w+');
    if fid == -1
        error('Failed to create the file for some reason ...')
    end

    len  = uint32(length(v));
    type = uint32(4);
    if ~strcmp(class(v),'double')
        v = double(v);
    end
    fwrite(fid,len,'uint32');
    fwrite(fid,type,'uint32');
    fwrite(fid,v,'double');
    fclose(fid);

end