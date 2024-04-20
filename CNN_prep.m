%% MS OCT Scans- Feature Extraction and Pre-Processing

clc; clearvars; close all;
addpath(genpath('../src'));

fileListPath = 'MS_filenames.txt';
fileNames = textread(fileListPath, '%s', 'delimiter', '\n'); 
Eye_array = [];

%CREATING FILENAME%
 for i1= 1:1:length(fileNames)
    f1 = fileNames(i1,:);
    f = ['MS_Files/', fileNames(i1,:)];
    file = [f{1}, f{2}];

%READING FILE% 
    [header, seg, ~, ~] = read_vol(file, 'get_coordinates');
    X = header.X_oct; 
    Y = header.Y_oct; 
  %Denotes Left or Right Eye
    Eye = header.eye;

    if Eye == 'OD'  %Ensures Eye Array is double rather than character
       Eye_LR = 1;
    elseif Eye == 'OS'
        Eye_LR = 0;
    end

    Eye_array = [Eye_array; Eye_LR];
    
%COMPUTING TRT ARRAY%
    layers = {'TRT', 'RNFL', 'GCIPL', 'INL', 'OPL', 'ONL', 'MZ', 'EZOSP', 'RPEcomp'}; %Need to specify which layers to compute           
    
    Thickness = compute_thickness(seg, layers, header.scale_z);
    
    TRT = Thickness.TRT;
    RNFL = Thickness.RNFL;
    GCIPL = Thickness.GCIPL;
    INL = Thickness.INL;
    OPL = Thickness.OPL;
    ONL = Thickness.ONL;
    MZ = Thickness.MZ;
    EZOSP = Thickness.EZOSP;
    RPEcomp = Thickness.RPEcomp;
    
    RL = TRT;  %creating a 3D matrix
    RL(:,:,2) = RNFL;
    RL(:,:,3) = GCIPL;
    RL(:,:,4) = INL;
    RL(:,:,5) = OPL;
    RL(:,:,6) = ONL;
    RL(:,:,7) = MZ;
    RL(:,:,8) = EZOSP;
    RL(:,:,9) = RPEcomp;

%EXTRACTING MIDDLE B-SCAN%
    total_rows = size(TRT, 1);
    
    middle_third_start = floor(total_rows / 3) + 1;
    middle_third_end = 2 * floor(total_rows / 3);
    middle_third = TRT(middle_third_start:middle_third_end, :);
    
    min_value = min(middle_third(:));
    [row, col] = find(middle_third == min_value);
    row = (row + middle_third_start)-1;
    row = row(1); %Location of middle b-scan

    for i2=1:1:9
        k = RL(:,:,i2);
        Thickness_Signal = k(row,:); %Extracting thickness signal for middle b-scan

    %MIRROR TRT SIGNALS FOR LEFT EYE%
        if Eye_LR == 0
            Thickness_Signal1 = flip(Thickness_Signal);
        elseif Eye_LR ==1
            Thickness_Signal1 = Thickness_Signal;
        end
    
    %COMBINE TRT SIGNALS FROM ALL OCT SCANS INTO CELL ARRAY% 
        MS_Thickness_Signal{i1,i2} = Thickness_Signal1; %All scans are equivalent to right eye
    end

 end

 MS_TRTsignal = MS_Thickness_Signal(:, 1);

%% HC OCT Scans- Feature Extraction and Pre-Processing

clc; clearvars; close all;
addpath(genpath('../src'));

fileListPath = 'Healthy_filenames.txt';
fileNames = textread(fileListPath, '%s', 'delimiter', '\n');  % Use textread to read the filenames from the text file

Eye_array = [];

%CREATING FILENAME%
 for i1= 1:1:length(fileNames)
    f1 = fileNames(i1,:);
    f = ['Healthy_Files/', fileNames(i1,:)];
    file = [f{1}, f{2}];

%READING FILE%  
    [header, seg, ~, ~] = read_vol(file, 'get_coordinates');
    X = header.X_oct; 
    Y = header.Y_oct; 
