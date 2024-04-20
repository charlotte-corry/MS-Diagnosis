%% Train, Validate and Test Model

clc
clear
close all

%Load in data
load Summary_Arrays/H_RL_mean_array.mat 
load Summary_Arrays/H_RL_median_array.mat
load Summary_Arrays/MS_RL_mean_array.mat
load Summary_Arrays/MS_RL_median_array.mat
load Summary_Arrays/H_RL_SD_array.mat
load Summary_Arrays/MS_RL_SD_array.mat
load Summary_Arrays/H_RL_IQR_array.mat
load Summary_Arrays/MS_RL_IQR_array.mat
load Summary_Arrays/H_RL_mode_array.mat
load Summary_Arrays/MS_RL_mode_array.mat
load Summary_Arrays/H_RL_range_array.mat
load Summary_Arrays/MS_RL_range_array.mat
load Summary_Arrays/H_RL_kurtosis_array.mat
load Summary_Arrays/MS_RL_kurtosis_array.mat
load Outlier_Arrays/MSOutliers_LOF.mat
load Outlier_Arrays/HealthyOutliers_LOF.mat

%PREPARE DATASET%

%Predictor Data Array
IQR_GCIPL = [H_RL_IQR_array(3,:), MS_RL_IQR_array(3,:)]';
Range_GCIPL = [H_RL_range_array(3,:), MS_RL_range_array(3,:)]';
SD_GCIPL = [H_RL_SD_array(3,:), MS_RL_SD_array(3,:)]';
Mean_GCIPL = [H_RL_mean_array(3,:), MS_RL_mean_array(3,:)]';
Median_RNFL = [H_RL_median_array(2,:), MS_RL_median_array(2,:)]';
Mean_RNFL = [H_RL_mean_array(2,:), MS_RL_mean_array(2,:)]';
Kurtosis_GCIPL = [H_RL_kurtosis_array(3,:), MS_RL_kurtosis_array(3,:)]';
Median_GCIPL = [H_RL_median_array(3,:), MS_RL_median_array(3,:)]';
Range_RPE = [H_RL_range_array(9,:), MS_RL_range_array(9,:)]';
Mode_RPE = [H_RL_mode_array(9,:), MS_RL_mode_array(9,:)]';
Mean_TRT = [H_RL_mean_array(1,:), MS_RL_mean_array(1,:)]';
Median_TRT = [H_RL_median_array(1,:), MS_RL_median_array(1,:)]';

%Different Features Utilised%
% x_withOutliers = [IQR_GCIPL, Range_GCIPL, SD_GCIPL, Mean_GCIPL, Median_RNFL, Mean_RNFL,... 
                 %Kurtosis_GCIPL, Median_GCIPL, Range_RPE, Mode_RPE, Mean_TRT, Median_TRT];
%Chi-2
 x_withOutliers = [IQR_GCIPL, Range_GCIPL, SD_GCIPL, Mean_GCIPL, Median_RNFL,...
                  Mean_RNFL, Kurtosis_GCIPL, Median_GCIPL, Range_RPE, Mode_RPE];
%MRMR
%x_withOutliers = [Range_GCIPL, Mean_GCIPL, Median_RNFL, SD_GCIPL, Mean_TRT, Median_TRT];

%Overlap
%x_withOutliers = [Range_GCIPL, Mean_GCIPL, Median_RNFL, SD_GCIPL];

%Remove Outliers%
Outliers = [HealthyOutliers; MSOutliers]; %Creating Outlier Array
x = x_withOutliers(~Outliers, :);   %Removing Outliers

%Partition Data%
Healthy = x(1:78, :);
MS = x(79:end, :);

rng(40)
rand_H = randperm(78); 
H1 = Healthy(rand_H(1:62), :);
H2 = Healthy(rand_H(63:end), :);

rng(40)
rand_MS = randperm(69);
MS1 = MS(rand_MS(1:55), :);
MS2 = MS(rand_MS(56:end), :);

x1 = [H1; MS1]; %train and validation data
x2 = [H2; MS2]; %test data

%Create Class Labels Array%
y1 = [zeros(62, 1); ones(55, 1)]; %train and validation labels
y2 = [zeros(16, 1); ones(14, 1)]; %test labels

%Shuffle Data%
rng(11)
rand_1 = randperm(117); %training/validating data
x1 = x1(rand_1, :);
y1 = y1(rand_1, :);

rng(17)
rand_2 = randperm(30); %testing data
x2 = x2(rand_2, :);
y2 =y2(rand_2, :);

%K-FOLD CV%

testIdx = zeros(length(x1));
c = cvpartition(y1,'KFold', 4, 'Stratify', true);

C_values = [0.01, 0.1, 1, 10, 100, 1000, 10^4, 10^5, 10^6];
KernelScale_values = [0.01, 0.01, 0.1, 1, 10, 100, 1000, 10^4, 10^5, 10^6];

% C_values = 1000; %Finalised Hyperparamters
% KernelScale_values = 100;

accuracy_array=[];

for j=1:length(KernelScale_values)
    for i=1:length(C_values)
        for fold = 1:4
        
            %Splitting data into folds
            trainIdx = training(c, fold);
            testIdx = test(c, fold);
        
            x_train = x1(trainIdx, :);
            y_train = y1(trainIdx);
        
            x_test = x1(testIdx, :);
            y_test = y1(testIdx);
        
           %TRAIN%

            model = fitcsvm(x_train, y_train, 'KernelFunction','rbf', ... 
                    'BoxConstraint', C_values(i), 'KernelScale', KernelScale_values(j));
            fourmodels{fold} = model;

            %VALIDATE%
            
            result1 = predict (model, x_test); 
            accuracy1(fold) = sum (result1 == y_test)/length (y_test) *100;
        end

        %Evaluate Accuracy%
        averageAccuracy = mean(accuracy1);
        accuracy_matrix(i, j) = averageAccuracy;
        accuracy_array = [accuracy_array; [C_values(i), KernelScale_values(j), averageAccuracy]];

        %Store the Trained Models%
        [max_accuracy1, idx1] = max(accuracy1(:));
        onemodel = fourmodels{idx1};
        models{i, j} = onemodel; %Model from fold with highest validation accuracy
    end
end

%Line 139-150 is not needed once optimum hyperparamters are set%
%Find the best combination of C and KernelScale based on accuracy
[max_accuracy, idx] = max(accuracy_matrix(:));
[best_C_idx, best_KernelScale_idx] = ind2sub(size(accuracy_matrix), idx);

best_C = C_values(best_C_idx);
best_KernelScale = KernelScale_values(best_KernelScale_idx);

disp(['Best C: ', num2str(best_C)]);
disp(['Best KernelScale: ', num2str(best_KernelScale)]);
disp(['Best Accuracy: ', num2str(max_accuracy)]);

best_model = models{best_C_idx, best_KernelScale_idx};

%TEST ON UNSEEN DATA%

result2 = predict (best_model, x2); 
accuracy2 = sum (result2 == y2)/length (y2) *100;

disp(['Final Accuracy: ', num2str(accuracy2)]);

%% Evaluate Performance

figure
confusionchart(y2,result2)

%Extracting TP,TN,FP & FN
mat = confusionmat(y2,result2);
TP = mat(2,2);
TN = mat(1,1);
FP = mat(1,2);
FN = mat(2,1);

%Precision
Precision = TP / (TP + FP)

%Recall (TPR)
Recall = TP / (TP + FN)

%F1 Score
F1Score = (2 * Precision * Recall) / (Precision + Recall)
