function writeLine(pout,str_to_write)

    str = java.lang.String([str_to_write char(10)]);
    pout.write(str.getBytes,0,length(str));
    pout.flush;
    
    %NOTE: Need to add on method for 
    
end

