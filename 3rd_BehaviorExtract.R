
library(R.matlab)

subjid_df <- read.csv("/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/pncControlEnergy_n946_SubjectsIDs.csv");
#########################################
### 2. Extrating behavior information ###
#########################################  
demo <- subjid_df;
# TBV   
BrainTissue_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_ctVol20170412.csv");
# Demographics 
Demographics_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/demographics/n1601_demographics_go1_20161212.csv");
# Motion
Motion_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_dti_qa_20170301.csv");
# Cognition
Cognition_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/cnb/n1601_cnb_factor_scores_tymoore_20151006.csv");
# Merge all data
demo <- merge(demo, BrainTissue_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Demographics_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Motion_Data, by = c("scanid", "bblid"));
demo <- merge(demo, Cognition_Data, by = c("scanid", "bblid"));
# Output the subjects' behavior data
write.csv(demo, "/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/n946_Behavior_20180807.csv", row.names = FALSE);
