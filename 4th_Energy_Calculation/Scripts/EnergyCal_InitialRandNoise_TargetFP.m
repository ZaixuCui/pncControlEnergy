
clear

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];

EnergyFolder = [Data_Folder '/energyData'];

Lausanne125_Matrix_Cell = g_ls([Matrix_Folder '/*.mat']);

T = 1;
rho = 1;
% Control nodes selection
n = 232;
xc = eye(n);

% initial state: all 0
x0 = zeros(n, 1);

Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system.mat']);
Atlas_Yeo_Index = Atlas_Yeo_Index.Yeo_7system([1:191 193:233]); % Remove the 192th region
% Target state: average activation data 
xf = Atlas_Yeo_Index;
xf(find(xf ~= 6)) = 0;
xf(find(xf == 6)) = 1;

% Nodes to be constrained
S = zeros(n);
for i = 1:length(xf)
  if xf(i) == 1
    S(i, i) = 1;
  end
end

% Extract indices of Yeo system
for j = 1:8
  System_Indices{j} = find(Atlas_Yeo_Index == j);
end

for i = 1:100
  disp(i);
  ResultantFolder = [EnergyFolder '/InitialRandNoise_ConstrainFP/InitialRandNoise_TargetFP_' num2str(i)];
  ConfigurationFolder = [ResultantFolder '/Configuration'];
  if ~exist([ConfigurationFolder '/x0_RandNoise.mat'])
    %mkdir(ConfigurationFolder);
    %x0_RandNoise = x0;
    %x0_RandNoise(find(xf)) = 0.1 * randn(27, 1);
    %save([ConfigurationFolder '/x0_RandNoise.mat'], 'x0_RandNoise');
  else
    load([ConfigurationFolder '/x0_RandNoise.mat']);
  end
  EnergyCal_SGE_Function(Lausanne125_Matrix_Cell, T, xc, x0_RandNoise, xf, S, rho, ResultantFolder);
end

for i = 1:100
  % Calculating yeo average value; Yeo 7 system + subcortical system
  EnergyMat_Path = [EnergyFolder '/InitialRandNoise_ConstrainFP/InitialRandNoise_TargetFP_' num2str(i) '.mat'];
  Energy_Mat = load(EnergyMat_Path);
  for j = 1:8
    Energy_YeoAvg(:, j) = mean(Energy_Mat.Energy(:, System_Indices{j}), 2);
  end
  save(EnergyMat_Path, 'Energy_YeoAvg', '-append');
end
