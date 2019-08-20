
library(R.matlab)
library(ggplot2)
library(visreg)

ReplicationFolder <- '/data/jux/BBL/projects/pncControlEnergy/results/Replication';
PredictionFolder <- paste0(ReplicationFolder, '/results/Age_Prediction/2Fold_Sort_NS');
Fold0 <- readMat(paste0(PredictionFolder, '/Fold_0_Score.mat'));
TestScore_Fold0 <- t(Fold0$Test.Score);
PredictScore_Fold0 <- as.numeric(t(Fold0$Predict.Score));
Index_Fold0 <- Fold0$Index + 1;
Fold1 <- readMat(paste0(PredictionFolder, '/Fold_1_Score.mat'));
TestScore_Fold1 <- t(Fold1$Test.Score);
PredictScore_Fold1 <- as.numeric(t(Fold1$Predict.Score));
Index_Fold1 <- Fold1$Index + 1;

FigureFolder <- paste0(ReplicationFolder, '/Figures');
Behavior <- readMat(paste0(ReplicationFolder, '/data/Age_Prediction/Energy_Behavior_AllSubjects.mat'));
StrengthInfo <- readMat(paste0(ReplicationFolder, '/data/NetworkStrength_Prob_946.mat'));
Behavior_Fold0 = data.frame(Age_Fold0 = as.numeric(Behavior$Age[Index_Fold0]));
Behavior_Fold0$Sex_Fold0 = as.numeric(Behavior$Sex[Index_Fold0]);
Behavior_Fold0$Handedness_Fold0 = as.numeric(Behavior$HandednessV2[Index_Fold0]);
Behavior_Fold0$Motion_Fold0 = as.numeric(Behavior$MotionMeanRelRMS[Index_Fold0]);
Behavior_Fold0$TBV_Fold0 = as.numeric(Behavior$TBV[Index_Fold0]);
Behavior_Fold0$TotalStrength_Fold0 = as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden[Index_Fold0]);
# Fold 1
Behavior_Fold1 = data.frame(Age_Fold1 = as.numeric(Behavior$Age[Index_Fold1]));
Behavior_Fold1$Sex_Fold1 = as.numeric(Behavior$Sex[Index_Fold1]);
Behavior_Fold1$Handedness_Fold1 = as.numeric(Behavior$HandednessV2[Index_Fold1]);
Behavior_Fold1$Motion_Fold1 = as.numeric(Behavior$MotionMeanRelRMS[Index_Fold1]);
Behavior_Fold1$TBV_Fold1 = as.numeric(Behavior$TBV[Index_Fold1]);
Behavior_Fold1$TotalStrength_Fold1 = as.numeric(StrengthInfo$WholeBrainStrength.EigNorm.SubIden[Index_Fold1]);

# Fold 0
Energy_lm <- lm(PredictScore_Fold0 ~ Age_Fold0 + Sex_Fold0 + Handedness_Fold0 + Motion_Fold0 + TBV_Fold0 + TotalStrength_Fold0, data = Behavior_Fold0);
plotdata <- visreg(Energy_lm, "Age_Fold0", type = "conditional", scale = "linear", plot = FALSE);
smooths <- data.frame(Variable = plotdata$meta$x, 
                      x = plotdata$fit[[plotdata$meta$x]],
                      smooth = plotdata$fit$visregFit,
                      lower = plotdata$fit$visregLwr,
                      upper = plotdata$fit$visregUpr);
predicts <- data.frame(Variable = "dim1",
                      x = plotdata$res$Age_Fold0,
                      y = plotdata$res$visregRes)
Fig <- ggplot() + 
       geom_point(data = predicts, aes(x, y), colour = '#99cc99', size = 1.8) + 
       geom_line(data = smooths, aes(x = x, y = smooth), colour = '#99cc99', size = 1.5) + 
       geom_ribbon(data = smooths, aes(x = x, ymin = lower, ymax = upper, fill = "0"), alpha = 0.15)
# Fold 1
Energy_lm <- lm(PredictScore_Fold1 ~ Age_Fold1 + Sex_Fold1 + Handedness_Fold1 + Motion_Fold1 + TBV_Fold1 + TotalStrength_Fold1, data = Behavior_Fold1);
plotdata <- visreg(Energy_lm, "Age_Fold1", type = "conditional", scale = "linear", plot = FALSE);
smooths_Fold1 <- data.frame(Variable = plotdata$meta$x,
                      x = plotdata$fit[[plotdata$meta$x]],
                      smooth = plotdata$fit$visregFit,
                      lower = plotdata$fit$visregLwr,
                      upper = plotdata$fit$visregUpr);
predicts_Fold1 <- data.frame(Variable = "dim1",
                      x = plotdata$res$Age_Fold1,
                      y = plotdata$res$visregRes)
Fig <- Fig + 
       geom_point(data = predicts_Fold1, aes(x, y), colour = '#8892be', size = 1.8) +
       geom_line(data = smooths_Fold1, aes(x = x, y = smooth), colour = '#8892be', size = 1.5) +
       geom_ribbon(data = smooths_Fold1, aes(x = x, ymin = lower, ymax = upper, fill = "0"), alpha = 0.15) +
       theme_classic() + labs(x = "Chronological Age (years)", y = "Brain Maturity Index") + 
       theme(axis.text=element_text(size=25, color='black'), axis.title=element_text(size=30)) + 
       scale_y_continuous(limits = c(8, 23), breaks = c(8, 12, 16, 20)) + 
       scale_fill_manual("", values = "grey12");
Fig
ggsave(paste0(FigureFolder, '/AgePrediction_CorrACC_NS.tiff'), width = 17, height = 15, dpi = 300, units = "cm");
