
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

# Demographics, motion, TBV
AllInfo <- read.csv(paste0(ReplicationFolder, '/data/n946_Behavior_20180807.csv'));
Behavior <- data.frame(Sex_factor = as.factor(AllInfo$sex));
Behavior$AgeYears <- as.numeric(AllInfo$ageAtScan1/12);
Behavior$HandednessV2 <- as.factor(AllInfo$handednessv2);
Behavior$MotionMeanRelRMS <- as.numeric(AllInfo$dti64MeanRelRMS);
Behavior$TBV <- as.numeric(AllInfo$mprage_antsCT_vol_TBV);
# Whole brain strength of the  network
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/NetworkStrength_Prob_946.mat'));
Strength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

ResultantFolder <- paste0(ReplicationFolder, '/results/InitialAll0_TargetFPShuffled');
if (!dir.exists(ResultantFolder))
{ 
  dir.create(ResultantFolder, recursive = TRUE);
}
Energy_Data_Folder = paste0(ReplicationFolder, '/data/energyData');

###################
### Age effects ###
###################
for (i in c(1:100))
{
  Energy_Mat_Path <- paste0(Energy_Data_Folder, '/ShuffledTargets_ConstrainFP/InitialAll0_TargetFPShuffle_', as.character(i), '.mat');
  Energy_Mat = readMat(Energy_Mat_Path);
  Energy <- Energy_Mat$Energy;
  Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

  # Age effect at whole-brain level
  Energy_WholeBrainAvg <- rowMeans(Energy);
  Energy_Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);  
  Energy_lm_WholeBrainAvg <- lm(Energy_WholeBrainAvg ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
  P_Value = summary(Energy_Gam_WholeBrainAvg)$s.table[, 4];
  if (summary(Energy_lm_WholeBrainAvg)$coefficients[2,3] < 0) {
    Z_Value = -qnorm(P_Value / 2, lower.tail=FALSE); 
  }  else {
    Z_Value = qnorm(P_Value / 2, lower.tail=FALSE);
  }
  # Calculate the partial correlation to represent effect size
  Energy_WholeBrainAvg_Partial <- lm(Energy_WholeBrainAvg ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior)$residuals;
  Age_Partial <- lm(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior)$residuals;
  Correlation = cor.test(Energy_WholeBrainAvg_Partial, Age_Partial);
  PartialCorr = Correlation$estimate;
  # Write to the file
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_WholeBrainLevel_ShuffledTarget_', as.character(i), '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Z_Value, Age_P = P_Value, Age_PCorr = PartialCorr);
  print(Z_Value)

  ColName <- c("Z", "P", "P_FDR", "PartialCorr");
  # Age effect at Yeo system average level
  print('###### Age effect of energy at Yeo system level ######');
  SystemsQuantity = 8;
  RowName_Yeo = c('Visual', 'Somatomotor', 'Dorsal attention', 'Ventral attention', 'Limbic', 'Frontalprietal', 'Default mode', 'Subcortical');
  Energy_Gam_Age_YeoAvg <- matrix(c(1:SystemsQuantity*4), nrow = SystemsQuantity, ncol = 4, dimnames = list(RowName_Yeo, ColName));
  for (j in 1:SystemsQuantity)
  {
    tmp_variable <- Energy_YeoAvg[, j];
    Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
    Energy_Gam_Age_YeoAvg[j, 2] <- summary(Energy_Gam)$s.table[, 4];
    Energy_Gam_Age_YeoAvg[j, 1] <- qnorm(Energy_Gam_Age_YeoAvg[j, 2] / 2, lower.tail=FALSE);
    Energy_lm <- lm(tmp_variable ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior);
    Age_T <- summary(Energy_lm)$coefficients[2,3];
    if (Age_T < 0) {
      Energy_Gam_Age_YeoAvg[j, 1] = -Energy_Gam_Age_YeoAvg[j, 1];
    }

    # Calculate the partial correlation to represent effect size
    Energy_tmp_Partial <- lm(tmp_variable ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior)$residuals;
    Age_Partial <- lm(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, data = Behavior)$residuals;
    PCorr_Test <- cor.test(Energy_tmp_Partial, Age_Partial);
    Energy_Gam_Age_YeoAvg[j, 4] = PCorr_Test$estimate;
  }
  Energy_Gam_Age_YeoAvg[, 3] <- p.adjust(Energy_Gam_Age_YeoAvg[, 2], "fdr");
  Energy_Gam_Age_CSV <- file.path(ResultantFolder, paste0('Energy_Gam_Age_YeoSystemLevel_ShuffledTarget_', as.character(i), '.csv'));
  write.csv(Energy_Gam_Age_YeoAvg, Energy_Gam_Age_CSV);
  Energy_Gam_Age_Mat <- file.path(ResultantFolder, paste0('Energy_Gam_Age_YeoSystemLevel_ShuffledTarget_', as.character(i), '.mat'));
  writeMat(Energy_Gam_Age_Mat, Age_Z = Energy_Gam_Age_YeoAvg[, 1], Age_P = Energy_Gam_Age_YeoAvg[, 2], Age_P_FDR = Energy_Gam_Age_YeoAvg[, 3], Age_PCorr = Energy_Gam_Age_YeoAvg[, 4]);
  print(Energy_Gam_Age_YeoAvg);
}

