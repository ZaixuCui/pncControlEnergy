
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

# Import participant coefficient
PC_Mat <- readMat(paste0(ReplicationFolder, '/data/PC.mat'));
PC <- PC_Mat$PC;

# Whole-brain level
Energy_WholeBrainAvg <- rowMeans(Energy);
PC_WholeBrainAvg <- rowMeans(PC);
Energy_Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(AgeYears, k=4) + PC_WholeBrainAvg + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam_WholeBrainAvg, "AgeYears", xlab = "", ylab = "", line.par = list(col = '#000000'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(0.2071, 0.228), breaks = c(0.210, 0.215, 0.220, 0.225))
Fig + geom_point(color = '#000000', size = 1.5)
ggsave(paste(FigureFolder, '/AgeEffect_WholeBrainLevel_Scatter_RegressPC.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");

# FP Network
i = 6
# Calculating average nodal efficiency of FP network
Yeo_Mat <- readMat(paste0(ReplicationFolder, '/data/Yeo_7system.mat'));
Yeo_7Systems <- Yeo_Mat$Yeo.7system[c(1:191, 193:233)];
System_I_Index = which(Yeo_7Systems == i);
PC_FPNetworkAvg = rowMeans(PC[, System_I_Index]);
#
tmp_variable <- Energy_YeoAvg[, i];
Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + PC_FPNetworkAvg + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam, "AgeYears", xlab = "", ylab = "", line.par = list(col = '#F5BA2E'), fill = list(fill = '#F3DDA8'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(1.73, 1.93), breaks = c(1.75, 1.80, 1.85, 1.90), label = c("1.75", "1.80", "1.85", "1.90"))
Fig + geom_point(color = '#F5BA2E', size = 1.5)
ggsave(paste0(FigureFolder, '/AgeEffect_Scatter_Frontoparietal_RegressPC.tiff'), width = 17, height = 15, dpi = 300, units = "cm");
