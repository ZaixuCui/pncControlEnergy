
library('R.matlab');
library('ggplot2');

ReplicationFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
FigureFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/Replication/Figures';

Yeo_atlas <- readMat(file.path(ReplicationFolder, '/data/Yeo_7system.mat'));
Yeo_Index <- Yeo_atlas$Yeo.7system[c(1:191, 193:233)];

InitialAll0_TargetActivation <- readMat(file.path(ReplicationFolder, '/data/energyData/InitialAll0_TargetFP.mat'));
Energy <- InitialAll0_TargetActivation$Energy;
Energy_SubjectsAvg <- log(colMeans(Energy));
tmp <- data.frame(Energy_data = Energy_SubjectsAvg, Yeo = Yeo_Index);
tmp$Yeo <- factor(tmp$Yeo, levels = c(1:8), labels = c("VS", "MT", "DA", "VA", "LM", "FP", "DM", "SC"));
Fig <- ggplot(tmp, aes(x = Yeo, y = Energy_data)) + geom_boxplot(fill = c("#AF33AD", "#7499C2", "#00A131", "#E443FF", "#EBE297", "#F5BA2E", "#E76178", "#5091CD"), width = 0.7) + geom_jitter()
Fig <- Fig + labs(x = "", y = "log(Control Energy)") + theme_classic()
Fig <- Fig + theme(axis.text.x = element_text(size= 32, colour="black"), 
                   axis.text.y = element_text(size= 32, colour="black"), 
                   axis.title=element_text(size = 32));
Fig + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(paste0(FigureFolder, '/Energyln_Boxplot.tiff'), width = 16, height = 15, units = "cm");

