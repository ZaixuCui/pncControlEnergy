
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

#########################################################
# 1. Age effect of energy at Yeo system and nodal level #
#########################################################
# Whole brain level
Energy_WholeBrainAvg <- rowMeans(Energy);
PC_WholeBrainAvg <- rowMeans(PC);
Energy_Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(AgeYears, k=4) + PC_WholeBrainAvg + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, method = "REML", data = Behavior);
visreg(Energy_Gam_WholeBrainAvg, 'AgeYears', xlab = 'Age (years)', ylab = 'Control Energy');
P_Value = summary(Energy_Gam_WholeBrainAvg)$s.table[, 4];
Z_Value = -qnorm(P_Value / 2, lower.tail=FALSE);
print(Z_Value);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_WholeBrainLevel.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Z_Value, Age_P = P_Value);
  # Calculate the partial correlation to represent effect size
Energy_WholeBrainAvg_Partial <- lm(Energy_WholeBrainAvg ~ Sex_factor + PC_WholeBrainAvg + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
Age_Partial <- lm(AgeYears ~ Sex_factor + PC_WholeBrainAvg + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
cor.test(Energy_WholeBrainAvg_Partial, Age_Partial);

# Yeo system average level
print('###### Age effect of energy at Yeo system level ######');
SystemsQuantity = 8;
ColName <- c("Z", "P", "P_FDR", "Partial_Corr");
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Age_YeoAvg <- matrix(0, nrow = SystemsQuantity, ncol = 4, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{ 
  Energy_tmp <- Energy_YeoAvg[, i];
  Energy_Gam <- gam(Energy_tmp ~ s(AgeYears, k=4) + PC_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age_YeoAvg[i, 2] <- summary(Energy_Gam)$s.table[, 4]; 
  Energy_Gam_Age_YeoAvg[i, 1] <- qnorm(Energy_Gam_Age_YeoAvg[i, 2] / 2, lower.tail=FALSE);
  Energy_lm <- lm(Energy_tmp ~ AgeYears + PC_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age_YeoAvg[i, 1] = -Energy_Gam_Age_YeoAvg[i, 1];
  }

  # Calculate the partial correlation to represent effect size
  Energy_tmp_Partial <- lm(Energy_tmp ~ PC_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
  Age_Partial <- lm(AgeYears ~ PC_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
  PCorr_Test <- cor.test(Energy_tmp_Partial, Age_Partial);
  Energy_Gam_Age_YeoAvg[i, 4] = PCorr_Test$estimate;
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
print(Energy_Gam_Age_YeoAvg); 
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoSystemLevel_RegressPC.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_YeoSystemLevel_RegressPC.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3], Age_PCorr = Energy_Gam_Age_YeoAvg[, 4]);

# Nodal level
print('###### Age effect of energy at nodal level ######');
Energy_Gam_Age <- matrix(0, 232, 4);
for (i in 1:232)
{
  Energy_tmp <- Energy[, i];
  # Gam analysis was used for age effect
  Energy_Gam <- gam(Energy_tmp ~ s(AgeYears, k=4) + PC[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  # Covert P value to Z value
  Energy_Gam_Age[i, 1] <- qnorm(Energy_Gam_Age[i, 2] / 2, lower.tail=FALSE);
  # Linear model was used to test whether it is a positive or negative relationship
  Energy_lm <- lm(Energy_tmp ~ AgeYears + PC[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age[i, 1] = -Energy_Gam_Age[i, 1];
  }

  # Calculate the partial correlation to represent effect size
  Energy_tmp_Partial <- lm(Energy_tmp ~ Sex_factor + PC[,i] + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
  Age_Partial <- lm(AgeYears ~ Sex_factor + PC[,i] + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
  PCorr_Test <- cor.test(Energy_tmp_Partial, Age_Partial);
  Energy_Gam_Age[i, 4] = PCorr_Test$estimate;
}
Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
# Write the results to a new matrix with 233 rows, set the values of 192th row as 1
RowName_Nodal_233 <- character(length = 233);
for (i in 1:233)
{
  RowName_Nodal_233[i] = paste("Node", as.character(i));
}
Energy_Gam_Age_New <- matrix(1, nrow = 233, ncol = 4, dimnames = list(RowName_Nodal_233, ColName));
Energy_Gam_Age_New[c(1:191, 193:233), ] = Energy_Gam_Age;
# Storing the results in both .csv and .mat file
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel_RegressPC.csv');
write.csv(Energy_Gam_Age_New, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel_RegressPC.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_New[, 1], Age_P = Energy_Gam_Age_New[, 2], Age_P_FDR = Energy_Gam_Age_New[, 3], Age_PCorr = Energy_Gam_Age_New[, 4]);
print(paste('Resultant file is ', Energy_Gam_Age_Mat, sep = ''));

