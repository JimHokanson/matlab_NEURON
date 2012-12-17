%
%cmd, arguments ....

%import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

%NOTE: copyStream only works when the process closes, it isn't asynchronous
%...

%http://undocumentedmatlab.com/blog/matlab-callbacks-for-java-events/

if false
    my_path  = getMyPath;
    jar_name = 'NEURON_reader.class';
    javaaddpath(my_path);
end


%ping_cmd = {'ping.exe', 'www2.google.com'};
ping_cmd =  {'C:\nrn72\bin\nrniv.exe' '-nogui' '-nobanner'  '-isatty'};

%java.lang.ProcessBuilder
pb      = java.lang.ProcessBuilder(ping_cmd);

%java.lang.ProcessImpl
p       = pb.start();

%p.exitValue %will error if process has not exited ...

perr = p.getErrorStream;
pin  = p.getInputStream;
pout = p.getOutputStream;

r = NEURON_reader(pin,perr,p);

[ success,result ] = readStuffs(r,-1,true);

%read_result(r,-1,true);

%NOTE: There needs to be time for the process to initiate ...
%How do we know how long to wait before it has initiated ???

%r.process_running

%TODO:
%1) - implement full loop - i.e. looping until done
%2) - DONE document code a bit - 
%3) - DONE remove terminal string from string
%4) - DONE implement stack dump check
%5) - DONE integrate code into Matlab object
%6) - test
%7) Startup delay handling ... - add read at start ...


writeLine(pout,'a=1');

writeLine(pout,'a');

%NOTE: Here we dont want to use a write line ...
%For some reason there is an extra newline ... 
writeLine(pout,'{fprint("\n<oc>\n")}');
[ success,result ] = readStuffs(r,-1,true);


disp(r.result_str);
%good_read
%


%neuron_process.run_stuff(pin,perr)

% outputStream = java.io.ByteArrayOutputStream;
% isc          = InterruptibleStreamCopier.getInterruptibleStreamCopier;
% isc.copyStream(p_in,outputStream);
% outputStream.close;
% 
% wtf = typecast(outputStream.toByteArray','uint8');

%http://www.mathworks.com/matlabcentral/newsreader/view_thread/39039