
clear

ProjectsFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
Data_Folder = [ProjectsFolder '/data'];
Matrix_Folder = [Data_Folder '/matrices_withoutBrainStem'];
ResultantFolder = [Data_Folder '/energyData/SpinNullFPTarget'];;

Lausanne125_Matrix_Cell = g_ls([Matrix_Folder '/*.mat']);

T = 1;
rho = 1;
% Control nodes selection
n = 232;
xc = eye(n);

% initial state: all 0
x0 = zeros(n, 1);

RotateIndex_Folder = [ResultantFolder '/FPRotateIndex'];

for m = 1:100
  RotateIndex = load([RotateIndex_Folder '/FPRotateIndex_InAtlas_' num2str(m) '.mat']);
  FPRotateIndex_InAtlas = RotateIndex.FPRotateIndex_InAtlas;
  FPRotateMask_WholeBrain = zeros(233, 1);
  FPRotateMask_WholeBrain(FPRotateIndex_InAtlas) = 1;
  FPRotateMask_WholeBrain = FPRotateMask_WholeBrain([1:191 193:233]); % Remove the 192th region
  xf = FPRotateMask_WholeBrain;

  % Nodes to be constrained
  S = zeros(n);
  for i = 1:length(xf)
    if xf(i) == 1
      S(i, i) = 1;
    end
  end

  ResultantFolder_M = [ResultantFolder '/InitialAll0_TargetFPSpinRotate_' num2str(m)];
  EnergyCal_SGE_Function(Lausanne125_Matrix_Cell, T, xc, x0, xf, S, rho, ResultantFolder_M);

  % Calculating yeo average value; Yeo 7 system + subcortical system
  Atlas_Yeo_Index = load([Data_Folder '/Yeo_7system.mat']);
  Atlas_Yeo_Index = Atlas_Yeo_Index.Yeo_7system([1:191 193:233]); % Remove the 192th region
  for i = 1:8
    System_Indices{i} = find(Atlas_Yeo_Index == i);
  end
  EnergyMat_Path = [ResultantFolder '/InitialAll0_TargetFPSpinRotate_' num2str(m) '.mat'];
  Energy_Mat = load(EnergyMat_Path);
  for i = 1:8
    Energy_YeoAvg(:, i) = mean(Energy_Mat.Energy(:, System_Indices{i}), 2);
  end
  save(EnergyMat_Path, 'Energy_YeoAvg', '-append');

end

