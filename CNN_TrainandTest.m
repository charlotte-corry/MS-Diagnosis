%% Train and Validate Network

clc 
clear all
close all

%load Summary_Arrays/TRT_norm.mat
load Summary_Arrays/TRT_stand.mat %load in standardised TRT signal array

data = TRT_stand; %swap out what data is entering the CNN

%PREPARE DATA%

%Partition Data 
Healthy = data(1:80, :);
MS = data(81:end, :);

rand_H = randperm(80); %Partition Healthy Data
H1 = Healthy(rand_H(1:72), :); %train and validation data
H2 = Healthy(rand_H(73:80), :); %test data

rand_MS = randperm(70); %Partition MS Data
MS1 = MS(rand_MS(1:63), :); %train and validation data
MS2 = MS(rand_MS(64:70), :); %test data

X1 = [H1; MS1]; %train and validation data
X2 = [H2; MS2]; %test data

%Create Class Label Arrays
Hl = repmat({'Healthy'}, 80, 1);
Hlabels = categorical(Hl);

MSl = repmat({'MS'}, 70, 1);
MSlabels = categorical(MSl);

T1 = [Hlabels(1:72); MSlabels(1:63)];
T2 = [Hlabels(73:80); MSlabels(64:70)];

%Shuffle Data
rand_1 = randperm(135); %Train and validation data
X1 = X1(rand_1);
T1 = T1(rand_1);

rand_2 = randperm(15); %Test Data
XTest = X2(rand_2, :);
TTest = T2(rand_2, :);

%K-FOLD CV%

c = cvpartition(T1,'KFold', 10, 'Stratify', true);
for fold = 1:10
        
            %Splitting data into folds
            trainIdx = training(c, fold);
            testIdx = test(c, fold);
        
            XTrain = X1(trainIdx, :);
            TTrain = T1(trainIdx);
        
            XValidation = X1(testIdx, :);
            TValidation = T1(testIdx);

            %DEFINE NETWORK LAYERS

            filterSize = 8;
            numFeatures = size(XTrain{1},1);
            numClasses = 2;
            
    layers = [ ...
        sequenceInputLayer(numFeatures)
        convolution1dLayer(filterSize,64,Padding="causal")
        reluLayer
        batchNormalizationLayer
        convolution1dLayer(filterSize,32,Padding="causal")
        reluLayer
        batchNormalizationLayer
        globalAveragePooling1dLayer
        fullyConnectedLayer(64)
        fullyConnectedLayer(numClasses)
        softmaxLayer
        classificationLayer];

            
            %DEFINE TRAINING OPTIONS

            miniBatchSize = 30;
            
            options = trainingOptions("adam", ...
                MaxEpochs=600, ...
                InitialLearnRate=0.001, ...
                SequencePaddingDirection="left", ...
                ValidationData={XValidation,TValidation}, ...
                Plots="training-progress", ...
                Verbose=0, ...
                ValidationFrequency = 10, ...
                OutputNetwork="best-validation-loss");              

        %TRAIN NETWORK

        [net, info] = trainNetwork(XTrain,TTrain,layers,options);

        %Store Validation Accuracies
        maxacc = max(info.ValidationAccuracy);
        ValAcc(fold) = maxacc; %check stored network is from epoch with highest acc
        ValAcc_final(fold) = info.FinalValidationAccuracy;
        ValLoss_final(fold) = info.FinalValidationLoss;

        %Store the trained networks
        networks(fold) = net; %stores network from epoch with highest acc within the fold

end 

%Average Validation Accuracy
ValidationAccuracy = mean(ValAcc);

%% Test Network and Evaluate Perfromance

%Finding the best network from fold with highest acc
[max_accuracy, idx] = max(ValAcc);
BestNetwork = networks(1,idx);

%TEST NETWORK%

[YTest, scores] = classify(BestNetwork, XTest, SequencePaddingDirection="left");

%EVALUATE PERFORMANCE%

%Accuracy
acc = mean(YTest == TTest) * 100;

%Confusion Matrix
figure
confusionchart(TTest,YTest)

%Extracting TP,TN,FP & FN
mat = confusionmat(TTest,YTest);
TP = mat(2,2);
TN = mat(1,1);
FP = mat(1,2);
FN = mat(2,1);

%Precision
Precision = TP / (TP + FP);

%Recall (TPR)
Recall = TP / (TP + FN);

%F1 Score
F1Score = (2 * Precision * Recall) / (Precision + Recall);

%1-Specificity (FPR)
FPR = FP / (FP + TN);

%% ROC Curve

ClassNamesMS = {'MS'};
ClassNamesMS = categorical(ClassNamesMS);
scoresMS = scores(:,2);
ROC = rocmetrics(TTest,scoresMS,ClassNamesMS);

figure
plot (ROC)
set(gca,'FontSize',14)
set(gcf,'Color','w');


