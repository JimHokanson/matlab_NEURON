classdef system_tester < NEURON.sl.obj.handle_light
    %
    %   Class:
    %   NEURON.xstim.single_AP_sim.system_tester
    %
    %   Improvements:
    %   -------------------------------------------------------------------
    %   1) Allow repeated subsets
    
    %There are 3 data sources with this model:
    %1) All known data
    %2) Data that we will say is known, the training data
    %3) Data that we will say is unknown, the testing data
    %
    %   Both 2 and 3 are subsets of 1
    
    %Options ==============================================================
    properties
        old_data_method = 1
        %1 - use % random subset of previous data
        %2 - use # random subset
        %3 - use previous locations
        
        d1 = '-----    Method Options   -------'
        m1_pct        = 0.1
        m1_min_points = 20
        m2_n        = 100 %Use 100 pints
        m3_prev_xyz = []
        m3_known_locations
    end
    
    properties
        full_solution_object %This is for all objects
        unknown_locations
        new_indices_to_full_indices
        guess_instructions = NEURON.simulation.extracellular_stim.threshold_options;
    end
    
    methods
        function initialize(obj,logged_data,xstim)
            %
            %    INPUTS:
            %
            %
            
            obj.guess_instructions = xstim.threshold_options_obj;
            
            sol = logged_data.solution;
            
            obj.full_solution_object = sol;
            
            n_indices = length(sol.thresholds);
            
            switch obj.old_data_method
                case 1
                    indices = NEURON.sl.array.shuffle(1:n_indices);
                    n_new = floor(obj.m1_pct*n_indices);
                    if n_new < obj.m1_min_points
                        error('Min points error')
                    end
                    n_old = n_indices - n_new;
                    if n_old == 0
                        error('No testing data')
                    end
                    old_indices = indices(1:n_new);
                    new_indices = indices(n_new+1:end);
                case 2
                    %indices = NEURON.sl.array.shuffle(1:n_indices);
                    error('Not yet implemented')
                case 3
                    error('Not yet implemented')
                otherwise
                    error('Old data method not recognized: %d, valid values are 1,2,3',obj.old_data_method)
            end
            
            obj.unknown_locations = sol.cell_locations(new_indices,:);
            obj.new_indices_to_full_indices = new_indices;
            
            %Modify logged data to only know training data
            logged_data.changeKnownData(old_indices);
            
        end
        function threshold_simulation_results = getThresholdsFromSimulation(obj,s_obj,new_indices,predicted_thresholds)
            
            %Steps: for new_indices, look up solutions
            
            full_indices = obj.new_indices_to_full_indices(new_indices);
            
            actual_thresholds = obj.full_solution_object.thresholds(full_indices);
            
            r = NEURON.xstim.single_AP_sim.threshold_simulation_results(s_obj);
            r.indices              = new_indices;
            r.predicted_thresholds = predicted_thresholds;
            r.actual_thresholds    = actual_thresholds;
            [n_loops,ranges]       = getNGuesses(obj,actual_thresholds,predicted_thresholds);
            r.n_loops              = n_loops;
            r.ranges               = ranges;
            
            threshold_simulation_results = r;
        end
        function [n_guesses,ranges] = getNGuesses(obj,actual_thresholds,predicted_thresholds)
            
            %THIS IS A BIG HACK
            %This ignores some properties of the guess instructions
            %and might also ignore some of the ranges values
            %
            %but, I think it will work for now ...
            
            gi = obj.guess_instructions;
            
            max_error_abs = gi.max_threshold_error_absolute;
            
            %TODO: Eventually this should move to be a method
            %of the guess instructions class
            %or some class specifically designed for this
            %
            %The threshold testing class should use the class as well
            %instead of directly processing the instructions
            
            n_points  = length(actual_thresholds);
            
            n_guesses = zeros(1,n_points);
            ranges    = zeros(n_points,2);
            
            for iPoint = 1:n_points
                cur_actual     = actual_thresholds(iPoint);
                cur_prediction = predicted_thresholds(iPoint);
                
                cur_guess_count = 1;
                
                %Determine bounds
                %--------------------------------------------------
                if cur_prediction > cur_actual
                    upper_bound  = cur_prediction;
                    lower_points = gi.getLowerStimulusTestingPoints(cur_prediction);
                    I = find(cur_actual > lower_points,1);
                    lower_bound = lower_points(I);
                    if I ~= 1
                        upper_bound = lower_points(I-1);
                    end
                    cur_guess_count = cur_guess_count + I;
                else
                    lower_bound = cur_prediction;
                    upper_points = gi.getHigherStimulusTestingPoints(cur_prediction);
                    I = find(cur_actual < upper_points,1);
                    upper_bound = upper_points(I);
                    if I ~= 1
                        lower_bound = upper_points(I-1);
                    end
                    cur_guess_count = cur_guess_count + I;
                end
                
                %Binary guess
                %--------------------------------------------------
                t_diff = upper_bound - lower_bound;
                while t_diff > max_error_abs
                    
                    next_threshold = lower_bound + 0.5*t_diff;
                    if next_threshold > cur_actual
                        upper_bound = next_threshold;
                    else
                        lower_bound = next_threshold;
                    end
                    
                    cur_guess_count = cur_guess_count + 1;
                    t_diff = upper_bound - lower_bound;
                end
                
                n_guesses(iPoint) = cur_guess_count;
                ranges(iPoint,:)  = [lower_bound,upper_bound];
            end
            
        end
    end
    
end

