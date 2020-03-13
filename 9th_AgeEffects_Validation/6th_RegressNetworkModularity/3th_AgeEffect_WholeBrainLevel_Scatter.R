
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

# Import modularity Q
Modularity_Q_Mat <- readMat(paste0(ReplicationFolder, '/data/Modularity_Yeo_Q_Prob.mat'));
Modularity_Q <- as.numeric(Modularity_Q_Mat$Modularity.Yeo.Q);

# Whole-brain level
Energy_WholeBrainAvg <- rowMeans(Energy);
Energy_Gam_WholeBrainAvg <- gam(Energy_WholeBrainAvg ~ s(AgeYears, k=4) + Modularity_Q + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method = "REML", data = Behavior);
Fig <- visreg(Energy_Gam_WholeBrainAvg, "AgeYears", xlab = "", ylab = "", line.par = list(col = '#000000'), gg = TRUE)
Fig <- Fig + theme_classic() + theme(axis.text=element_text(size=32, color='black'));
Fig <- Fig + scale_y_continuous(limits = c(0.2071, 0.228), breaks = c(0.210, 0.215, 0.220, 0.225))
Fig + geom_point(color = '#000000', size = 1.5)
ggsave(paste(FigureFolder, '/AgeEffect_WholeBrainLevel_Scatter_RegressModularityQ.tiff', sep = ''), width = 17, height = 15, dpi = 300, units = "cm");

