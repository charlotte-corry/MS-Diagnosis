%% Detecting Outliers in Mean Array

clear 
clear all
close all

load Summary_Arrays/H_RL_mean_array.mat

%Calculting Contamination Fraction (1.5*IQR)%
layer = (H_RL_mean_array(4,:))'; %Change number in brackets for different retinal layer
IQR = iqr(layer);
q1 = quantile(layer, 0.25);
q3 = quantile(layer, 0.75);
lower_adjacent = q1 - (1.5*IQR);
upper_adjacent = q3 + (1.5*IQR);
outliers = layer(layer < lower_adjacent | layer > upper_adjacent);
NumOutliers = length(outliers);

%LOF algorithm%
CF = (NumOutliers/length(layer)); %Calculating Contimination Fraction%
[LOF, H4, scores] = lof((layer), ContaminationFraction= CF);

%% Combining Outliers in TRT, RNFL, GCIPL and INL

clear
clear all
close all

load Outlier_Arrays/H1_LOF.mat
load Outlier_Arrays/H2_LOF.mat
load Outlier_Arrays/H3_LOF.mat
load Outlier_Arrays/H4_LOF.mat
load Outlier_Arrays/MS1_LOF.mat
load Outlier_Arrays/MS2_LOF.mat
load Outlier_Arrays/MS3_LOF.mat
load Outlier_Arrays/MS4_LOF.mat

HealthyOutliers = bitor(bitor(bitor(H1, H2), H3), H4);
MSOutliers = bitor(bitor(bitor(MS1, MS2), MS3), MS4);
