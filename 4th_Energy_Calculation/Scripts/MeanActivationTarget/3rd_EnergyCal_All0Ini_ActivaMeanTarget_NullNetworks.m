
clear

% Energy of null networks (preserving the degree and strength distribution, but destroying the topological structure)

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

EnergyFolder = [Data_Folder '/energyData'];

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

% Extract indices of Yeo system
% Calculating yeo average value; Yeo 7 system + subcortical system
Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system.mat']);
Atlas_Yeo_Index = Atlas_Yeo_Index.Yeo_7system([1:191 193:233]); % Remove the 192th region
for i = 1:8
  System_Indices{i} = find(Atlas_Yeo_Index == i);
end

for i = 51:100
  Lausanne125_Matrix_Cell = g_ls([Matrix_Folder '_NullNetworks/NullNetwork_' num2str(i, '%03d') '/*.mat']);
  ResultantFolder = [EnergyFolder '/NullNetworks_ActivationMean/InitialAll0_TargetActivationMean_NullNetwork_' num2str(i)];
  mkdir(ResultantFolder);
  EnergyCal_SGE_Function(Lausanne125_Matrix_Cell, T, xc, x0, xf, S, rho, ResultantFolder);
end

for i = 50:100
  Lausanne125_Matrix_Cell = g_ls([Matrix_Folder '_NullNetworks/NullNetwork_' num2str(i, '%03d') '/*.mat']);
  ResultantFolder = [EnergyFolder '/NullNetworks_ActivationMean/InitialAll0_TargetActivationMean_NullNetwork_' num2str(i)];
  mkdir(ResultantFolder);
  EnergyCal_SGE_Function(Lausanne125_Matrix_Cell, T, xc, x0, xf, S, rho, ResultantFolder);
end

for i = 1:100
  % Calculating yeo average value; Yeo 7 system + subcortical system
  EnergyMat_Path = [EnergyFolder '/NullNetworks_ActivationMean/InitialAll0_TargetActivationMean_NullNetwork_' num2str(i) '.mat'];
  Energy_Mat = load(EnergyMat_Path);
  for j = 1:8
    Energy_YeoAvg(:, j) = mean(Energy_Mat.Energy(:, System_Indices{j}), 2);
  end
  save(EnergyMat_Path, 'Energy_YeoAvg', '-append');
end
