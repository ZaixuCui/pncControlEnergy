
import scipy.io as sio
import numpy as np
import os
import sys
sys.path.append('/data/jux/BBL/projects/pncControlEnergy/scripts/Replication/10th_PredictAge');
import Ridge_CZ_Sort

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
DataFolder = ReplicationFolder + '/data/Age_Prediction';
# Import all samples
Data_Mat = sio.loadmat(DataFolder + '/Energy_Behavior_AllSubjects.mat');
Energy = Data_Mat['Energy'];
Age = Data_Mat['Age'];
Age = np.transpose(Age);
# Range of parameters
Alpha_Range = np.exp2(np.arange(16) - 10);

ResultantFolder = ReplicationFolder + '/results/Age_Prediction/Weight';
Ridge_CZ_Sort.Ridge_Weight(Energy, Age, 1, 2, Alpha_Range, ResultantFolder, 1)

