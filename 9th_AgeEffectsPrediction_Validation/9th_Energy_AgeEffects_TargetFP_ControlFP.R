
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

Energy_Mat_Path = paste0(ReplicationFolder, '/data/energyData/InitialAll0_TargetFP_ControlFP.mat');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

ResultantFolder <- paste0(ReplicationFolder, '/results_Revise/InitialAll0_TargetFP_ControlFP');
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
YeoLabel_Mat <- readMat(paste0(ReplicationFolder, '/data/Yeo_7system.mat'));
Yeo_7System_Label <- YeoLabel_Mat$Yeo.7system;
Yeo_7System_Label <- Yeo_7System_Label[c(1:191,193:233)]; # Remove the 192th region
FP_Index <- which(Yeo_7System_Label == 6);

# Age effect of control energy in FP system
Energy_WholeBrainAvg <- rowMeans(Energy[,FP_Index]);
Energy_Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, method = "REML", data = Behavior);
Energy_lm_WholeBrainAvg <- lm(Energy_WholeBrainAvg ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior);
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
Energy_WholeBrainAvg_Partial <- lm(Energy_WholeBrainAvg ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
Age_Partial <- lm(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
cor.test(Energy_WholeBrainAvg_Partial, Age_Partial);
# Scatter plot
Fig <- visreg(Energy_Gam_WholeBrainAvg, 'AgeYears', xlab = 'Age (years)', ylab = 'Control Energy', line.par = list(col = '#000000'), gg = TRUE) +
       theme_classic() + theme(axis.text=element_text(size=32, color='black')) +
       scale_y_continuous(limits = c(1.83, 2.0), breaks = c(1.85, 1.90, 1.95, 2.00)) +
       geom_point(color = '#000000', size = 1.5)
ggsave(paste(ResultantFolder, '/AgeEffect_Energy_ControlFP_Scatter.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");

# Nodal level
print('###### Age effect of energy at nodal level ######');
FP_NodesQuantity <- length(FP_Index);
Energy_Gam_Age <- matrix(0, FP_NodesQuantity, 4);
for (i in 1:FP_NodesQuantity)
{
  Energy_tmp <- Energy[, FP_Index[i]];
  # Gam analysis was used for age effect
  Energy_Gam <- gam(Energy_tmp ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, method = "REML", data = Behavior);
  Energy_Gam_Age[i, 2] <- summary(Energy_Gam)$s.table[, 4];
  # Covert P value to Z value
  Energy_Gam_Age[i, 1] <- qnorm(Energy_Gam_Age[i, 2] / 2, lower.tail=FALSE);
  # Linear model was used to test whether it is a positive or negative relationship
  Energy_lm <- lm(Energy_tmp ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior);
  Age_T <- summary(Energy_lm)$coefficients[2,3];
  if (Age_T < 0) {
    Energy_Gam_Age[i, 1] = -Energy_Gam_Age[i, 1];
  }

  # Calculate the partial correlation to represent effect size
  Energy_tmp_Partial <- lm(Energy_tmp ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
  Age_Partial <- lm(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden, data = Behavior)$residuals;
  PCorr_Test <- cor.test(Energy_tmp_Partial, Age_Partial);
  Energy_Gam_Age[i, 4] = PCorr_Test$estimate;
}
Energy_Gam_Age[, 3] <- p.adjust(Energy_Gam_Age[, 2], "fdr");
Energy_Gam_Age_232 <- matrix(1, nrow = 232, ncol = 4);
Energy_Gam_Age_232[FP_Index, ] <- Energy_Gam_Age;
# Write the results to a new matrix with 233 rows, set the values of 192th row as 1
RowName_Nodal_233 <- character(length = 233);
for (i in 1:233)
{ 
  RowName_Nodal_233[i] = paste("Node", as.character(i));
}
Energy_Gam_Age_New <- matrix(1, nrow = 233, ncol = 4, dimnames = list(RowName_Nodal_233, c("Z", "P", "P_FDR", "Partial_Corr")));
Energy_Gam_Age_New[c(1:191, 193:233), ] = Energy_Gam_Age_232;
# Storing the results in both .csv and .mat file
Energy_Gam_Age_CSV <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.csv');
write.csv(Energy_Gam_Age_New, Energy_Gam_Age_CSV);
Energy_Gam_Age_Mat <- file.path(ResultantFolder, 'Energy_Gam_Age_NodalLevel.mat');
writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_New[, 1], Age_P = Energy_Gam_Age_New[, 2], Age_P_FDR = Energy_Gam_Age_New[, 3], Age_PCorr = Energy_Gam_Age_New[, 4]);
print(paste('Resultant file is ', Energy_Gam_Age_Mat, sep = ''));

################################################
# 2. Cognition effect of energy at nodal level #
################################################
NonNANIndex <- which(!is.na(AllInfo$F3_Executive_Efficiency));
Behavior_Cognition <- data.frame(ExecutiveEfficiency = as.numeric(AllInfo$F3_Executive_Efficiency[NonNANIndex]));
Behavior_Cognition$AgeYears <- Behavior$AgeYears[NonNANIndex];
Behavior_Cognition$Sex_factor <- Behavior$Sex_factor[NonNANIndex];
Behavior_Cognition$HandednessV2 <- Behavior$HandednessV2[NonNANIndex];
Behavior_Cognition$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NonNANIndex];
Behavior_Cognition$TBV <- Behavior$TBV[NonNANIndex];
WholeBrainStrength_EigNorm_SubIden_Cognition <- WholeBrainStrength_EigNorm_SubIden[NonNANIndex];
Energy_Cognition <- Energy[NonNANIndex,];

print('###### Cognition effect of energy at nodal level ######');
Energy_Gam_Cognition <- matrix(0, FP_NodesQuantity, 4);
for (i in 1:FP_NodesQuantity)
{ 
  Energy_tmp <- Energy_Cognition[, FP_Index[i]];
  # Gam analysis was used for age effect
  Energy_Gam <- gam(Energy_tmp ~ ExecutiveEfficiency + s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_Cognition);
  Energy_Gam_Cognition[i, 1] <- summary(Energy_Gam)$p.table[2, 3];
  Energy_Gam_Cognition[i, 2] <- summary(Energy_Gam)$p.table[2, 4];

  # Calculate the partial correlation to represent effect size
  Energy_tmp_Partial <- lm(Energy_tmp ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden_Cognition, data = Behavior_Cognition)$residuals;
  EF_Partial <- lm(ExecutiveEfficiency ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + WholeBrainStrength_EigNorm_SubIden_Cognition, data = Behavior_Cognition)$residuals;
  PCorr_Test <- cor.test(Energy_tmp_Partial, EF_Partial);
  Energy_Gam_Cognition[i, 4] = PCorr_Test$estimate;
}
Energy_Gam_Cognition[, 3] <- p.adjust(Energy_Gam_Cognition[, 2], "fdr");
Energy_Gam_Cognition_232 <- matrix(1, nrow = 232, ncol = 4);
Energy_Gam_Cognition_232[FP_Index, ] <- Energy_Gam_Cognition;
# Write the results to a new matrix with 233 rows, set the values of 192th row as 1
RowName_Nodal_233 <- character(length = 233);
for (i in 1:233)
{ 
  RowName_Nodal_233[i] = paste("Node", as.character(i));
}
Energy_Gam_Cognition_New <- matrix(1, nrow = 233, ncol = 4, dimnames = list(RowName_Nodal_233, c("Z", "P", "P_FDR", "Partial_Corr")));
Energy_Gam_Cognition_New[c(1:191, 193:233), ] = Energy_Gam_Cognition_232;
# Storing the results in both .csv and .mat file
Energy_Gam_Cognition_CSV <- file.path(ResultantFolder, 'Energy_Gam_Cognition_NodalLevel.csv');
write.csv(Energy_Gam_Cognition_New, Energy_Gam_Cognition_CSV);
Energy_Gam_Cognition_Mat <- file.path(ResultantFolder, 'Energy_Gam_Cognition_NodalLevel.mat');
writeMat(Energy_Gam_Cognition_Mat, Cognition_Z = Energy_Gam_Cognition_New[, 1], Cognition_P = Energy_Gam_Cognition_New[, 2], Cognition_P_FDR = Energy_Gam_Cognition_New[, 3], Cognition_PCorr = Energy_Gam_Cognition_New[, 4]);
print(paste('Resultant file is ', Energy_Gam_Cognition_Mat, sep = ''));

