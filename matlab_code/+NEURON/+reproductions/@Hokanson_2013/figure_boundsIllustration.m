function figure_boundsIllustration()
%The goal of this function is to show some issues with bounds ...
%
%   NEURON.reproductions.Hokanson_2013.figure_boundsIllustration
%   
%
%1) Within range bounds
%2) z-limit bounds
%3) x-limit bounds


obj = NEURON.reproductions.Hokanson_2013;

C.merge_solvers  = false;
C.use_new_solver = true; 

%z - limit bounds
%--------------------------------------------------------------------------
X_VECTOR = -200:10:200;
Z_VECTOR = -2000:10:2000;
Y_VECTOR = 0;

X_AXON   = 500;


XYZ   = {X_VECTOR Y_VECTOR Z_VECTOR};

xstim = obj.instantiateXstim([0 0 0]);

INL   = xstim.cell_obj.getAverageNodeSpacing;

r = xstim.sim__getThresholdsMulipleLocations(XYZ,...
    'merge_solvers',C.merge_solvers,'use_new_solver',C.use_new_solver);

keyboard


%Plotting results
%-------------------------------------------------
imagesc(X_VECTOR,Z_VECTOR,squeeze(r)');
colorbar;
axis equal
hold on
scatter(0,0,100,'w','filled')

%Axon plotting
line([X_AXON X_AXON],[Z_VECTOR(1) Z_VECTOR(end)],'Color','k','Linewidth',3)
scatter(X_AXON*ones(1,3),[-INL 0 INL],100,'r','filled')
hold off

temp = sl.plot.postp.imageToPatch(gcf,'ignore_colorbars',false);

%--------------------------------------------------------------------------
%-------                    X limit bounds               ----------------
%--------------------------------------------------------------------------
%
%   transverse or long pairings ?????
%
%   Use dual stim or single stim ?????








