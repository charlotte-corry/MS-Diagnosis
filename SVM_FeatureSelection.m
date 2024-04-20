%% Preparing Dataset

clc
clear 
close all

load Summary_Arrays/H_RL_mean_array.mat %load in data
load Summary_Arrays/H_RL_median_array.mat
load Summary_Arrays/MS_RL_mean_array.mat
load Summary_Arrays/MS_RL_median_array.mat
load Summary_Arrays/H_RL_SD_array.mat
load Summary_Arrays/MS_RL_SD_array.mat
load Summary_Arrays/H_RL_skewness_array.mat
load Summary_Arrays/MS_RL_skewness_array.mat
load Summary_Arrays/H_RL_range_array.mat
load Summary_Arrays/H_RL_mode_array.mat
load Summary_Arrays/H_RL_IQR_array.mat
load Summary_Arrays/H_RL_kurtosis_array.mat
load Summary_Arrays/MS_RL_range_array.mat
load Summary_Arrays/MS_RL_mode_array.mat
load Summary_Arrays/MS_RL_IQR_array.mat
load Summary_Arrays/MS_RL_kurtosis_array.mat
load Outlier_Arrays/MSOutliers_LOF.mat
load Outlier_Arrays/HealthyOutliers_LOF.mat

mean_array = [H_RL_mean_array, MS_RL_mean_array]';
median_array = [H_RL_median_array, MS_RL_median_array]';
SD_array = [H_RL_SD_array, MS_RL_SD_array]';
range_array = [H_RL_range_array, MS_RL_range_array]';
mode_array = [H_RL_mode_array, MS_RL_mode_array]';
IQR_array = [H_RL_IQR_array, MS_RL_IQR_array]';
skewness_array = [H_RL_skewness_array, MS_RL_skewness_array]';
kurtosis_array = [H_RL_kurtosis_array, MS_RL_kurtosis_array]';

X_withOutliers = [mean_array, median_array, SD_array, range_array, ...
                  mode_array, IQR_array, skewness_array, kurtosis_array]; 

Outliers = [HealthyOutliers; MSOutliers]; %Creating Outlier Array
X = X_withOutliers(~Outliers, :);   %Removing Outliers     

Column_Labels = {'MeanTRT', 'MeanRNFL', 'MeanGCIPL', 'MeanINL', 'MeanOPL',...
                 'MeanONL', 'MeanMZ', 'MeanEZOSP', 'MeanRPEcomp',...
                 'MedianTRT', 'MedianRNFL', 'MedianGCIPL', 'MedianINL', 'MedianOPL',...
                 'MedianONL', 'MedianMZ', 'MedianEZOSP', 'MedianRPEcomp',...
                 'SD TRT', 'SD RNFL', 'SD GCIPL', 'SD INL', 'SD OPL',...
                 'SD ONL', 'SD MZ', 'SD EZOSP', 'SD RPEcomp',...
                 'rangeTRT', 'rangeRNFL', 'rangeGCIPL', 'rangeINL', 'rangeOPL',...
                 'rangeONL', 'rangeMZ', 'rangeEZOSP', 'rangeRPEcomp',...
                 'modeTRT', 'modeRNFL', 'modeGCIPL', 'modeINL', 'modeOPL',...
                 'modeONL', 'modeMZ', 'modeEZOSP', 'modeRPEcomp',...
                 'IQR TRT', 'IQR RNFL', 'IQR GCIPL', 'IQR INL', 'IQR OPL',... 
                 'IQR ONL', 'IQR MZ', 'IQR EZOSP', 'IQR RPEcomp',...
                 'skewTRT', 'skewRNFL', 'skewGCIPL', 'skewINL', 'skewOPL',...
                 'skewONL', 'skewMZ', 'skewEZOSP', 'skewRPEcomp',...
                 'kurtTRT', 'kurtRNFL', 'kurtGCIPL', 'kurtINL', 'kurtOPL',...
                 'kurtONL', 'kurtMZ', 'kurtEZOSP', 'kurtRPEcomp'};

Tbl = array2table(X, 'VariableNames', Column_Labels);

Y = [zeros(78, 1); ones(69, 1)]; %Class labels array (0 = H, 1 = MS)

%% Chi-Square Tests

[idx,scores] = fscchi2(Tbl,Y);

bar(scores(idx))
xlabel('Predictor rank')
ylabel('Predictor importance score')

%Extracting and displaying best features
top10 = idx(1:10);
BestFeatures = Tbl.Properties.VariableNames(top10);
disp(BestFeatures)

%% Minimum Redundancy Maximum Relevance Algorithm

[idx,scores] = fscmrmr(Tbl,Y);

bar(scores(idx))
xlabel('Predictor rank')
ylabel('Predictor importance score')

%Extracting and displaying best features
top10 = idx(1:10);
BestFeatures = Tbl.Properties.VariableNames(top10);
disp(BestFeatures)


