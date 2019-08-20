##########################################################################################################
### This script will construct a subject sample for PNC-ControlEnergy-Development analyses, retaining  ###
###     subjects who passed quality assurance protocols for Freesurfer, DTI, and healthExcludev2.      ###
###                                 Finally, 946 subjects remained.                                    ###
##########################################################################################################

library(R.matlab)

#########################################################
### 1. Filter subjects, finally 946 subjects remained ###
#########################################################
## LTN and Health Status
health <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/health/n1601_health_20170421.csv")
## T1
t1_qa <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/t1struct/n1601_t1QaData_20170306.csv")
## DTI 
dti_qa <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/dti/n1601_dti_qa_20170301.csv")
## B0 Acquisition
protVal <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/n1601_pnc_protocol_validation_params_status_20161220.csv")
ControlEnergy_df <- health
## Merge QA data 
ControlEnergy_df <- merge(ControlEnergy_df, t1_qa, by=c("scanid","bblid"))
ControlEnergy_df <- merge(ControlEnergy_df, dti_qa, by=c("scanid","bblid"))
ControlEnergy_df <- merge(ControlEnergy_df, protVal, by=c("scanid","bblid"))
### Define study sample using exclusion criteria
## Health Exclude
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$healthExcludev2 == 0 & ControlEnergy_df$ltnExcludev2 == 0), ]
dim(ControlEnergy_df)
## FreeSurfer QA
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$fsFinalExclude == 0), ] 
## Valid and complete 64-direction DTI sequence
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$dti64ProtocolValidationStatus == 1), ]
## B0 acquisition and distortion correction
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$b0ProtocolValidationStatus==1), ]
## Roalf's DTI QA
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$dti64Exclude == 0), ]
dim(ControlEnergy_df)
####################################
# After above criteria, 949 subjects remaining.
# Within these subjects, 18 subjects have isolated nodes, because the region was missing during the brain parcellation.
# 17 subjects lost the 192th region, 1 subject (ID: 5474) lost 18th region, 1 subject (ID: 2796) lost 78th region, 1 subject (ID: 6191) lost 195th region.
# We removed the three subjects (ID: 5474, 2796, 6191)here. And next step, we will remove the 192th region from the network. 
###################################
ControlEnergy_df <- ControlEnergy_df[which(ControlEnergy_df$scanid != 5474 & ControlEnergy_df$scanid != 2796 & ControlEnergy_df$scanid != 6191), ]
dim(ControlEnergy_df);
## Specify columns to retain
attach(ControlEnergy_df)
keeps <- c("bblid", "scanid")
## Define new dataframe with specified columns 
subjid_df <- ControlEnergy_df[keeps]
dim(subjid_df)
detach(ControlEnergy_df)
## Write out subject identifiers to CSV
## Finally, we get 946 subjects
dir.create("/data/jux/BBL/projects/pncControlEnergy/results/Replication/data");
write.csv(subjid_df, "/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/pncControlEnergy_n946_SubjectsIDs.csv", row.names=FALSE)

