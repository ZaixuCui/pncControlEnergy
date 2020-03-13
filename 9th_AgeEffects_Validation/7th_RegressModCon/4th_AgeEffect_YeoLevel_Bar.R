
library(ggplot2)
library(R.matlab)
library(cowplot)

ReplicationFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
Result_Path <- paste0(ReplicationFolder, '/results');
FigureFolder <- paste0(ReplicationFolder, '/Figures');

AgeEffect_Mat <- paste(Result_Path, '/InitialAll0_TargetFP/Energy_Gam_Age_YeoSystemLevel_RegressModControl.mat', sep = '');
AgeEffect <- readMat(AgeEffect_Mat);

data <- data.frame(AgeEffects_Z = as.numeric(AgeEffect$Age.Z));
data$EffectRank <- rank(data$AgeEffects_Z);
BorderColor <- c("#F5BA2E", "#AF33AD", "#7499C2", "#5091cd",
                 "#00A131", "#E443FF", "#E76178", "#EBE297");
LineType <- c("solid", "solid", "solid", "dashed", "dashed", 
              "dashed", "solid", "solid");
Fig <- ggplot(data, aes(EffectRank, AgeEffects_Z)) + 
       geom_bar(stat = "identity", fill = c("#F5BA2E", "#AF33AD", 
              "#7499C2", "#FFFFFF", "#FFFFFF", "#FFFFFF", "#E76178", "#EBE297"),
              colour = BorderColor, linetype = LineType, width = 0.8) + 
       labs(x = "", y = "") + theme_classic() +
       theme(axis.text.x = element_text(size = 32, color = "black"),
             axis.text.y = element_text(size = 32, color = "black"),
             axis.title = element_text(size = 32)) +
       theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
       scale_x_discrete(limits = c(1, 2, 3, 4, 5, 6, 7, 8),
             labels = c("FP", "VS", "MT", "SC", "DA", "VA", "DM", "LM")) +
       scale_y_continuous(limits = c(-10, 10));
Fig
ggsave(paste0(FigureFolder, '/AgeEffect_YeoLevel_Bar_RegressModControl.tiff'), width = 16, height = 15, dpi = 300, units = "cm");

