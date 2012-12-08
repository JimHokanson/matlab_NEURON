function NEURON_determineThreshold(model,hocFileName,stimVarName,varargin)

in.max_count          = 100;
in.last_value         = [];
in.lower_bound        = 0;
in.upper_bound        = 1000;
in.upper_bound_growth = 100;
in.run_arguments      = {};
in = processVarargin(in,varargin);

done = false;
reachedThreshold = false;

nextStim = 0.5*(in.upper_bound - in.lower_bound) + in.lower_bound;

count = 0;
while ~done
    count = count + 1;
    if count > in.max_count
        error('Iteration limit exceeded')
    end

    nextStimStr = sprintf('%0.2f',nextStim);

    [status,extras] = NEURON_runNeuron(model,hocFileName,'params',...
        {'vars_stimAmp' nextStimStr ...
        'vars_rho_ext' int2str(rho(i_rho)) ...
        'vars_e_rP'    int2str(r(i_r))});
    if ~status
        fprintf(2,'NEURON CODE FAILED\n');
        disp(extras.raw)
        error('Neuron code failed, see above')
    end
    %mesh(extras.data.vm)
    mx = max(extras.data.vm);

    %CRAPPY THRESHOLD DETECTION CODE
    %--------------------------------
    if length(find(mx > 10)) > 50
        %go lower
        upperBound = nextStim;
    else
        lowerBound = nextStim;
    end

    tempStim = 0.5*(upperBound-lowerBound)+lowerBound;
    if abs(tempStim - nextStim) < 0.01
        done = true;
        threshold = upperBound;
    else
        nextStim = tempStim;
    end



end