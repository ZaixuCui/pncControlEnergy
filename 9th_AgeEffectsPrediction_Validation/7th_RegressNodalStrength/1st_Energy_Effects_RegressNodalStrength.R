
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
NodalStrength_EigNorm_SubIden <- StrengthInfo$NodalStrength.EigNorm.SubIden;
WholeBrainStrength_EigNorm_SubIden <- StrengthInfo$WholeBrainStrength.EigNorm.SubIden;

NodalStrength_EigNorm_SubIden_Yeo = matrix(0, 946, 8);
Yeo_Mat <- readMat(paste0(ReplicationFolder, '/data/Yeo_7system.mat'));
Yeo_7Systems <- Yeo_Mat$Yeo.7system[c(1:191, 193:233)];
for (i in 1:8)
{
  System_I_Index = which(Yeo_7Systems == i);
  NodalStrength_EigNorm_SubIden_Yeo[, i] = rowMeans(NodalStrength_EigNorm_SubIden[, System_I_Index]);
}

######################################################################
# 1. Age effect of energy at whole brain, Yeo system and nodal level #
######################################################################
# Yeo system average level
print('###### Age effect of energy at Yeo system level ######');
SystemsQuantity = 8;
ColName <- c("Z", "P", "P_FDR", "Partial_Corr");
RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
Energy_Gam_Age_YeoAvg <- matrix(0, nrow = SystemsQuantity, ncol = 4, dimnames = list(RowName_Yeo, ColName));
for (i in 1:SystemsQuantity)
{ 
  Energy_tmp <- Energy_YeoAvg[, i];
  Energy_Gam <- gam(Energy_tmp ~ s(AgeYears, k=4) + WholeBrainStrength_EigNorm_SubIden + NodalStrength_EigNorm_SubIden_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
  Energy_Gam_Age_YeoAvg[i, 2] <- summary(Energy_Gam)$s.table[, 4]; 
  Energy_Gam_Age_YeoAvg[i, 1] <- qnorm(Energy_Gam_Age_YeoAvg[i, 2] / 2, lower.tail=FALSE);
  Energy_lm <- lm(Energy_tmp ~ AgeYears + WholeBrainStrength_EigNorm_SubIden + NodalStrength_EigNorm_SubIden_Yeo[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age_YeoAvg[i, 1] = -Energy_Gam_Age_YeoAvg[i, 1];
  }
  
  # Calculate the partial correlation to represent effect size
  Energy_tmp_Partial <- lm(Energy_tmp ~ NodalStrength_EigNorm_SubIden_Yeo[,i] + WholeBrainStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
  Age_Partial <- lm(AgeYears ~ NodalStrength_EigNorm_SubIden_Yeo[,i] + WholeBrainStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
  PCorr_Test <- cor.test(Energy_tmp_Partial, Age_Partial);
  Energy_Gam_Age_YeoAvg[i, 4] = PCorr_Test$estimate;
}
Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
print(Energy_Gam_Age_YeoAvg); 
Energy_Gam_Age_CSV <- file.path(ResultantFolder, '/Energy_Gam_Age_YeoSystemLevel_RegressNodalStrength.csv');
write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, '/Energy_Gam_Age_YeoSystemLevel_RegressNodalStrength.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3], Age_PCorr = Energy_Gam_Age_YeoAvg[, 4]);

# Nodal level
print('###### Age effect of energy at nodal level ######');
Energy_Gam_Age <- matrix(0, 232, 4);
for (i in 1:232)
{
  Energy_tmp <- Energy[, i];
  # Gam analysis was used for age effect
  Energy_Gam <- gam(Energy_tmp ~ s(AgeYears, k=4) + WholeBrainStrength_EigNorm_SubIden + NodalStrength_EigNorm_SubIden[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
  Energy_Gam_Age[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  # Covert P value to Z value
  Energy_Gam_Age[i, 1] <- qnorm(Energy_Gam_Age[i, 2] / 2, lower.tail=FALSE);
  # Linear model was used to test whether it is a positive or negative relationship
  Energy_lm <- lm(Energy_tmp ~ AgeYears + WholeBrainStrength_EigNorm_SubIden + NodalStrength_EigNorm_SubIden[,i] + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age[i, 1] = -Energy_Gam_Age[i, 1];
  }

  # Calculate the partial correlation to represent effect size
  Energy_tmp_Partial <- lm(Energy_tmp ~ NodalStrength_EigNorm_SubIden[,i] + WholeBrainStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
  Age_Partial <- lm(AgeYears ~ NodalStrength_EigNorm_SubIden[,i] + WholeBrainStrength_EigNorm_SubIden + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
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
Energy_Gam_Age_CSV <- file.path(ResultantFolder, '/Energy_Gam_Age_NodalLevel_RegressNodalStrength.csv');
write.csv(Energy_Gam_Age_New, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, '/Energy_Gam_Age_NodalLevel_RegressNodalStrength.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_New[, 1], Age_P = Energy_Gam_Age_New[, 2], Age_P_FDR = Energy_Gam_Age_New[, 3], Age_PCorr = Energy_Gam_Age_New[, 4]);
print(paste('Resultant file is ', Energy_Gam_Age_Mat, sep = ''));

