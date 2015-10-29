function figure_boundsIllustration()
%The goal of this function is to show some issues with bounds ...
%
%   NEURON.reproductions.Hokanson_2013.figure_boundsIllustration
%   
%   This currently only shows the solutions in z-repeating
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

xstim = obj.instantiateXstim([0 0 -800; 0 0 800]);

r2 = xstim.sim__getThresholdsMulipleLocations(XYZ,...
    'merge_solvers',C.merge_solvers,'use_new_solver',C.use_new_solver);


xstim = obj.instantiateXstim([0 0 -225; 0 0 225]);

r3 = xstim.sim__getThresholdsMulipleLocations(XYZ,...
    'merge_solvers',C.merge_solvers,'use_new_solver',C.use_new_solver);

%Minimum encompassed
%min(r(1,1,:))

keyboard


%Plotting results
%-------------------------------------------------

r_both = {r r2 r3};
figure(1)
for iPair = 1:3

    subplot(1,3,iPair)
    cla
    cur_r = r_both{iPair};
imagesc(X_VECTOR,Z_VECTOR,squeeze(cur_r)');
colorbar;
axis equal
hold on
if iPair == 1
    scatter(0,0,100,'w','filled')
elseif iPair == 2
    scatter([0 0],[-800 800],100,'w','filled')
else
    scatter([0 0],[-225 225],100,'w','filled')
end

%Axon plotting
line([X_AXON X_AXON],[Z_VECTOR(1) Z_VECTOR(end)],'Color','k','Linewidth',3)
scatter(X_AXON*ones(1,3),[-INL 0 INL],100,'r','filled')
hold off
axis equal
set(gca,'clim',[0 25])
end

%temp = NEURON.sl.plot.postp.imageToPatch(gcf,'ignore_colorbars',false);

%Value of interest
%min(r(1,1,:))




%--------------------------------------------------------------------------
%-------                    X limit bounds               ----------------
%--------------------------------------------------------------------------
%
%   transverse or long pairings ?????
%
%   Use dual stim or single stim ?????








