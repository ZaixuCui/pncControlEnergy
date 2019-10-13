
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

Energy_Mat_Path = paste0(ReplicationFolder, '/data/energyData/InitialAll0_TargetMotor.mat');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

ResultantFolder <- paste0(ReplicationFolder, '/results/InitialAll0_TargetMotor');
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
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/NetworkStrength_Prob_946.mat'));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

######################################################################
# 2. Age effect of energy at whole-brain, Yeo system and nodal level #
######################################################################
# Whole-brain level
Energy_WholeBrainAvg <- rowMeans(Energy);
Energy_Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
visreg(Energy_Gam_WholeBrainAvg, 'AgeYears', xlab = 'Age (years)', ylab = 'Control Energy', gg = TRUE);
Energy_lm_WholeBrainAvg <- lm(Energy_WholeBrainAvg ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
P_Value = summary(Energy_Gam_WholeBrainAvg)$s.table[, 4];
if (summary(Energy_lm_WholeBrainAvg)$coefficients[2,3] < 0) {
  Z_Value = -qnorm(P_Value / 2, lower.tail=FALSE);
}  else {
  Z_Value = qnorm(P_Value / 2, lower.tail=FALSE);
}
print(Z_Value);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_WholeBrainLevel.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Z_Value, Age_P = P_Value);
  # Calculate the partial correlation to represent effect size
Energy_WholeBrainAvg_Partial <- lm(Energy_WholeBrainAvg ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior)$residuals;
Age_Partial <- lm(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior)$residuals;
cor.test(Energy_WholeBrainAvg_Partial, Age_Partial);
