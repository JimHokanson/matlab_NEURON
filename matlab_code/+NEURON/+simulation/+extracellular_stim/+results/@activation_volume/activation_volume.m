classdef activation_volume < handle
    %
    %   Class: NEURON.results.xstim.activation_volume
    %
    %   TODO: Summarize purpose of this class
    
    %REFERENCE OBJECTS ====================================================
    properties (Hidden)
       xstim_obj 
    end
    
    %OPTIONS  =============================================================
    properties
        start_width   = 100
        step_size     = 20
        spacing_model = 1 %Currently only one value is valid
        %Use this to ensure a proper range of values
        %1 - indicates axon type model
        %
        %   TODO: Increase documentation on this model ...
    end
    
    properties
       bounds = [] % [min x xyz; max x xyz]
    end
    
    methods
        function obj = activation_volume(xstim_obj)

            obj.xstim_obj = xstim_obj;
            
            %Population of bounds 
            %--------------------------------------------------------------
            elec_objs = xstim_obj.elec_objs;
            
            all_elec_locations = vertcat(elec_objs.xyz);
            
            obj.bounds = [min(all_elec_locations,[],1); ...
                            max(all_elec_locations,[],1)];

            
            if obj.spacing_model == 1
                obj.bounds(1,1:2)  = round2(obj.bounds(1,1:2) - obj.start_width,obj.step_size,@floor);
                obj.bounds(2,1:2)  = round2(obj.bounds(2,1:2) + obj.start_width,obj.step_size,@ceil);
                
                %Updating z to completely encompass the axon ...
                z_distance_spanned = obj.bounds(2,3) - obj.bounds(1,3);
                extra_spacing      = (obj.getInternodeLength - z_distance_spanned)/2;
                obj.bounds(1,3)    = round2(obj.bounds(1,3) - extra_spacing,obj.step_size,@floor);
                obj.bounds(2,3)    = round2(obj.bounds(2,3) + extra_spacing,obj.step_size,@ceil);
                
            else
                error('Only spacing model #1 is implemented')
            end

        end   
        function internode_length = getInternodeLength(obj)
           %getInternodeLength    
           %    
           %    internode_length = getInternodeLength(obj)
           %
           
           if obj.spacing_model == 1
               
              %Known implementations:
              %--------------------------------------------------------
              %NEURON.cell.axon.MRG.getAverageNodeSpacing 
              internode_length = obj.xstim_obj.cell_obj.getAverageNodeSpacing;
           else
              error('Internode length should only be requested for spacing model 1') 
           end
        end
        function varargout = getXYZlattice(obj,as_cell)
           %getXYZlattice
           %
           %    CALLING FORMS
           %    ===========================================================
           %    [x,y,z]   = getXYZlattice(obj,false)
           %    
           %    [{x,y,z}] = getXYZlattice(obj,true)
           %    
           
           if ~exist('as_cell','var')
               as_cell = false;
           end
            
           x = obj.bounds(1,1):obj.step_size:obj.bounds(2,1);
           y = obj.bounds(1,2):obj.step_size:obj.bounds(2,2);
           z = obj.bounds(1,3):obj.step_size:obj.bounds(2,3);
           
           if as_cell
              varargout{1} = {x y z}; 
           else
              varargout{1} = x;
              varargout{2} = y;
              varargout{3} = z;
           end
           
        end
    end

    
    
end

