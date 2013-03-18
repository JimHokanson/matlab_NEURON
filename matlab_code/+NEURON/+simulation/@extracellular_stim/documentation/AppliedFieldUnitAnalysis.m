%{

This file is meant to ensure that the units used in NEURON are appropriate
given stimulus current amplitudes in microamps.

%
%extracelluar_stim_getPotential
%
%   v_ext = extracelluar_stim_getPotential(r,I,resistivity)
%
%

UNITS
---------------------------------------------------------------
          I : microamps
          r : microns
resistivity : ohms-centimeter


%NOTE: rho = R*A/length
%
%EQUATION
%====================================
%V = resistivity * I
%    ------------------
%     (4 * pi * r)
%
%TO VOLTS
%------------------
% 1e-2 * 1e-6
% ------------
%    1e-6
%
%V = I*R
%
%
%See page 28 of Bioelectricity, A Quantitative Approach
%Plonsey & Barr, 2nd edition
%v_ext = 1e-2*I.*resistivity./(4*pi.*r);


%}