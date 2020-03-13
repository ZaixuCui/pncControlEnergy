
library(R.matlab)
library(mgcv)
library(reshape2)
library(ggplot2);

Data_Folder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication/data';
Trajectory_Info = readMat(paste0(Data_Folder, '/energyData/InitialAll0_TargetFP_TrajectoryInfo.mat'));
X_Trajectories_SubjectsAvg = Trajectory_Info$X.Trajectories.SubjectsAvg;
Distance_Series = Trajectory_Info$Distance.Series;
Energy_Series = Trajectory_Info$Energy.Series;
# Plot trajectory
Trajectories_SubjectsAvg = melt(X_Trajectories_SubjectsAvg);
ggplot(data = Trajectories_SubjectsAvg, aes(x = Var1, y = Var2, fill = value)) +
    geom_tile() +
    #scale_fill_gradient2(low = "blue", mid = "cyan", high = "purple") + 
    #labs(x = 'Time (a.u.)', y = 'Region') +
    labs(x = '', y = '') + 
    theme_classic() + 
    theme(axis.text = element_text(size = 30, color = 'black')) +
    theme(axis.title = element_text(size = 25)) +
    theme(legend.text = element_text(size = 20), legend.title = element_text(size = 20)) + 
    scale_x_continuous(expand = c(0, 0)) + 
    scale_y_continuous(expand = c(0, 0)) + 
    labs(fill = "");
ggsave(paste0(Data_Folder, '/energyData/Trajectories_SubjectsAvg.tiff'), width = 22, height = 15, dpi = 300, units = "cm");
# Plot correlation between energy and distance across subjects
data = data.frame(Energy_Subjects = Trajectory_Info$Energy.Subjects);
data$Distance_Subjects <- Trajectory_Info$Distance.Subjects;
ggplot(data, aes(x = Distance_Subjects, y = Energy_Subjects)) + 
    geom_point(size = 2) +
    geom_smooth(method = lm) + 
    theme_classic() + labs(x = "Trajectory Distance", y = "") + 
    theme(axis.text = element_text(size = 25, color = 'black'), axis.title = element_text(size = 30)) + 
    scale_x_continuous(limits = c(2505, 2555), breaks = c(2510, 2530, 2550)) +
    scale_y_continuous(limits = c(47.5, 56), breaks = c(48, 52, 56)) 
ggsave(paste0(Data_Folder, '/energyData/Distance_Energy_Corr.tiff'), width = 18, height = 13.5, dpi = 300, units = "cm")
