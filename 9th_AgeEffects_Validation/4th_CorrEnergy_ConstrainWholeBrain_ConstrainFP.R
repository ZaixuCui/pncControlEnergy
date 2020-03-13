
library(R.matlab)
library(mgcv)
library(reshape2)
library(ggplot2);

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Energy_ConstrainFP = readMat(paste0(Data_Folder, '/energyData/InitialAll0_TargetFP.mat'));
Energy_ConstrainFP_WholeBrainAvg = rowMeans(Energy_ConstrainFP$Energy);
Energy_ConstrainWholeBrain = readMat(paste0(Data_Folder, '/energyData/InitialAll0_TargetFP_ConstrainWholeBrain.mat'));
Energy_ConstrainWholeBrain_WholeBrainAvg = rowMeans(Energy_ConstrainWholeBrain$Energy);

cor.test(Energy_ConstrainFP_WholeBrainAvg, Energy_ConstrainWholeBrain_WholeBrainAvg);
# Plot correlation between control energy cost (constrain FP) 
# and control energy cost (constrain whole-brain) across subjects
data = data.frame(Energy_ConstrainFP = Energy_ConstrainFP_WholeBrainAvg);
data$Energy_ConstrainWholeBrain <- Energy_ConstrainWholeBrain_WholeBrainAvg;
ggplot(data, aes(x = Energy_ConstrainFP, y = Energy_ConstrainWholeBrain)) + 
    geom_point(size = 2) +
    geom_smooth(method = lm) + 
    theme_classic() + labs(x = "", y = "") + 
    theme(axis.text = element_text(size = 32, color = 'black')) + 
    scale_x_continuous(limits = c(0.2, 0.241), breaks = c(0.20, 0.21, 0.22, 0.23, 0.24)) +
    scale_y_continuous(limits = c(0.22, 0.25), breaks = c(0.22, 0.23, 0.24, 0.25)) 
FigureFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/Replication/Figures';
ggsave(paste0(FigureFolder, '/CorrEnergy_ConstrainWholeBrain_ConstrainFP.tiff'), width = 17, height = 15, dpi = 300, units = "cm")

