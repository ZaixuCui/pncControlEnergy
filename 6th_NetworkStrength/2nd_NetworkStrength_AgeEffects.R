
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';

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
WholeBrainStrength_Raw <- as.numeric(StrengthInfo$WholeBrainStrength.Raw);
WholeBrainStrength_EigNorm_SubIden <- as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden);

# Raw whole brain strength
Strength_Gam <- gam(WholeBrainStrength_Raw ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
Fig <- visreg(Strength_Gam, 'AgeYears', xlab = 'Age (years)', ylab = 'Total Network Strength', line.par = list(col = '#000000'), gg = TRUE) + 
       theme_classic() + theme(axis.text=element_text(size=32, color='black')) + 
       scale_y_continuous(limits = c(100, 204), breaks = c(100, 130, 160, 190)) +
       geom_point(color = '#000000', size = 1.5)
ggsave(paste(ReplicationFolder, '/results_Revise/NodalStrength/WholeBrainStrength_Raw_Scatter.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");
Strength_lm <- lm(WholeBrainStrength_Raw ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior);
P_Value = summary(Strength_Gam)$s.table[, 4];
if (summary(Strength_lm)$coefficients[2,3] < 0) {
  Z_Value = -qnorm(P_Value / 2, lower.tail=FALSE);
}  else {
  Z_Value = qnorm(P_Value / 2, lower.tail=FALSE);
}
# Partial correlation
WholeBrainStrength_Raw_Partial <- lm(WholeBrainStrength_Raw ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
Age_Partial <- lm(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
cor.test(WholeBrainStrength_Raw_Partial, Age_Partial);

# Whole brain strength after scaling 
Strength_Gam <- gam(WholeBrainStrength_EigNorm_SubIden ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, method = "REML", data = Behavior);
Fig <- visreg(Strength_Gam, 'AgeYears', xlab = 'Age (years)', ylab = 'Total Network Strength', line.par = list(col = '#000000'), gg = TRUE) +
       theme_classic() + theme(axis.text=element_text(size=32, color='black')) +
       scale_y_continuous(limits = c(-160, -127), breaks = c(-150, -140, -130)) +
       geom_point(color = '#000000', size = 1.5)
ggsave(paste(ReplicationFolder, '/results_Revise/NodalStrength/WholeBrainStrength_EigNorm_SubIden_Scatter.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");
Strength_lm <- lm(WholeBrainStrength_EigNorm_SubIden ~ AgeYears + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior);
P_Value = summary(Strength_Gam)$s.table[, 4];
if (summary(Strength_lm)$coefficients[2,3] < 0) {
  Z_Value = -qnorm(P_Value / 2, lower.tail=FALSE);
}  else {
  Z_Value = qnorm(P_Value / 2, lower.tail=FALSE);
}
# Partial correlation
WholeBrainStrength_EigNorm_SubIden_Partial <- lm(WholeBrainStrength_EigNorm_SubIden ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
Age_Partial <- lm(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV, data = Behavior)$residuals;
cor.test(WholeBrainStrength_EigNorm_SubIden_Partial, Age_Partial);

