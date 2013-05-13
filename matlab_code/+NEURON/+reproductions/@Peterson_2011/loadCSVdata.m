function loadCSVdata(obj)
%
%
%   p = NEURON.reproductions.Peterson_2011;
%   p.loadCSVdata
%  
%
%
%
%   CSV data was created from supplemental data from JNE websites
%
%   FILES:
%   ============================================
%   
%   private/mdf1_thresholds.csv
%   private/mdf2_thresholds.csv
%   FORMAT:
%   skip first 3 lines
%   then:
%   columns are: diameter, pulse duration, ve, mdf output
%
%   private/mdf2_data.csv

mdf1_path = fullfile(getMyPath,'private','mdf1_thresholds.csv');
mdf2_path = fullfile(getMyPath,'private','mdf2_thresholds.csv');

data_1 = readDelimitedFile(mdf1_path,',','header_lines',3);
data_2 = readDelimitedFile(mdf2_path,',','header_lines',3);

obj.mdf1 = helper__processData(data_1);
obj.mdf2 = helper__processData(data_2);


%Could speed this up later

end

function output = helper__processData(data_in)

    %Delim,pulsewidth,Ve,MDF_output
    data_in = str2double(data_in);
    d = data_in(:,1);
    p = data_in(:,2);
    v = data_in(:,3);
    m = data_in(:,4);

    [ud,~,id] = unique(d);
    [up,~,ip] = unique(p);

    %TODO: Should check unique rows of data ...
    
    output.ve  = accumarray([id ip],v,[length(ud) length(up)],@(x) {x},{}); 
    output.mdf = accumarray([id ip],m,[length(ud) length(up)],@(x) {x},{}); 
    output.diameters    = ud;
    output.pulse_widths = up;
    
end