
function [X_Opt_Trajectory, X_Opt_Final, U_Opt_Trajectory, Energy, n_err] = EnergyCal_Function(ConnPath, T, xc, x0, xf, S, rho, ResultantFile)

load(ConnPath);
A = connectivity ./ svds(connectivity, 1);
A = A - eye(size(A));

[X_Opt_Trajectory, X_Opt_Final, U_Opt_Trajectory, Energy, n_err] = optim_fun(A, T, xc, x0, xf, S, rho);
save(ResultantFile, 'X_Opt_Trajectory', 'X_Opt_Final', 'U_Opt_Trajectory', 'Energy', 'n_err', 'xc', 'xf');
