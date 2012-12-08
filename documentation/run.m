%NEURON run

finitialize(value)
fcurrent


run() 
    stdinit() 
        init() 
            finitialize()
    continuerun() or steprun() 
    step() 
        advance() 
            fadvance() %integrates system in time
            
            
%advance () - hook for doing things before or after timestep
%proc advance() { fadvance()}

%Might need to step more often then plotting ...
% % % proc step() {local i 
% % %     if (using_cvode_) { 
% % %     advance()
% % %     } else for i=1,nstep_steprun { 
% % %     advance()
% % %     } 
% % % Plot()
% % % } 



% % % %proc steprun() {
% % % step()
% % % flushPlot()
% % % }

%proc run(){
%     stdinit()
%     continuerun(tstop)
%}