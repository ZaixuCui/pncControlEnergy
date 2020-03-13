
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

Energy_Mat_Path = paste0(ReplicationFolder, '/data/energyData/InitialAll0_TargetFP.mat');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

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
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/NetworkStrength_Prob_946.mat'));
WholeBrainStrength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

# Extract participant coefficient
PCInfo <- readMat(paste0(ReplicationFolder, '/data/PC.mat'));
PC <- PCInfo$PC;
PC_Yeo <- PCInfo$PC.Yeo;

##################################################
# Age effect of energy of fronto-parietal system #
##################################################
# Yeo system average level
print('###### Age effect of energy at Yeo system level ######');
i = 6
Energy_tmp <- Energy_YeoAvg[, i];
PC_SystemI <- PC_Yeo[,i];
Energy_Gam <- gam(Energy_tmp ~ s(AgeYears, k=4) + PC_SystemI + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, method = "REML", data = Behavior);
P_Value = summary(Energy_Gam)$s.table[, 4]; 
Z_Value <- qnorm(P_Value / 2, lower.tail=FALSE);
Energy_lm <- lm(Energy_tmp ~ AgeYears + PC_SystemI + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior);
Age_T <- summary(Energy_lm)$coefficients[2,3];
if (Age_T < 0) {
  Z_Value = -Z_Value;
}

# Calculate the partial correlation to represent effect size
Energy_tmp_Partial <- lm(Energy_tmp ~ PC_SystemI + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
Age_Partial <- lm(AgeYears ~ PC_SystemI + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
cor.test(Energy_tmp_Partial, Age_Partial)

