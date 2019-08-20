
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
NodalStrength_EigNorm_SubIden <- StrengthInfo$NodalStrength.EigNorm.SubIden;

NodalStrength_EigNorm_SubIden_Yeo = matrix(0, 946, 8);
Yeo_Mat <- readMat(paste0(ReplicationFolder, '/data/Yeo_7system.mat'));
Yeo_7Systems <- Yeo_Mat$Yeo.7system[c(1:191, 193:233)];
FPSystem_Index = which(Yeo_7Systems == 6);
NodalStrength_EigNorm_SubIden_FP = rowMeans(NodalStrength_EigNorm_SubIden[, FPSystem_Index]);

i = 6;
tmp_variable <- Energy_YeoAvg[, i];
Energy_Gam <- gam(tmp_variable ~ s(AgeYears, k=4) + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden + NodalStrength_EigNorm_SubIden_FP, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam, "AgeYears", xlab = "", ylab = "", line.par = list(col = '#F5BA2E'), fill = list(fill = '#F3DDA8'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(1.78, 1.881), breaks = c(1.78, 1.81, 1.84, 1.87), label = c("1.78", "1.81", "1.84", "1.87"))
Fig + geom_point(color = '#F5BA2E', size = 1.5)
ggsave(paste0(FigureFolder, '/AgeEffect_Scatter_Frontoparietal_RegressNS.tiff'), width = 17, height = 15, dpi = 300, units = "cm");
