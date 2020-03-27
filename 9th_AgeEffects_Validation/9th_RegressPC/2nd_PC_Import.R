
library(R.matlab);

ReplicationFolder = '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
# Import participant coefficient
AllInfo <- read.csv(paste0(ReplicationFolder, '/data/n946_Behavior_20180807.csv'));
scanID <- AllInfo$scanid;
PC_Folder <- paste0(ReplicationFolder, '/data/PC');
PC <- matrix(0, 946, 232);
for (i in c(1:length(scanID)))
{
  print(i);
  tmp <- readMat(paste0(PC_Folder, '/', as.character(scanID[i]), '.mat'));
  PC[i,] <- tmp$PC;
}

# Calculating participant coefficient of each Yeo network
PC_Yeo = matrix(0, 946, 8);
Yeo_Mat <- readMat(paste0(ReplicationFolder, '/data/Yeo_7system.mat'));
Yeo_7Systems <- Yeo_Mat$Yeo.7system[c(1:191, 193:233)];
for (i in 1:8)
{
  System_I_Index = which(Yeo_7Systems == i);
  PC_Yeo[, i] = rowMeans(PC[, System_I_Index]);
}
writeMat(paste0(ReplicationFolder, '/data/PC.mat'), PC = PC, PC_Yeo = PC_Yeo, scanID = scanID);


