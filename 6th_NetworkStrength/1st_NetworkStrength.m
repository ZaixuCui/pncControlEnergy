
clear

% Total connection strength of the whole brain
% Probabilistic network
ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
Prob_Folder = [ReplicationFolder '/data/matrices_withoutBrainStem'];
Prob_Cell = g_ls([Prob_Folder '/*.mat']);
NodalStrength_EigNorm_SubIden = zeros(946, 232);
Atlas_Yeo_Index = load([ReplicationFolder '/data/Yeo_7system.mat']);
Atlas_Yeo_Index = Atlas_Yeo_Index.Yeo_7system([1:191 193:233]);
FP_Index = find(Atlas_Yeo_Index == 6);
NonFP_Index = find(Atlas_Yeo_Index ~= 6);
for i = 1:length(Prob_Cell)
  i
  tmp = load(Prob_Cell{i});
  [~, n, ~] = fileparts(Prob_Cell{i});
  scan_ID(i) = str2num(n(1:4));
  WholeBrainStrength_Raw(i) = sum(sum(tmp.connectivity)) / 2;
  % We scaled the matrix by the maximum eigenvalue and then subtract the identity matrix, which was did when calculating the energy 
  A = tmp.connectivity ./ svds(tmp.connectivity, 1);
  A = A - eye(size(A));
  A_triu = triu(A);
  WholeBrainStrength_EigNorm_SubIden(i) = sum(sum(A_triu));
  WithinFPNetworkStrength_EigNorm_SubIden(i) = sum(sum(A_triu(FP_Index, FP_Index)));
  FPOtherNetworkStrength_EigNorm_SubIden(i) = sum(sum(A(FP_Index, NonFP_Index)));
end
WholeBrainStrength_EigNorm_SubIden = WholeBrainStrength_EigNorm_SubIden';
WithinFPNetworkStrength_EigNorm_SubIden = WithinFPNetworkStrength_EigNorm_SubIden';
FPOtherNetworkStrength_EigNorm_SubIden = FPOtherNetworkStrength_EigNorm_SubIden';
save([ReplicationFolder '/data/NetworkStrength_Prob_946.mat'], 'WholeBrainStrength_Raw', 'WholeBrainStrength_EigNorm_SubIden', 'WithinFPNetworkStrength_EigNorm_SubIden', 'FPOtherNetworkStrength_EigNorm_SubIden', 'scan_ID');

