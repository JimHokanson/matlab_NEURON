%
%cmd, arguments ....

%import com.mathworks.mlwidgets.io.InterruptibleStreamCopier;

%NOTE: copyStream only works when the process closes, it isn't asynchronous
%...

%http://undocumentedmatlab.com/blog/matlab-callbacks-for-java-events/


%ping_cmd = {'ping.exe', 'www2.google.com'};
ping_cmd =  {'C:\nrn72\bin\nrniv.exe' '-nogui -isatty'};

%java.lang.ProcessBuilder
pb      = java.lang.ProcessBuilder(ping_cmd);

%java.lang.ProcessImpl
p       = pb.start();

p_in  = p.getInputStream;
p_out = p.getOutputStream;

outputStream = java.io.ByteArrayOutputStream;
isc          = InterruptibleStreamCopier.getInterruptibleStreamCopier;
isc.copyStream(p_in,outputStream);
outputStream.close;

wtf = typecast(outputStream.toByteArray','uint8');

%http://www.mathworks.com/matlabcentral/newsreader/view_thread/39039