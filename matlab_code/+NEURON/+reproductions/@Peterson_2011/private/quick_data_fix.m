function quick_data_fix
%
%   NOTE: This code is probably a one time use situation but I am keeping
%   it just in case
%
%   Copied all pdf text into Excel, which ended up as a long vector
%
%Just a bit of code I wrote
%to go from one long vector to a more organized table ...

[num,txt,raw] = xlsread('temp_book.xlsx','Sheet1');


%New format:
%just weights
%Pulse durations and diamters can be external

%Diameter
%Line


diameter_lines = find(cellfun(@(x) strncmp(x,'Diameter',8),txt));

new_data = cell(length(diameter_lines)*11+1,12);
new_data(1) = raw(1);
current_line = 1;
for iDiam = 1:length(diameter_lines)
   cur_diameter_line =  diameter_lines(iDiam);
   other_lines = cur_diameter_line+1:cur_diameter_line+120;
   new_data(current_line+1) = raw(cur_diameter_line);
   new_data(current_line+2:current_line+11,:) = reshape(raw(other_lines),12,10)';
   current_line = current_line + 11;
end

xlswrite('temp_book.xlsx',new_data,'Sheet1Clean')