%DENOTES Left or Right Eye
    Eye = header.eye;
    
    if Eye == 'OD'  %Ensures Eye Array is double rather than character
       Eye_LR = 1;
    elseif Eye == 'OS'
        Eye_LR = 0;
    end
   
    Eye_array = [Eye_array; Eye_LR];

%COMPUTING TRT ARRAY%
    layers = {'TRT', 'RNFL', 'GCIPL', 'INL', 'OPL', 'ONL', 'MZ', 'EZOSP', 'RPEcomp'}; %Need to specify which layers to compute           
    
    Thickness = compute_thickness(seg, layers, header.scale_z);
    
    TRT = Thickness.TRT;
    RNFL = Thickness.RNFL;
    GCIPL = Thickness.GCIPL;
    INL = Thickness.INL;
    OPL = Thickness.OPL;
    ONL = Thickness.ONL;
    MZ = Thickness.MZ;
    EZOSP = Thickness.EZOSP;
    RPEcomp = Thickness.RPEcomp;
    
    RL = TRT;  %creating a 3D matrix
    RL(:,:,2) = RNFL;
    RL(:,:,3) = GCIPL;
    RL(:,:,4) = INL;
    RL(:,:,5) = OPL;
    RL(:,:,6) = ONL;
    RL(:,:,7) = MZ;
    RL(:,:,8) = EZOSP;
    RL(:,:,9) = RPEcomp;

%EXTRACTING MIDDLE B-SCAN%
    total_rows = size(TRT, 1);
    
    middle_third_start = floor(total_rows / 3) + 1;
    middle_third_end = 2 * floor(total_rows / 3);
    middle_third = TRT(middle_third_start:middle_third_end, :);
    
    min_value = min(middle_third(:));
    [row, col] = find(middle_third == min_value);
    row = (row + middle_third_start)-1;
    row = row(1); %Location of middle b-scan   

    for i2=1:1:9
        k = RL(:,:,i2);
        Thickness_Signal = k(row,:); %Extracting thickness signal for middle b-scan
        Thickness_Signal(isnan(Thickness_Signal)) = Thickness_Signal(1,3); %Replaces any NaNs in middle b-scan
                                                             
        
    %MIRROR TRT SIGNAL FOR LEFT EYES%
        if Eye_LR == 0
            Thickness_Signal1 = flip(Thickness_Signal);
        elseif Eye_LR ==1
            Thickness_Signal1 = Thickness_Signal;
        end

    %COMBINE TRT SIGNALS FROM ALL OCT SCANS INTO CELL ARRAY% 
        H_Thickness_Signal{i1,i2} = Thickness_Signal1; %All scans are equivalent to right eye
    end
    
 end

  H_TRTsignal = H_Thickness_Signal(:, 1);

%% Normalising & Standardising- MS and HC

clc
clear all
close all

load Summary_Arrays/MS_signal.mat %Save TRT signals from each section above and load in here
load Summary_Arrays/H_signal.mat

%COMBINING MS AND HEALTHY FILES%
Signal = [H_Thickness_Signal; MS_Thickness_Signal];

%TRANFROMING CELL ARRAY TO DOUBLE ARRAY WHICH INCLUDES NANs%
TRTsignal = Signal(:, 1);
nan_array = NaN(150,600);

for i3=1:150
    len = length(TRTsignal{i3});
    nan_array(i3,1:len) = TRTsignal{i3};
end

%CALCULATING MEAN, SD, MIN AND MAX OF DATA%
nan_mean = mean(nan_array,'all','omitmissing');
nan_std = std(nan_array,0,'all','omitmissing');
nan_max = max(nan_array,[],'all');
nan_min = min(nan_array,[],'all');

%CREATING THE STANDARDISED AND NORMALISED CELL ARRAYS%
for i4=1:150
    TRTsignal_stand{i4} = (TRTsignal{i4} - nan_mean)/nan_std;
    TRT_stand = TRTsignal_stand';
    TRTsignal_norm{i4} = (TRTsignal{i4} - nan_min)/(nan_max-nan_min);
    TRT_norm = TRTsignal_norm';
end

