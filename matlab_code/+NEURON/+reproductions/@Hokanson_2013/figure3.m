 function figure3()
            %
            %   NEURON.reproductions.Hokanson_2013.figure3
            %   
            
             obj = NEURON.reproductions.Hokanson_2013;

            
             for iPair = [1 2 5]
                for iDiameter = [2 3 4]
                    for stim_width = [0.050 0.100 0.2 0.40]
                        current_diameter = obj.ALL_DIAMETERS(iDiameter);
                        fprintf('Running Pairing: %d\n',iPair);
                        fprintf('Current Diameter: %d\n',iDiameter);
                        fprintf('Running Width: %g\n',stim_width);
                        options = {...
                            'stim_durations',[stim_width 2*stim_width],...
                            'electrode_locations',obj.ALL_ELECTRODE_PAIRINGS{iPair},...
                            'tissue_resistivity',obj.TISSUE_RESISTIVITY};
                        xstim_obj = NEURON.simulation.extracellular_stim.create_standard_sim(options{:});
                        cell_obj  = xstim_obj.cell_obj;
                        cell_obj.props_obj.changeFiberDiameter(current_diameter);
                        
                        act_obj   = xstim_obj.sim__getActivationVolume();
                
                        temp = act_obj.getVolumeCounts(1:0.5:30);
                        
                        
                        %xstim_obj.sim__getThresholdsMulipleLocations({-500:20:500 -500:20:500 -500:20:500});
                    end
                end
            end
            
        end