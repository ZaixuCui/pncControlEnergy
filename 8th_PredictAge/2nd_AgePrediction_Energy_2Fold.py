
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/jux/BBL/projects/pncControlEnergy/scripts/Replication/9th_PredictAge');
import Ridge_CZ_Sort

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
DataFolder = ReplicationFolder + '/data/Age_Prediction';
# Import data
Data_Mat = sio.loadmat(DataFolder + '/Energy_Behavior_AllSubjects.mat');
Energy = Data_Mat['Energy'];
Age = Data_Mat['Age'];
Age = np.transpose(Age);
# Range of parameters
Alpha_Range = np.exp2(np.arange(16) - 10);

FoldQuantity = 2;

ResultantFolder = ReplicationFolder + '/results/Age_Prediction/2Fold_Sort';
Ridge_CZ_Sort.Ridge_KFold_Sort(Energy, Age, FoldQuantity, Alpha_Range, ResultantFolder, 1, 0);

# Permutation test, 1,000 times
Times_IDRange = np.arange(1000);
ResultantFolder = ReplicationFolder + '/results/Age_Prediction/2Fold_Sort_Permutation';
Ridge_CZ_Sort.Ridge_KFold_Sort_Permutation(Energy, Age, Times_IDRange, FoldQuantity, Alpha_Range, ResultantFolder, 1, 1000, '-q all.q,basic.q')
