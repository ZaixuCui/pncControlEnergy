
library(R.matlab)
library(ggplot2)

Folder <- '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/energyData';
Energy_Actual_Mat <- readMat(paste0(Folder, '/InitialAll0_TargetMotor.mat'));
Energy_Actual <- Energy_Actual_Mat$Energy;
Energy_Actual_WholeBrainAvg <- rowMeans(Energy_Actual);

RepeatQuantity <- 100;
Energy_NullNetworks = matrix(0, 946, 232);
Energy_NullNetworks_WholeBrainAvg = matrix(0, 946, 1);
for (i in 1:100)
{
  tmp <- readMat(paste0(Folder, '/NullNetworks/InitialAll0_TargetMotor_NullNetwork_', as.character(i), '.mat'));
  Energy_NullNetworks = Energy_NullNetworks + tmp$Energy;
  Energy_NullNetworks_WholeBrainAvg = Energy_NullNetworks_WholeBrainAvg + rowMeans(tmp$Energy);
}
Energy_NullNetworks = Energy_NullNetworks / RepeatQuantity;
Energy_NullNetworks_WholeBrainAvg = Energy_NullNetworks_WholeBrainAvg / RepeatQuantity;

# Compare the whole brain average energy between actual networks and null networks (paired t-test)
Res <- t.test(Energy_Actual_WholeBrainAvg, Energy_NullNetworks_WholeBrainAvg, paired = TRUE);
print(Res$p.value);
print(mean(Energy_Actual_WholeBrainAvg));
print(mean(Energy_NullNetworks_WholeBrainAvg));

# plot
FigureFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/Replication/Figures';
Energy <- rbind(as.matrix(Energy_Actual_WholeBrainAvg), Energy_NullNetworks_WholeBrainAvg);
Label <- rbind(matrix(1, 946, 1), matrix(2, 946, 1));
tmp <- data.frame(Energy = Energy, Label = Label);
tmp$Label <- factor(tmp$Label, levels = c(1:2));
Fig <- ggplot(tmp, aes(x = Label, y = Energy)) + geom_boxplot(fill = c("#636466", "#c7c8ca")) + geom_jitter()
Fig <- Fig + labs(x = "", y = "Control Energy") + theme_classic()
Fig <- Fig + theme(axis.text.y = element_text(size= 37, colour="black"), 
                   axis.title=element_text(size = 37));
Fig <- Fig + scale_y_continuous(limits = c(0.25, 0.36), breaks = c(0.25, 0.30, 0.35), expand = c(0, 0))
Fig + theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave(paste0(FigureFolder, '/Energy_TrueNullNetwork_Motor.tiff'), width = 17, height = 15, dpi = 100, units = "cm");

