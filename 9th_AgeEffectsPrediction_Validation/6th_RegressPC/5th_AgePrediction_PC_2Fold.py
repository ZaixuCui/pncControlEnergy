
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/jux/BBL/projects/pncControlEnergy/scripts/Replication/8th_PredictAge');
import Ridge_CZ_Sort

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
DataFolder = ReplicationFolder + '/data/Age_Prediction';
# Import data
Data_Mat = sio.loadmat(DataFolder + '/Energy_Behavior_AllSubjects.mat');
PC = Data_Mat['PC'];
Age = Data_Mat['Age'];
Age = np.transpose(Age);
# Range of parameters
Alpha_Range = np.exp2(np.arange(16) - 10);

FoldQuantity = 2;

ResultantFolder = ReplicationFolder + '/results/Age_Prediction/2Fold_Sort_PC';
Ridge_CZ_Sort.Ridge_KFold_Sort(PC, Age, FoldQuantity, Alpha_Range, ResultantFolder, 1, 0);

# Permutation test, 1,000 times
Permutation_Times = 1000;
Times_IDRange = np.arange(Permutation_Times);
Permutation_RandIndex_File_List = [''] * Permutation_Times;
for i in np.arange(Permutation_Times):
  Permutation_RandIndex_File_List[i] = ReplicationFolder + \
                 '/results/Age_Prediction/2Fold_Sort_Permutation/' + 'Time_' + str(i) + '/RandIndex.mat';

ResultantFolder = ReplicationFolder + '/results/Age_Prediction/2Fold_Sort_Permutation_PC';
#Ridge_CZ_Sort.Ridge_KFold_Sort_Permutation(PC, Age, Times_IDRange, FoldQuantity, Alpha_Range, ResultantFolder, 1, 1000, '-q all.q,basic.q', Permutation_RandIndex_File_List)


