function run()

clear classes


%Very basic setup figure
%----------------------------------------------
obj = NEURON.reproductions.Hokanson_2013;
% obj.example_figure_1();


obj.example_figure_2();

%More in depth setup figure
%----------------------------------------------
NEURON.reproductions.Hokanson_2013.figure0

%Versus fiber diameter
%----------------------------------------------------
NEURON.reproductions.Hokanson_2013.figure2


%Versus stimulus width
%---------------------------------------------------
NEURON.reproductions.Hokanson_2013.figure3


%Versus distance
%----------------------------------------------------
NEURON.reproductions.Hokanson_2013.figure1
