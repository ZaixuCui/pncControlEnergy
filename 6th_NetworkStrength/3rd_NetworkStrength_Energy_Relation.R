
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

Energy_Mat_Path = paste0(ReplicationFolder, '/data/energyData/InitialAll0_TargetFP.mat');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_WholeBrainAvg <- rowMeans(Energy);

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
Behavior$WholeBrainStrength_Raw <- as.numeric(StrengthInfo$WholeBrainStrength.Raw);
Behavior$WholeBrainStrength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

# Energy vs. Raw whole brain strength
Energy_Strength_Gam <- gam(Energy_WholeBrainAvg ~ WholeBrainStrength_Raw + s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
Fig <- visreg(Energy_Strength_Gam, 'wholeBrainStrength_Raw', xlab = 'Total Network Strength', ylab = 'Control Energy', line.par = list(col = '#000000'), gg = TRUE) + 
       theme_classic() + theme(axis.text=element_text(size=32, color='black')) + 
       scale_y_continuous(limits = c(100, 204), breaks = c(100, 130, 160, 190)) +
       geom_point(color = '#000000', size = 1.5)
ggsave(paste(ReplicationFolder, '/results_Revise/NodalStrength/Energy_WholeBrainStrength_Raw_Scatter.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");
# Partial correlation
WholeBrainStrength_Raw_Partial <- lm(WholeBrainStrength_Raw ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
Energy_Partial <- lm(Energy_WholeBrainAvg ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
cor.test(WholeBrainStrength_Raw_Partial, Energy_Partial);

# Energy vs. Whole brain strength after scaling 
Energy_Strength_Gam <- gam(Energy_WholeBrainAvg ~ WholeBrainStrength_EigNorm_SubIden + s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
Fig <- visreg(Energy_Strength_Gam, 'WholeBrainStrength_EigNorm_SubIden', xlab = 'Total Network Strength', ylab = 'Control Energy', line.par = list(col = '#000000'), gg = TRUE) +
       theme_classic() + theme(axis.text=element_text(size=32, color='black')) +
       scale_y_continuous(limits = c(-160, -127), breaks = c(-150, -140, -130)) +
       geom_point(color = '#000000', size = 1.5)
ggsave(paste(ReplicationFolder, '/results_Revise/NodalStrength/Energy_WholeBrainStrength_EigNorm_SubIden_Scatter.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");
# Partial correlation
WholeBrainStrength_EigNorm_SubIden_Partial <- lm(WholeBrainStrength_EigNorm_SubIden ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
Energy_Partial <- lm(Energy_WholeBrainAvg ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
cor.test(WholeBrainStrength_EigNorm_SubIden_Partial, Energy_Partial);

