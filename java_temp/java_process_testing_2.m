%

if false
    my_path  = getMyPath;
    jar_name = 'commons-exec-1.1.jar';
    javaaddpath(fullfile(my_path,jar_name));
end

%InputStream - io apache commons

c = org.apache.commons.exec.CommandLine('C:\nrn72\bin\nrniv.exe');
c.addArgument('-nogui');
c.addArgument('-isatty');

exec = org.apache.commons.exec.DefaultExecutor;
sh   = exec.getStreamHandler;