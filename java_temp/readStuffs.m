function [ success,result ] = readStuffs(r,wait_time,debug )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

r.init_read(wait_time,debug);
done = false;
while ~done
    done = r.read_result;
    if ~done
        pause(0.001)
    end
end

success = r.success_flag;
result  = char(r.result_str);

end

