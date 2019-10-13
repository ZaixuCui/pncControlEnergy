
clear

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, testing if nodal efficiency significantly predicted brain age %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AgePrediction_ResFolder = [ReplicationFolder '/results/Age_Prediction/2Fold_Sort_PC'];
Prediction_Fold0_PC = load([AgePrediction_ResFolder '/Fold_0_Score.mat']);
MAE_Actual_Fold0 = Prediction_Fold0_PC.MAE;
Index_Fold0 = Prediction_Fold0_PC.Index + 1;
Prediction_Fold1_PC = load([AgePrediction_ResFolder '/Fold_1_Score.mat']);
MAE_Actual_Fold1 = Prediction_Fold1_PC.MAE;
Index_Fold1 = Prediction_Fold1_PC.Index + 1;

Behavior = load([ReplicationFolder '/data/Age_Prediction/Energy_Behavior_AllSubjects.mat']);
% Fold 0
Age_Fold0 = Behavior.Age(Index_Fold0);
Sex_Fold0 = Behavior.Sex(Index_Fold0);
Handedness_Fold0 = Behavior.HandednessV2(Index_Fold0);
Motion_Fold0 = Behavior.MotionMeanRelRMS(Index_Fold0);
TBV_Fold0 = Behavior.TBV(Index_Fold0);
TotalStength_Fold0 = Behavior.Strength_EigNorm_SubIden(Index_Fold0);
% Fold 1
Age_Fold1 = Behavior.Age(Index_Fold1);
Sex_Fold1 = Behavior.Sex(Index_Fold1);
Handedness_Fold1 = Behavior.HandednessV2(Index_Fold1);
Motion_Fold1 = Behavior.MotionMeanRelRMS(Index_Fold1);
TBV_Fold1 = Behavior.TBV(Index_Fold1);
TotalStength_Fold1 = Behavior.Strength_EigNorm_SubIden(Index_Fold1);

