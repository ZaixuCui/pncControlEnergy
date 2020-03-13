
clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

EnergyFolder = [Data_Folder '/energyData'];
mkdir(EnergyFolder);

Lausanne125_Matrix_Cell = g_ls([Matrix_Folder '/*.mat']);

T = 1;
rho = 1;
% Control nodes selection
n = 232;
xc = eye(n);

% initial state: all 0
x0 = zeros(n, 1);

% Target state: average activation data 
Activation_Mat = load([Data_Folder '/Activation_675_Avg.mat']);
xf = Activation_Mat.Activation_675_Avg;

% Nodes to be constrained
S = eye(n);

ResultantFolder = [EnergyFolder '/InitialAll0_TargetActivationMean'];
EnergyCal_SGE_Function(Lausanne125_Matrix_Cell, T, xc, x0, xf, S, rho, ResultantFolder);

% Calculating yeo average value; Yeo 7 system + subcortical system
Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system.mat']);
Atlas_Yeo_Index = Atlas_Yeo_Index.Yeo_7system([1:191 193:233]); % Remove the 192th region
for i = 1:8
  System_Indices{i} = find(Atlas_Yeo_Index == i);
end
EnergyMat_Path = [EnergyFolder '/InitialAll0_TargetActivationMean.mat'];
Energy_Mat = load(EnergyMat_Path);
for i = 1:8
  Energy_YeoAvg(:, i) = mean(Energy_Mat.Energy(:, System_Indices{i}), 2);
end
save(EnergyMat_Path, 'Energy_YeoAvg', '-append');

