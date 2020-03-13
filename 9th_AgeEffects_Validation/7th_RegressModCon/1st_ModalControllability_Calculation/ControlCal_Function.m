function [avg_cont, mod_cont, bound_cont] = ControlCal_Function(ConnPath, ResultantFile)

%
% ConnPath:
%    The path of the .mat file which contains a matrix named 'connectivity'
%

tmp = load(ConnPath);
A = tmp.connectivity;
% Here we did not scale the matrix as did in main analysis
% Because in the codes of mod_control.m, the first command is scaling by maximum eigenvalue
mod_cont = modal_control(A);

save(ResultantFile, 'mod_cont');
