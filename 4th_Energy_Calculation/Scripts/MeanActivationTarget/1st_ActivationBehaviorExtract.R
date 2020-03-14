
library(R.matlab)

#########################################################################
###   Averaging activation for these 946 subjects                     ###
###   Only 675 subjects have activation data in all regions           ###
###   So, average these 675 subjects                                  ###
#########################################################################
subjid_df <- read.csv("/data/jux/BBL/projects/pncControlEnergy/results/Replication_Prob/data/pncControlEnergy_n946_SubjectsIDs.csv");
# Extract average activation of 675 subjects 
nback_All_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/nbackGlmBlockDesign/n1601_Laussanne_scale125.csv");
nbackQA_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/nbackGlmBlockDesign/n1601_NBACKQAData_20181001.csv");
nbackBehavior_Data <- read.csv("/data/joy/BBL/studies/pnc/n1601_dataFreeze/neuroimaging/nback/n1601_nbackBehavior_from_20160207_dataRelease_20161027.csv");
nback_All_Data <- merge(nback_All_Data, nbackQA_Data, by = c("scanid", "bblid"));
nback_All_Data <- merge(nback_All_Data, nbackBehavior_Data, by = c("scanid", "bblid"));
# Select the activation data of the 946 subjects
Activation_Extract <- merge(subjid_df, nback_All_Data, by = c("scanid", "bblid"));
# Extracting the activation and removing subjects with nbackExclude=1, nbackZerobackNrExclude=1
st <- which(colnames(Activation_Extract) == 'Laussannescale125_contrast4_2back.0back_roi1');
nd <- which(colnames(Activation_Extract) == 'Laussannescale125_contrast4_2back.0back_roi233');
Include_SubjectIndex <- which(Activation_Extract$nbackExclude == 0);
Activation_2b0b <- as.matrix(Activation_Extract[Include_SubjectIndex, st:nd]);
scan_ID_Activation <- subjid_df$scanid[Include_SubjectIndex]
# Mean activation
Activation_2b0b_MeanAcrossNodes <- rowMeans(Activation_2b0b);
# Remove subjects with NAN, finally only 675 subjects have activation
# Average the 675 subjects' activation, resulting in average activation
NonNANIndex <- which(!is.na(Activation_2b0b_MeanAcrossNodes));
Activation_2b0b_Extract <- Activation_2b0b[NonNANIndex,]
# Activation_2b0b_Extract variable is a 675*233 matrix
# Remove the 192th region, because we removed this region in the brain network
Activation_2b0b_Extract <- Activation_2b0b_Extract[, c(1:191, 193:233)]
scan_ID_Activation <- scan_ID_Activation[NonNANIndex]
Activation_675_Avg <- colMeans(Activation_2b0b_Extract);
writeMat("/data/jux/BBL/projects/pncControlEnergy/results/Replication/data/Activation_675_Avg.mat", Activation_675_Avg = Activation_675_Avg, Activation_675 = Activation_2b0b_Extract, scan_ID_Activation = scan_ID_Activation);