[ParCorr_Actual_Fold0, ~] = partialcorr(Prediction_Fold0_PC.Predict_Score', Age_Fold0, [double(Sex_Fold0) double(Handedness_Fold0) double(Motion_Fold0) double(TBV_Fold0) double(TotalStength_Fold0)]);
[ParCorr_Actual_Fold1, ~] = partialcorr(Prediction_Fold1_PC.Predict_Score', Age_Fold1, [double(Sex_Fold1) double(Handedness_Fold1) double(Motion_Fold1) double(TBV_Fold1) double(TotalStength_Fold1)]);

%% Significance
AgePrediction_PermutationFolder = [ReplicationFolder '/results/Age_Prediction/2Fold_Sort_Permutation_PC'];
% Fold 0
Permutation_Fold0_Cell = g_ls([AgePrediction_PermutationFolder '/Time_*/Fold_0_Score.mat']);
for i = 1:1000
  tmp = load(Permutation_Fold0_Cell{i});
  ParCorr_Rand_Fold0(i) = partialcorr(tmp.Predict_Score', Age_Fold0, [double(Sex_Fold0) double(Handedness_Fold0) double(Motion_Fold0) double(TBV_Fold0) double(TotalStength_Fold0)]);
  MAE_Rand_Fold0(i) = tmp.MAE;
end
ParCorr_Fold0_Sig = length(find(ParCorr_Rand_Fold0 >= ParCorr_Actual_Fold0)) / 1000;
MAE_Fold0_Sig = length(find(MAE_Rand_Fold0 <= MAE_Actual_Fold0)) / 1000;
save([ReplicationFolder '/results/Age_Prediction/2Fold_Sort_Fold0_Specificity_Sig_PC.mat'], 'ParCorr_Actual_Fold0', 'ParCorr_Rand_Fold0', 'ParCorr_Fold0_Sig', 'MAE_Actual_Fold0', 'MAE_Rand_Fold0', 'MAE_Fold0_Sig');
% Fold 1
Permutation_Fold1_Cell = g_ls([AgePrediction_PermutationFolder '/Time_*/Fold_1_Score.mat']);
for i = 1:1000
  tmp = load(Permutation_Fold1_Cell{i});
  ParCorr_Rand_Fold1(i) = partialcorr(tmp.Predict_Score', Age_Fold1, [double(Sex_Fold1) double(Handedness_Fold1) double(Motion_Fold1) double(TBV_Fold1) double(TotalStength_Fold1)]);
  MAE_Rand_Fold1(i) = tmp.MAE;
end
ParCorr_Fold1_Sig = length(find(ParCorr_Rand_Fold1 >= ParCorr_Actual_Fold1)) / 1000;
MAE_Fold1_Sig = length(find(MAE_Rand_Fold1 <= MAE_Actual_Fold1)) / 1000;
save([ReplicationFolder '/results/Age_Prediction/2Fold_Sort_Fold1_Specificity_Sig_PC.mat'], 'ParCorr_Actual_Fold1', 'ParCorr_Rand_Fold1', 'ParCorr_Fold1_Sig', 'MAE_Actual_Fold1', 'MAE_Rand_Fold1', 'MAE_Fold1_Sig');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Testing if brain age predicted by control energy can be %
% explained by participant coefficient                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AgePrediction_ResFolder = [ReplicationFolder '/results/Age_Prediction/2Fold_Sort'];
Prediction_Fold0_Energy = load([AgePrediction_ResFolder '/Fold_0_Score.mat']);
Prediction_Fold1_Energy = load([AgePrediction_ResFolder '/Fold_1_Score.mat']);
% Correlating predicted and actual age while controlling brain age predictedy by nodal efficiency
[ParCorr_Actual_Fold0, ~] = partialcorr(Prediction_Fold0_Energy.Predict_Score', Age_Fold0, [double(Sex_Fold0) double(Handedness_Fold0) double(Motion_Fold0) double(TBV_Fold0) double(TotalStength_Fold0) double(Prediction_Fold0_PC.Predict_Score')]);
[ParCorr_Actual_Fold1, ~] = partialcorr(Prediction_Fold1_Energy.Predict_Score', Age_Fold1, [double(Sex_Fold1) double(Handedness_Fold1) double(Motion_Fold1) double(TBV_Fold1) double(TotalStength_Fold1) double(Prediction_Fold1_PC.Predict_Score')]);
% Test the significance
AgePrediction_Energy_PermutationFolder = [ReplicationFolder '/results/Age_Prediction/2Fold_Sort_Permutation'];
AgePrediction_PC_PermutationFolder = [ReplicationFolder '/results/Age_Prediction/2Fold_Sort_Permutation_PC'];
% Fold 0
Permutation_Fold0_Cell_Energy = g_ls([AgePrediction_Energy_PermutationFolder '/Time_*/Fold_0_Score.mat']);
Permutation_Fold0_Cell_PC = g_ls([AgePrediction_PC_PermutationFolder '/Time_*/Fold_0_Score.mat']);
for i = 1:1000
  tmp_Energy = load(Permutation_Fold0_Cell_Energy{i});
  tmp_PC = load(Permutation_Fold0_Cell_PC{i});
  ParCorr_Rand_Fold0(i) = partialcorr(tmp_Energy.Predict_Score', Age_Fold0, [double(Sex_Fold0) double(Handedness_Fold0) double(Motion_Fold0) double(TBV_Fold0) double(TotalStength_Fold0) double(tmp_PC.Predict_Score')]);
end
ParCorr_Fold0_Sig = length(find(ParCorr_Rand_Fold0 >= ParCorr_Actual_Fold0)) / 1000;
save([ReplicationFolder '/results/Age_Prediction/2Fold_Sort_Fold0_Specificity_Sig_RegressPC.mat'], 'ParCorr_Actual_Fold0', 'ParCorr_Rand_Fold0', 'ParCorr_Fold0_Sig');
% Fold 1
Permutation_Fold1_Cell_Energy = g_ls([AgePrediction_Energy_PermutationFolder '/Time_*/Fold_1_Score.mat']);
Permutation_Fold1_Cell_PC = g_ls([AgePrediction_PC_PermutationFolder '/Time_*/Fold_1_Score.mat']);
for i = 1:1000
  tmp_Energy = load(Permutation_Fold1_Cell_Energy{i});
  tmp_PC = load(Permutation_Fold1_Cell_PC{i});
  ParCorr_Rand_Fold1(i) = partialcorr(tmp_Energy.Predict_Score', Age_Fold1, [double(Sex_Fold1) double(Handedness_Fold1) double(Motion_Fold1) double(TBV_Fold1) double(TotalStength_Fold1) double(tmp_PC.Predict_Score')]);
end
ParCorr_Fold1_Sig = length(find(ParCorr_Rand_Fold1 >= ParCorr_Actual_Fold1)) / 1000;
save([ReplicationFolder '/results/Age_Prediction/2Fold_Sort_Fold1_Specificity_Sig_RegressPC.mat'], 'ParCorr_Actual_Fold1', 'ParCorr_Rand_Fold1', 'ParCorr_Fold1_Sig');