# Plot histogram for whole-brain level and fronto-parietal system analysis
FigureFolder <- paste0(ReplicationFolder, '/Figures');
ResultsFolder <- paste0(ReplicationFolder, '/results');
# Real Network 
Res_Path <- paste0(ResultsFolder, '/InitialAll0_TargetFP/Energy_Gam_Age_WholeBrainLevel.mat');
tmp <- readMat(Res_Path);
WholeBrain_PCorr <- tmp$Age.PCorr;
Res_Path <- paste0(ResultsFolder, '/InitialAll0_TargetFP/Energy_Gam_Age_YeoSystemLevel.mat');
tmp <- readMat(Res_Path);
FP_PCorr <- tmp$Age.PCorr[6];
# Shuffled Targets
WholeBrain_PCorr_ShuffledTarget <- matrix(0, 100, 1);
FP_PCorr_ShuffledTarget <- matrix(0, 100, 1);
for (i in c(1:100))
{ 
  Res_Path <- paste0(ResultsFolder, '/InitialAll0_TargetFPShuffled/Energy_Gam_Age_WholeBrainLevel_ShuffledTarget_', as.character(i), '.mat');
  tmp <- readMat(Res_Path);
  WholeBrain_PCorr_ShuffledTarget[i] <- tmp$Age.PCorr;
  Res_Path <- paste0(ResultsFolder, '/InitialAll0_TargetFPShuffled/Energy_Gam_Age_YeoSystemLevel_ShuffledTarget_', as.character(i), '.mat');
  tmp <- readMat(Res_Path);
  FP_PCorr_ShuffledTarget[i] <- tmp$Age.PCorr[6];
}
 
# Whole brain
data <- data.frame(PCorr_ShuffledTarget = WholeBrain_PCorr_ShuffledTarget);
Fig <- ggplot(data, aes(x = PCorr_ShuffledTarget)) + geom_histogram(bins = 30);
Fig <- Fig + labs(x = "", y = "") + theme_classic()
Fig <- Fig + theme(axis.text = element_text(size= 32, color = "black"))
Fig + scale_x_continuous(limits = c(-0.3, 0.42), breaks = c(-0.2, 0, 0.2, 0.4)) + scale_y_continuous(limits = c(0, 14.5), breaks = c(0, 5, 10), expand = c(0, 0))
ggsave(paste(FigureFolder, '/AgeEffect_ShuffledTarget_PCorr_WholeBrain.tiff', sep = ''), width = 15, height = 15, dpi = 300, units = "cm");
# FP
data <- data.frame(PCorr_ShuffledTarget = FP_PCorr_ShuffledTarget);
Actual_Res <- data.frame(x = FP_PCorr);
Actual_Res$y <- 0;
Fig <- ggplot(data, aes(x = PCorr_ShuffledTarget)) + geom_histogram(bins=30);
Fig <- Fig + labs(x = "", y = "") + theme_classic()
Fig <- Fig + theme(axis.text = element_text(size= 32, color = "black"))
Fig + scale_x_continuous(limits = c(-0.3, 0.3), breaks = c(-0.2, 0, 0.2)) + scale_y_continuous(limits = c(0, 11), breaks = c(0, 5, 10), expand = c(0, 0))
ggsave(paste(FigureFolder, '/AgeEffect_ShuffledTarget_PCorr_FP.tiff', sep = ''), width = 15, height = 15, dpi = 300, units = "cm");

