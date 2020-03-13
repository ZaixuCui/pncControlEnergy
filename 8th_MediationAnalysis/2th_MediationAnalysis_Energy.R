
####################################################
###   Zaixu Cui| Mediation Analysis | 20180921   ###
####################################################

## Install packages
require(lavaan)
require(stats)
require(Formula)
library(mgcv)
library(voxel)
library(knitr)
library(visreg)

## Load in data
Data <- read.csv("/Users/zaixucui/Desktop/DataForMediation.csv")

## Set variables
Data$Sex_factor <- as.factor(Data$Sex_factor)
Data$HandednessV2 <- as.factor(Data$HandednessV2)
age <- Data$AgeYears
ExecutiveEfficiency <- Data$ExecutiveEfficiency

##############################################
## For 157th region: the left mid-cingulate ##
##############################################

Energy_157 <- Data$Energy_157

## Regress covariates out
AgeGam <- gam(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method="REML", data=Data)
AgeResid <- resid(AgeGam)

ExecutiveEfficiencyGam <- gam(ExecutiveEfficiency ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method="REML", data=Data)
ExecutiveEfficiencyResid <- resid(ExecutiveEfficiencyGam)

Energy157Gam <- gam(Energy_157 ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method="REML", data=Data)
Energy157Resid <- resid(Energy157Gam)

tmp <- gam(Energy_157 ~ s(AgeYears, k=4) + ExecutiveEfficiency + Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method="REML", data=Data)

## Standardize independent (X), dependent (Y), and mediating (M) variables
X <- as.data.frame(scale(AgeResid))
Y <- as.data.frame(scale(ExecutiveEfficiencyResid)) 
M <- as.data.frame(scale(Energy157Resid))

Data <- data.frame(X=X, Y=Y, M=M)
Data <- data.frame(cbind(X,Y,M))
colnames(Data) <- c("X", "Y", "M")

# Set model
model <- ' # direct effect
Y ~ c*X
# mediator
M ~ a*X
Y ~ b*M
# indirect effect (a*b)
ab := a*b
# total effect
total := c + (a*b)
'

# Run on model
fit_sem <- sem(model, data = Data, se="bootstrap", bootstrap=10000)
summary(fit_sem, fit.measures=TRUE, standardize=TRUE, rsquare=TRUE)

## Calculate bootstrapped confidence intervals for the indirect (c') effect
boot.fit <- parameterEstimates(fit_sem, boot.ci.type="perc",level=0.95, ci=TRUE,standardized = TRUE)
boot.fit


##############################################
## For 43th region: the right mid-cingulate ##
##############################################

Energy_43 <- Data$Energy_43

## Regress covariates out
AgeGam <- gam(AgeYears ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method="REML", data=Data)
AgeResid <- resid(AgeGam)

ExecutiveEfficiencyGam <- gam(ExecutiveEfficiency ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method="REML", data=Data)
ExecutiveEfficiencyResid <- resid(ExecutiveEfficiencyGam)

Energy43Gam <- gam(Energy_43 ~ Sex_factor + HandednessV2 + MotionMeanRelRMS + TBV + Strength_EigNorm_SubIden, method="REML", data=Data)
Energy43Resid <- resid(Energy43Gam)

## Standardize independent (X), dependent (Y), and mediating (M) variables
X <- as.data.frame(scale(AgeResid))
Y <- as.data.frame(scale(ExecutiveEfficiencyResid)) 
M <- as.data.frame(scale(Energy43Resid))

Data <- data.frame(X=X, Y=Y, M=M)
Data <- data.frame(cbind(X,Y,M))
colnames(Data) <- c("X", "Y", "M")

# Set model
model <- ' # direct effect
Y ~ c*X
# mediator
M ~ a*X
Y ~ b*M
# indirect effect (a*b)
ab := a*b
# total effect
total := c + (a*b)
'

# Run on model
fit_sem <- sem(model, data = Data, se="bootstrap", bootstrap=10000)
summary(fit_sem, fit.measures=TRUE, standardize=TRUE, rsquare=TRUE)

## Calculate bootstrapped confidence intervals for the indirect (c') effect
boot.fit <- parameterEstimates(fit_sem, boot.ci.type="perc",level=0.95, ci=TRUE,standardized = TRUE)
boot.fit
