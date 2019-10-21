
####
# Extract data for mediation analysis (i.e., behavior data and control energy)
# We only test the bilateral mid-cingulate regions (i.e., 43th and 157th), as only these two regions represent significant cognition effects after FDR correction
####

library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

Energy_Mat_Path = paste0(ReplicationFolder, '/data/energyData/InitialAll0_TargetFP.mat');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;

ResultantFolder <- paste0(ReplicationFolder, '/results/InitialAll0_TargetFP');
if (!dir.exists(ResultantFolder))
{
  dir.create(ResultantFolder, recursive = TRUE);
}

###############################################
# Import demographics, cognition and strength #
###############################################
# Demographics, motion, TBV
AllInfo <- read.csv(paste0(ReplicationFolder, '/data/n946_Behavior_20180807.csv'));
Behavior <- data.frame(Sex_factor = as.factor(AllInfo$sex));
Behavior$AgeYears <- as.numeric(AllInfo$ageAtScan1/12);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);
# Whole brain strength of the network
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/WholeBrainStrength_Prob_946.mat'));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

NonNANIndex <- which(!is.na(AllInfo$F3_Executive_Efficiency));
Behavior_Cognition <- data.frame(ExecutiveEfficiency = as.numeric(AllInfo$F3_Executive_Efficiency[NonNANIndex]));
Behavior_Cognition$AgeYears <- Behavior$AgeYears[NonNANIndex];
Behavior_Cognition$Sex_factor <- Behavior$Sex_factor[NonNANIndex];
Behavior_Cognition$HandednessV2 <- Behavior$HandednessV2[NonNANIndex];
Behavior_Cognition$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NonNANIndex];
Behavior_Cognition$TBV <- Behavior$TBV[NonNANIndex];
Behavior_Cognition$Strength_EigNorm_SubIden <- Strength_EigNorm_SubIden[NonNANIndex];
Energy_Cognition <- Energy[NonNANIndex,];

# Mediation analysis
Behavior_Cognition$Energy_43 = Energy_Cognition[, 43];
Behavior_Cognition$Energy_157 = Energy_Cognition[, 157];

write.csv(Behavior_Cognition, paste0(ResultantFolder, '/DataForMediation.csv'));


