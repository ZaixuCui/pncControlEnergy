
library(R.matlab);
library(mgcv);
library(visreg);
library(ggplot2);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
FigureFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/Figures';

Energy_Mat_Path = paste0(ReplicationFolder, '/data/energyData/InitialAll0_TargetFP.mat');
Energy_Mat = readMat(Energy_Mat_Path);
Energy <- Energy_Mat$Energy;
Energy_YeoAvg <- Energy_Mat$Energy.YeoAvg;

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

# Whole-brain level scatter plot
Energy_WholeBrainAvg <- rowMeans(Energy);
Energy_Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam_WholeBrainAvg, "AgeYears", xlab = "", ylab = "", line.par = list(col = '#000000'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(0.2075, 0.228), breaks = c(0.210, 0.215, 0.220, 0.225))
Fig + geom_point(color = '#000000', size = 1.5)
ggsave(paste(FigureFolder, '/AgeEffect_WholeBrainLevel_Scatter.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");

# Bar plot
Result_Path <- paste0(ReplicationFolder, '/results');
AgeEffect_Mat <- paste(Result_Path, '/InitialAll0_TargetFP/Energy_Gam_Age_YeoSystemLevel.mat', sep = '');
AgeEffect <- readMat(AgeEffect_Mat);
data <- data.frame(AgeEffects_Z = AgeEffect$Age.Z)
data$EffectRank <- rank(data$AgeEffects_Z);
BorderColor <- c("#F5BA2E", "#AF33AD", "#7499C2", "#5091cd",
                 "#00A131", "#E443FF", "#E76178", "#EBE297");
LineType <- c("solid", "solid", "solid", "solid", "dashed",
              "solid", "solid", "solid");
Fig <- ggplot(data, aes(EffectRank, AgeEffects_Z)) + 
       geom_bar(stat = "identity", fill = c("#F5BA2E", "#AF33AD", "#7499C2", 
                "#5091cd", "#FFFFFF", "#E443FF", "#E76178", "#EBE297"), 
                colour = BorderColor, linetype = LineType, width=0.8) + 
       labs(x = "", y = "") + theme_classic() +
       theme(axis.text.x = element_text(size = 32, color = "black"),
             axis.text.y = element_text(size = 32, color = "black"),
             axis.title = element_text(size = 32)) +
       theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
       scale_x_discrete(limits = c(1, 2, 3, 4, 5, 6, 7, 8),
             labels = c("FP", "VS", "MT", "SC", "DA", "VA", "DM", "LM"))# +
       #scale_y_continuous(limits = c(-10, 10), breaks = c(-10, -5, 0, 5, 10));
Fig
ggsave(paste0(FigureFolder, '/AgeEffect_YeoLevel_Bar.tiff'), width = 16, height = 15, dpi = 300, units = "cm");

# Scatter plot for age effects
# Fronto-parietal system
print("Frontoparietal");
i = 6
tmp_variable <- Energy_YeoAvg[, i];
Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam, "AgeYears", xlab = "", ylab = "", line.par = list(col = '#F5BA2E'), fill = list(fill = '#F3DDA8'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(1.73, 1.91), breaks = c(1.75, 1.80, 1.85, 1.90), label = c("1.75", "1.80", "1.85", "1.90"))
Fig + geom_point(color = '#F5BA2E', size = 1.5)
ggsave(paste(FigureFolder, '/AgeEffect_Scatter_Frontoparietal.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");

# Visual
print("Visual");
i = 1
tmp_variable <- Energy_YeoAvg[, i];
Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam, "AgeYears", xlab = "", ylab = "", line.par = list(col = '#AF33AD'), fill = list(fill = '#EFC9EE'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(0, 0.0011), breaks = c(0, 0.00050, 0.001), label = c("0", "5.0", "10.0"))
Fig + geom_point(color = '#AF33AD', size = 1.5)
ggsave(paste(FigureFolder, '/AgeEffect_Scatter_Visual.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");

# Somatomotor
print("Somatomotor");
i = 2
tmp_variable <- Energy_YeoAvg[, i];
Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam, "AgeYears", xlab = "", ylab = "", line.par = list(col = '#7499C2'), fill = list(fill = '#D9E2EC'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(0.001, 0.0048), breaks = c(0.001, 0.002, 0.003, 0.004), label = c("1.0", "2.0", "3.0", "4.0"))
Fig + geom_point(color = '#7499C2', size = 1.5)
ggsave(paste(FigureFolder, '/AgeEffect_Scatter_Somatomotor.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");

# Limbic
print("Limbic");
i = 5
tmp_variable <- Energy_YeoAvg[, i];
Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam, "AgeYears", xlab = "", ylab = "", line.par = list(col = '#EBE297'), fill = list(fill = '#F5F2D9'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(0.002, 0.0098), breaks = c(0.002, 0.004, 0.006, 0.008), label = c("2.0", "4.0", "6.0", "8.0"))
Fig + geom_point(color = '#EBE297', size = 1.5);
ggsave(paste(FigureFolder, '/AgeEffect_Scatter_Limbic.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");

# Default mode
print("Default mode");
i = 7
tmp_variable <- Energy_YeoAvg[, i];
Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam, "AgeYears", xlab = "", ylab = '', line.par = list(col = '#E76178'), fill = list(fill = '#F8BCC6'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(0.006, 0.013), breaks = c(0.006, 0.008, 0.010, 0.012), label = c("6.0", "8.0", "10.0", "12.0"))
Fig + geom_point(color = '#E76178', size = 1.5);
ggsave(paste(FigureFolder, '/AgeEffect_Scatter_DefaultMode.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");

# Subcortical
print("Subcortical");
i = 8
tmp_variable <- Energy_YeoAvg[, i];
Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam, "AgeYears", xlab = "", ylab = '', line.par = list(col = '#5091cd'), fill = list(fill = '#b4d1ec'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(0, 0.021), breaks = c(0, 0.01, 0.02), label = c("0", "1.0", "2.0"))
Fig + geom_point(color = '#5091cd', size = 1.5);
ggsave(paste(FigureFolder, '/AgeEffect_Scatter_Subcortical.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");

# Ventral attention
print("Ventral attention");
i = 4
tmp_variable <- Energy_YeoAvg[, i];
Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam, "AgeYears", xlab = "", ylab = "", line.par = list(col = '#E443FF'), fill = list(fill = '#F6C9FF'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(0.005, 0.030), breaks = c(0.005, 0.015, 0.025), label = c("0.5", "1.5", "2.5"))
Fig + geom_point(color = '#E443FF', size = 1.5)
ggsave(paste(FigureFolder, '/AgeEffect_Scatter_VentralAttention.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");
# There is an outlier, energy in ventral attention for no. 798 subject 
ind <- setdiff(c(1:946), 798);
tmp_variable <- tmp_variable[ind];
Behavior_VA <- data.frame(AgeYears = Behavior$AgeYears[ind]);
Behavior_VA$Sex_factor <- Behavior$Sex_factor[ind];
Behavior_VA$HandednessV2 <- Behavior$HandednessV2[ind];
Behavior_VA$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[ind];
Behavior_VA$TBV <- Behavior$TBV[ind];
Behavior_VA$Strength_EigNorm_SubIden <- Strength_EigNorm_SubIden[ind];
Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior_VA);

# Scatter plot for cognition effects
NonNANIndex <- which(!is.na(AllInfo$F3_Executive_Efficiency));
Behavior_Cognition <- data.frame(ExecutiveEfficiency = as.numeric(AllInfo$F3_Executive_Efficiency[NonNANIndex]));
Behavior_Cognition$AgeYears <- Behavior$AgeYears[NonNANIndex];
Behavior_Cognition$Sex_factor <- Behavior$Sex_factor[NonNANIndex];
Behavior_Cognition$HandednessV2 <- Behavior$HandednessV2[NonNANIndex];
Behavior_Cognition$MotionMeanRelRMS <- Behavior$MotionMeanRelRMS[NonNANIndex];
Behavior_Cognition$TBV <- Behavior$TBV[NonNANIndex];
Strength_EigNorm_SubIden_Cognition <- Strength_EigNorm_SubIden[NonNANIndex];
Energy_Cognition <- Energy[NonNANIndex,];
# Frontalparietal
print("43th region, FP system");
i = 43 # the 43th region, right
tmp_variable <- Energy_Cognition[, i];
Energy_Gam <- gam(tmp_variable ~ ExecutiveEfficiency + s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_Cognition);
Fig <- visreg(Energy_Gam, "ExecutiveEfficiency", xlab = "", ylab = "", line.par = list(col = '#F5BA2E'), fill = list(fill = '#F3DDA8'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=30, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(1.81, 2.24), breaks = c(1.8, 2.0, 2.2))
Fig + geom_point(color = '#F5BA2E', size = 1.5)
ggsave(paste0(FigureFolder, '/CognitionEffect_Scatter_Nodal_43Right.tiff'), width = 17, height = 15, dpi = 300, units = "cm");

print("157th region, FP system");
i = 157 # the 157th region, left
tmp_variable <- Energy_Cognition[, i];
Energy_Gam <- gam(tmp_variable ~ ExecutiveEfficiency + s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden_Cognition, method = "REML", data = Behavior_Cognition);
Fig <- visreg(Energy_Gam, "ExecutiveEfficiency", xlab = "", ylab = "", line.par = list(col = '#F5BA2E'), fill = list(fill = '#F3DDA8'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=30, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(1.7, 2.25), breaks = c(1.7, 1.9, 2.1))
Fig + geom_point(color = '#F5BA2E', size = 1.5)
ggsave(paste0(FigureFolder, '/CognitionEffect_Scatter_Nodal_157Left.tiff'), width = 17, height = 15, dpi = 300, units = "cm");

