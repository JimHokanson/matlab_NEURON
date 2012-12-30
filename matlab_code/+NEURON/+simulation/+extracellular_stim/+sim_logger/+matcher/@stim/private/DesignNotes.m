%{

STIM MATCHER DESIGN NOTES

DESIGN NOTES:
---------------------------------------------------------------------------
1) Regarding positive or negative thresholding, we always treat the input
as positive, transforming the input data to match that expectation. In
other words if we are trying to match an input stimulus of 0 1 2 1 0 with
a negative stimulation factor, we would instead be looking for a positive
stimulation factor with an applied input stimulus of 0 -1 -2 -1 0. 






%}