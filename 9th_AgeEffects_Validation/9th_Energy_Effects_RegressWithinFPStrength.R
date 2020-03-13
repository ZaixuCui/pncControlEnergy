
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
WithinFPNetworkStrength_EigNorm_SubIden <- as.numeric(StrengthInfo$WithinFPNetworkStrength.EigNorm.SubIden);
FPOtherNetworkStrength_EigNorm_SubIden <- as.numeric(StrengthInfo$FPOtherNetworkStrength.EigNorm.SubIden);

##########################################
# Age effect of with-FP network strength #
##########################################
WithinFPStrength_Gam <- gam(WithinFPNetworkStrength_EigNorm_SubIden ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, method = "REML", data = Behavior);
P_Value = summary(WithinFPStrength_Gam)$s.table[, 4];
Z_Value <- qnorm(P_Value / 2, lower.tail=FALSE);
WithinFPStrength_lm <- lm(WithinFPNetworkStrength_EigNorm_SubIden ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior);
Age_T <- summary(WithinFPStrength_lm)$coefficients[2,3];
if (Age_T < 0) {
  Z_Value = -Z_Value;
}
# Calculate the partial correlation to represent effect size
WithinFPStrength_Partial <- lm(WithinFPNetworkStrength_EigNorm_SubIden ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
Age_Partial <- lm(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
cor.test(WithinFPStrength_Partial, Age_Partial)

############################################
# Age effect of FP-Other networks strength #
############################################
FPOtherNetworkStrength_Gam <- gam(FPOtherNetworkStrength_EigNorm_SubIden ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, method = "REML", data = Behavior);
P_Value = summary(FPOtherNetworkStrength_Gam)$s.table[, 4];
Z_Value <- qnorm(P_Value / 2, lower.tail=FALSE);
FPOtherNetworkStrength_lm <- lm(FPOtherNetworkStrength_EigNorm_SubIden ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior);
Age_T <- summary(FPOtherNetworkStrength_lm)$coefficients[2,3];
if (Age_T < 0) {
  Z_Value = -Z_Value;
}
# Calculate the partial correlation to represent effect size
FPOtherNetworkStrength_Partial <- lm(FPOtherNetworkStrength_EigNorm_SubIden ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
Age_Partial <- lm(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
cor.test(FPOtherNetworkStrength_Partial, Age_Partial)

##################################################
# Age effect of energy of fronto-parietal system #
#   Controlling for with-FP network strength     #
##################################################
# Yeo system average level
print('###### Age effect of energy at Yeo system level ######');
i = 6
Energy_tmp <- Energy_YeoAvg[, i];
Energy_Gam <- gam(Energy_tmp ~ s(AgeYears, k=4) + WithinFPNetworkStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, method = "REML", data = Behavior);
P_Value = summary(Energy_Gam)$s.table[, 4]; 
Z_Value <- qnorm(P_Value / 2, lower.tail=FALSE);
Energy_lm <- lm(Energy_tmp ~ AgeYears + WithinFPNetworkStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior);
Age_T <- summary(Energy_lm)$coefficients[2,3];
if (Age_T < 0) {
  Z_Value = -Z_Value;
}
# Calculate the partial correlation to represent effect size
Energy_tmp_Partial <- lm(Energy_tmp ~ WithinFPNetworkStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
Age_Partial <- lm(AgeYears ~ WithinFPNetworkStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
cor.test(Energy_tmp_Partial, Age_Partial)

##################################################
# Age effect of energy of fronto-parietal system #
#   Controlling for FP-Other network strength    #
##################################################
# Yeo system average level
print('###### Age effect of energy at Yeo system level ######');
i = 6
Energy_tmp <- Energy_YeoAvg[, i];
Energy_Gam <- gam(Energy_tmp ~ s(AgeYears, k=4) + FPOtherNetworkStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, method = "REML", data = Behavior);
P_Value = summary(Energy_Gam)$s.table[, 4];
Z_Value <- qnorm(P_Value / 2, lower.tail=FALSE);
Energy_lm <- lm(Energy_tmp ~ AgeYears + FPOtherNetworkStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior);
Age_T <- summary(Energy_lm)$coefficients[2,3];
if (Age_T < 0) {
  Z_Value = -Z_Value;
}
# Calculate the partial correlation to represent effect size
Energy_tmp_Partial <- lm(Energy_tmp ~ FPOtherNetworkStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
Age_Partial <- lm(AgeYears ~ FPOtherNetworkStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
cor.test(Energy_tmp_Partial, Age_Partial)


