
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/jux/BBL/projects/pncControlEnergy/scripts/Replication/9th_PredictAge');
import Ridge_CZ_Random

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

ResultantFolder = ReplicationFolder + '/results/Age_Prediction/2Fold_Random';
Ridge_CZ_Random.Ridge_KFold_RandomCV_MultiTimes(Energy, Age, FoldQuantity, Alpha_Range, 100, ResultantFolder, 1, 0);

