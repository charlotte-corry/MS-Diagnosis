%% MS OCT Scans- Feature Extraction and Pre-Processing

clc; clearvars; close all;
addpath(genpath('../src'));

fileListPath = 'MS_filenames.txt';
fileNames = textread(fileListPath, '%s', 'delimiter', '\n');  % Use textread to read the filenames from the text file

MS_RL_mean_array = [];
MS_RL_median_array = [];
MS_RL_IQR_array = [];
MS_RL_interQR_array = [];
MS_RL_mode_array = [];
MS_RL_range_array = [];
MS_RL_SD_array = [];
MS_RL_kurtosis_array = [];
MS_RL_skewness_array = [];
middle_row_array = [];

%CREATING FILENAME%
for i1= 1:1:length(fileNames)
    f1 = fileNames(i1,:);
    f = ['MS_Files/', fileNames(i1,:)];
    file = [f{1}, f{2}];

 %READING OCT FILE%       
    [header, seg, ~, ~] = read_vol(file, 'get_coordinates');
    
    X = header.X_oct; 
    Y = header.Y_oct; 
    %disp(fields(seg)')  % check which segmented boundaries are present in the file
        
 %COMPUTING RETINAL LAYERS' THICKNESSES%
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

%FINDING MIDDLE B-SCAN%
    total_rows = size(TRT, 1);
    middle_third_start = floor(total_rows / 3) + 1;
    middle_third_end = 2 * floor(total_rows / 3);
    middle_third = TRT(middle_third_start:middle_third_end, :);
    min_value = min(middle_third(:));
    [row, col] = find(middle_third == min_value);
    row = (row + middle_third_start)-1;
    row = row(1); %remove if analysing new files

  %EXTRACTING MIDDLE B-SCAN, REDUCING THICKNESS VALUES TO STATISTICAL SUMMARIES%
  %AND FORMING STATISTICAL SUMMARY ARRAYS%
    for i2=1:1:9
        k = RL(:,:,i2);
        layer_middle = k(row,:); %Selecting middle b scan
        
        layer_mean = mean(layer_middle); %Finding mean thickness of middle b scan
        MS_RL_mean_array(i2,i1) = layer_mean;

        layer_median = median(layer_middle); %Finding median thickness of middle b scan
        MS_RL_median_array(i2,i1) = layer_median;

        layer_IQR = iqr(layer_middle); %Finding IQR of layer thickness in middle b scan
        MS_RL_IQR_array(i2,i1) = layer_IQR;

        layer_mode = mode(layer_middle); %Finding mode thickness of middle b scan
        MS_RL_mode_array(i2,i1) = layer_mode;

        layer_range = max(layer_middle) - min(layer_middle); %Finding range of layer thickness in middle b scan
        MS_RL_range_array(i2,i1) = layer_range;
        
        layer_SD = std(layer_middle); %Finding SD of layer thickness in middle b scan
        MS_RL_SD_array(i2,i1) = layer_SD;

        layer_kurtosis = kurtosis(layer_middle); %Finding kurtosis of layer thickness in middle b scan
        MS_RL_kurtosis_array(i2,i1) = layer_kurtosis;

        layer_skewness = skewness(layer_middle); %Finding skewness of layer thickness in middle b scan
        MS_RL_skewness_array(i2,i1) = layer_skewness;
        
        middle_row_array(i2,i1) = row;   
    end 
end


%CONVERTING STATISTICAL SUMMARY ARRAYS TO TABLES%
rowNames = {'TRT', 'RNFL', 'GCIPL', 'INL', 'OPL', 'ONL', 'MZ', 'EZOSP', 'RPEcomp'};

Table_meanthickness = array2table(MS_RL_mean_array, 'RowNames', rowNames);
Table_medianthickness = array2table(MS_RL_median_array, 'RowNames', rowNames);
Table_IQRofthickness = array2table(MS_RL_IQR_array, 'RowNames', rowNames);
Table_modethickness = array2table(MS_RL_mode_array, 'RowNames', rowNames);
Table_rangeofthickness = array2table(MS_RL_range_array, 'RowNames', rowNames);
Table_SDofthickness = array2table(MS_RL_SD_array, 'RowNames', rowNames);
Table_kurtosisofthickness = array2table(MS_RL_kurtosis_array, 'RowNames', rowNames);
Table_skewnessofthickness = array2table(MS_RL_skewness_array, 'RowNames', rowNames);
Table_middlerow = array2table(middle_row_array, 'RowNames', rowNames);

%% HC OCT Scans- Feature Extraction and Pre-Processing

clc; clearvars; close all;
addpath(genpath('../src'));

fileListPath = 'Healthy_filenames.txt';
fileNames = textread(fileListPath, '%s', 'delimiter', '\n');  % Use textread to read the filenames from the text file

H_RL_mean_array = [];
H_RL_median_array = [];
H_RL_IQR_array = [];
H_RL_interQR_array = [];
H_RL_mode_array = [];
H_RL_range_array = [];
H_RL_SD_array = [];
H_RL_kurtosis_array = [];
H_RL_skewness_array = [];
middle_row_array = [];

%CREATING FILENAME%
for i1=1:1:length(fileNames)
    f1 = fileNames(i1,:);
    f = ['Healthy_Files/', fileNames(i1,:)];
    file = [f{1}, f{2}];

 %READING OCT FILE%       
    [header, seg, ~, ~] = read_vol(file, 'get_coordinates');
    
    X = header.X_oct; 
    Y = header.Y_oct; 
    %disp(fields(seg)')  % check which segmented boundaries are present in the file
        
%COMPUTING RETINAL LAYERS' THICKNESSES%
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

  %FINDING MIDDLE B-SCAN%
    total_rows = size(TRT, 1);
    middle_third_start = floor(total_rows / 3) + 1;
    middle_third_end = 2 * floor(total_rows / 3);
    middle_third = TRT(middle_third_start:middle_third_end, :);
    min_value = min(middle_third(:));
    [row, col] = find(middle_third == min_value);
    row = (row + middle_third_start)-1;

  %EXTRACTING MIDDLE B-SCAN, REDUCING THICKNESSES TO STATISTICAL SUMMARIES%
  %AND FORMING STATISTICAL SUMMARY ARRAYS%
    for i2=1:1:9
        k = RL(:,:,i2);
        layer_middle = k(row,:); %Selecting middle b scan
        layer_middle(isnan(layer_middle)) = layer_middle(1,3); %Replaces missing values from middle layer 
                                                               %edit if analysing new files                                                                    
                                                                                                                                                                                                                              
        layer_mean = mean(layer_middle); %Finding mean thickness of middle b scan
        H_RL_mean_array(i2,i1) = layer_mean;

        layer_median = median(layer_middle); %Finding median thickness of middle b scan
        H_RL_median_array(i2,i1) = layer_median;

        layer_IQR = iqr(layer_middle); %Finding IQR of layer thickness in middle b scan
        H_RL_IQR_array(i2,i1) = layer_IQR;
        
        layer_mode = mode(layer_middle); %Finding mode thickness of middle b scan
        H_RL_mode_array(i2,i1) = layer_mode;

        layer_range = max(layer_middle) - min(layer_middle); %Finding range of layer thickness in middle b scan
        H_RL_range_array(i2,i1) = layer_range;
        
        layer_SD = std(layer_middle); %Finding SD of layer thickness in middle b scan
        H_RL_SD_array(i2,i1) = layer_SD;

        layer_kurtosis = kurtosis(layer_middle); %Finding kurtosis of layer thickness in middle b scan
        H_RL_kurtosis_array(i2,i1) = layer_kurtosis;

        layer_skewness = skewness(layer_middle); %Finding skewness of layer thickness in middle b scan
        H_RL_skewness_array(i2,i1) = layer_skewness;
        
        middle_row_array(i2,i1) = row;     
    end  
end

%CONVERTING STATISTICAL SUMMARY ARRAYS TO TABLES%
rowNames= {'TRT', 'RNFL', 'GCIPL', 'INL', 'OPL', 'ONL', 'MZ', 'EZOSP', 'RPEcomp'};

Table_meanthickness = array2table(H_RL_mean_array, 'RowNames', rowNames);
Table_medianthickness = array2table(H_RL_median_array, 'RowNames', rowNames);
Table_IQRofthickness = array2table(H_RL_IQR_array, 'RowNames', rowNames);
Table_modethickness = array2table(H_RL_mode_array, 'RowNames', rowNames);
Table_rangeofthickness = array2table(H_RL_range_array, 'RowNames', rowNames);
Table_SDofthickness = array2table(H_RL_SD_array, 'RowNames', rowNames);
Table_kurtosisofthickness = array2table(H_RL_kurtosis_array, 'RowNames', rowNames);
Table_skewnessofthickness = array2table(H_RL_skewness_array, 'RowNames', rowNames);
Table_middlerow = array2table(middle_row_array, 'RowNames', rowNames);

