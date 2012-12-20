function [thresh_value,n_loops] = sim__determine_threshold(obj,starting_value)
%sim__determine_threshold
%
%   [thresh_value,nLoops] = sim__determine_threshold(obj,starting_value)
%
%   This method works closely with the following class:
%       NEURON.threshold_cmd
%   This class is available as the property:
%       .threshold_cmd_obj
%
%   Specifically the following things may be manipulated:
%   =======================================================
%   max_threshold       - max stimulus amplitude to use
%   use_max_threshold   - allows solving based only on what won't throw
%                         numerical errors
%   threshold_accuracy  - accuracy to solve threshold to ...
%   guess_amount        - amount to guess when first testing threshold
%   allow_opposite_sign - whether or not to allow a double sided solution
%                         (either sign)
%   
%
%
%   SPECIAL CASES - see helper__handleError
%   =======================================================
%   10000
%
%   NEURON FUNCTIONS CALLED
%   =======================================================
%   xstim__determine_threshold
%
%   FULL PATH: NEURON.simulation.extracellular_stim.sim_determine_threshold

    %Important call to make sure everything is synced
    initSystem(obj.ev_man_obj)

    [thresh_value,n_loops] = obj.threshold_analysis_obj.determine_threshold(starting_value);
end


% % % %     
% % % % 
% % % %     THRESH_STEPS_MAX = 3;
% % % % 
% % % %     ZERO_STIM = 0.01;
% % % % 
% % % %     %NOTE: Initialization of the system is where we 
% % % %     %apply the stimulus current ..., need to handle too close 
% % % %     obj.ev_man_obj.initSystem();
% % % % 
% % % %     %NOTE: Should check v_all & t_vec
% % % %     v_all = obj.v_all;
% % % %     if any(isinf(v_all(:)))
% % % %         thresh_value = NaN;
% % % %         nLoops = 0;
% % % %         return
% % % %     elseif all(abs(v_all(:)) < ZERO_STIM)
% % % %         thresh_value = NaN;
% % % %         nLoops = 0;
% % % %         return
% % % %     end
% % % %     
% % % %     %NOTE: When applying potential, need to take into account near zero cases ...
% % % % 
% % % %     %SLOPPY, need to change
% % % %     %10000 - overflow
% % % %     %20000 - underflow
% % % %     
% % % %     t_obj = obj.threshold_cmd_obj;
% % % %     
% % % %     [thresh_value,nLoops] = helper__runOneSidedThreshold(obj,starting_value);
% % % %     %keyboard
% % % %     
% % % %     
% % % %     
% % % %     %UGLY TEMPORARY HACK FOR SFN ...
% % % %     %====================================================================
% % % %     %CODE NOT YET IMPLEMENTED ...
% % % % % % % %     %TODO: Eventually remove this code
% % % %        %NOTE: need to make this interactive ...
% % % %        %i.e.
% % % %        %1) Ask user to solve
% % % %        %2) start at some level and go up ...
% % % %        %Guess too
% % % %     if thresh_value == 50000
% % % %        
% % % %        for iStep = 1:THRESH_STEPS_MAX
% % % %            
% % % %             stim_higher = sign(starting_value)*(abs(starting_value) + iStep*0.5*t_obj.threshold_accuracy);
% % % %             apFired     = sim__single_stim(obj,stim_higher,'complicated_analysis',true);           
% % % %            
% % % %             if apFired
% % % %                 break
% % % %             end
% % % %            
% % % %        end
% % % %        if apFired
% % % %           thresh_value = stim_higher;
% % % %           nLoops = nLoops + iStep;
% % % %           return
% % % %        else
% % % %            error('Error code 50000, tried to fix using fixed steps, but this failed too')
% % % %        end
% % % %     end
% % % %     %====================================================================
% % % %     
% % % %     
% % % %     if thresh_value >= 10000
% % % %         if thresh_value == 10000
% % % %            if t_obj.allow_opposite_sign
% % % %                [thresh_value,nLoops] = helper__runOneSidedThreshold(obj,-1*starting_value);
% % % %                 if thresh_value >= 10000
% % % %                     thresh_value = helper__handleError(thresh_value,t_obj,false); 
% % % %                 end
% % % %            else
% % % %                 thresh_value = helper__handleError(thresh_value,t_obj,true); 
% % % %            end
% % % %         else
% % % %            thresh_value = helper__handleError(thresh_value,t_obj,false); 
% % % %         end
% % % %     end
% % % %     
% % % % 
% % % % end
% % % % 
% % % % function [thresh_value,nLoops] = helper__runOneSidedThreshold(obj,starting_value)
% % % % %helper__runOneSidedThreshold
% % % % %
% % % % %   [thresh_value,nLoops] = helper__runOneSidedThreshold(obj,starting_value)
% % % % %
% % % % %   TODO: Document function 
% % % % 
% % % %     c = obj.cmd_obj;           %(Class NEURON.cmd)
% % % %     t = obj.threshold_cmd_obj; %(Class NEURON.threshold_cmd)
% % % %     
% % % %     
% % % %     %Adjust threshold if value requested is too large to begin with ...
% % % %     %---------------------------------------------------------------------------------------
% % % %     max_threshold_use = getMaxThresholdForSim(t);
% % % %     if abs(starting_value) > max_threshold_use
% % % %        new_starting_value = 0.5*max_threshold_use*sign(starting_value);
% % % %        formattedWarning('Stimulus amplitude specified: %g, is greater than max allowed: %g, starting at %g instead',...
% % % %            starting_value,max_threshold_use,new_starting_value)
% % % %        starting_value = new_starting_value;
% % % %     end
% % % %     
% % % %     %Run code and get result ...
% % % %     %----------------------------------------------------------------------------------------
% % % %     str = sprintf('threshold = xstim__determine_threshold(%0g,%0g,%0g,%0g)\n io__print_variable("threshold",threshold)',...
% % % %     starting_value,t.guess_amount,max_threshold_use,t.threshold_accuracy);
% % % %     [~,result_str] = c.run_command(str);
% % % %     
% % % %     %For debugging: 
% % % %     %[apFired,extras] = sim__single_stim(obj,-23,true);
% % % %     %mesh(extras.vm)
% % % %     
% % % %     %Why does this crash occassionally??? - rather, nothing is printed ...
% % % %     try
% % % %         thresh_value   = str2double(c.extractSingleParam(result_str,'threshold'));
% % % %     catch ME
% % % %         str2 = 'io__print_variable("threshold",threshold)';
% % % %         [~,result_str2] = c.run_command(str2);
% % % %         thresh_value   = str2double(c.extractSingleParam(result_str2,'threshold'));
% % % %         formattedWarning('Failed to retrieve threshold, not sure why, worked the 2nd time')
% % % %     end
% % % %     
% % % %     if thresh_value >= 10000 && thresh_value ~= 30000
% % % %         nLoops = 0;
% % % %     else
% % % %         %nLoops only valid 
% % % %         nLoops = str2double(c.extractSingleParam(result_str,'loop_count'));
% % % %     end
% % % %     
% % % % end
% % % % 
% % % % 
% % % % function thresh_value = helper__handleError(error_code,t_obj,is_single) 
% % % % 
% % % % thresh_value = error_code;
% % % % 
% % % % %Look away, some very last minute coding
% % % % 
% % % % if error_code >= 40000 && error_code <= 80000
% % % %     error('Error_code: %d, see code in xstim__determine_threshold.hoc',error_code); 
% % % % else
% % % % 
% % % %     switch error_code 
% % % %         case 10000
% % % %             if t_obj.throw_error_on_no_solution
% % % %                 if is_single
% % % %                     error('Unable to find single sided threshold')
% % % %                 else
% % % %                     error('Unable to find threshold within both limits')
% % % %                 end
% % % %             else
% % % %                 thresh_value = NaN;
% % % %             end
% % % %         case 20000
% % % %             error('Underflow, everything yielded an AP')
% % % %         case 30000
% % % %             error('Loop error value, too many runs')
% % % %         otherwise
% % % %             error('Unrecognized error value')
% % % %     end
% % % % end
% % % % end