
clc; clearvars; close all;
addpath(genpath('../src'));

files = {'MS_filenames.txt', 'Healthy_filenames.txt'};
preface = {'MS_Files/', 'Healthy_Files/'};

for i=1:2
    fileListPath = files{i};
    fileNames = textread(fileListPath, '%s', 'delimiter', '\n'); 
    
    RL_mean_array = [];
    RL_median_array = [];
    RL_IQR_array = [];
    RL_interQR_array = [];
    RL_mode_array = [];
    RL_range_array = [];
    RL_SD_array = [];
    RL_kurtosis_array = [];
    RL_skewness_array = [];
    middle_row_array = [];
    
    %CREATING FILENAME%
    for i1= 1:1:length(fileNames)
        f1 = fileNames(i1,:);
        f = [preface{i}, fileNames(i1,:)];
        file = [f{1}, f{2}];
    
     %READING OCT FILE%       
        [header, seg, ~, ~] = read_vol(file, 'get_coordinates');
        
        X = header.X_oct; 
        Y = header.Y_oct; 
            
     %COMPUTING LAYER THICKNESS%
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
        row = row(1); 
    
      %COMPUTING STATISTICAL SUMMARY ARRRAYS%
        for i2=1:1:9
            k = RL(:,:,i2);
            layer_middle = k(row,:); %Selecting middle b scan
            layer_middle(isnan(layer_middle)) = layer_middle(1,3); %%Replaces NaN from middle layer 
                                                                   
            
            layer_mean = mean(layer_middle); %Finding mean thickness of middle b scan
            RL_mean_array(i2,i1) = layer_mean;
    
            layer_median = median(layer_middle); %Finding median thickness of middle b scan
            RL_median_array(i2,i1) = layer_median;

            layer_SD = std(layer_middle); %Finding SD of layer thickness in middle b scan
            RL_SD_array(i2,i1) = layer_SD;
     
        end 
    end
    
    rowNames = {'TRT', 'RNFL', 'GCIPL', 'INL', 'OPL', 'ONL', 'MZ', 'EZOSP', 'RPEcomp'};
    
    Table_meanthickness = array2table(RL_mean_array, 'RowNames', rowNames);
    Table_medianthickness = array2table(RL_median_array, 'RowNames', rowNames);
    Table_SDofthickness = array2table(RL_SD_array, 'RowNames', rowNames);
   
    %EXTRACTING INDIVIDUAL RLs FROM STATISTICAL SUMMARY ARRAYS FOR BOXPLOTS%
    RL_mean_array = RL_mean_array';
    Mean_TRT{i} = RL_mean_array(:, 1);
    Mean_RNFL{i} = RL_mean_array(:, 2);
    Mean_GCIPL{i} = RL_mean_array(:, 3);
    Mean_INL{i} = RL_mean_array(:, 4);
    Mean_OPL{i} = RL_mean_array(:, 5);
    Mean_ONL{i} = RL_mean_array(:, 6);
    Mean_MZ{i} = RL_mean_array(:, 7);
    Mean_EZOSP{i} = RL_mean_array(:, 8);
    Mean_RPEcomp{i} = RL_mean_array(:, 9);

    RL_median_array = RL_median_array';
    Median_TRT{i} = RL_median_array(:, 1);
    Median_RNFL{i} = RL_median_array(:, 2);
    Median_GCIPL{i} = RL_median_array(:, 3);
    Median_INL{i} = RL_median_array(:, 4);
    Median_OPL{i} = RL_median_array(:, 5);
    Median_ONL{i} = RL_median_array(:, 6);
    Median_MZ{i} = RL_median_array(:, 7);
    Median_EZOSP{i} = RL_median_array(:, 8);
    Median_RPEcomp{i} = RL_median_array(:, 9);
   
    RL_SD_array = RL_SD_array';
    SD_TRT{i} = RL_SD_array(:, 1);
    SD_RNFL{i} = RL_SD_array(:, 2);
    SD_GCIPL{i} = RL_SD_array(:, 3);
    SD_INL{i} = RL_SD_array(:, 4);
    SD_OPL{i} = RL_SD_array(:, 5);
    SD_ONL{i} = RL_SD_array(:, 6);
    SD_MZ{i} = RL_SD_array(:, 7);
    SD_EZOSP{i} = RL_SD_array(:, 8);
    SD_RPEcomp{i} = RL_SD_array(:, 9);
end

%CREATING BOXPLOTS IN TERMS OF MEAN%
figure
subplot(3, 3, 1)
x = [Mean_TRT{1}; Mean_TRT{2}];
g = [ones(size(Mean_TRT{1})); 2*ones(size(Mean_TRT{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Mean)')
title('TRT')
[h, p, ci, stats] = ttest2(Mean_TRT{1}, Mean_TRT{2});
annotation('textbox', [0.21, 0.91, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 2)
x = [Mean_RNFL{1}; Mean_RNFL{2}];
g = [ones(size(Mean_RNFL{1})); 2*ones(size(Mean_RNFL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Mean)')
title('RNFL')
[h, p, ci, stats] = ttest2(Mean_RNFL{1}, Mean_RNFL{2});
annotation('textbox', [0.49, 0.91, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 3)
x = [Mean_GCIPL{1}; Mean_GCIPL{2}];
g = [ones(size(Mean_GCIPL{1})); 2*ones(size(Mean_GCIPL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Mean)')
title('GCIPL')
[h, p, ci, stats] = ttest2(Mean_GCIPL{1}, Mean_GCIPL{2});
annotation('textbox', [0.77, 0.91, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 4)
x = [Mean_INL{1}; Mean_INL{2}];
g = [ones(size(Mean_INL{1})); 2*ones(size(Mean_INL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Mean)')
title('INL')
[h, p, ci, stats] = ttest2(Mean_INL{1}, Mean_INL{2});
annotation('textbox', [0.21, 0.6, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 5)
x = [Mean_OPL{1}; Mean_OPL{2}];
g = [ones(size(Mean_OPL{1})); 2*ones(size(Mean_OPL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Mean)')
title('OPL')
[h, p, ci, stats] = ttest2(Mean_OPL{1}, Mean_OPL{2});
annotation('textbox', [0.49, 0.6, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 6)
x = [Mean_ONL{1}; Mean_ONL{2}];
g = [ones(size(Mean_ONL{1})); 2*ones(size(Mean_ONL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Mean)')
title('ONL')
[h, p, ci, stats] = ttest2(Mean_ONL{1}, Mean_ONL{2});
annotation('textbox', [0.77, 0.6, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 7)
x = [Mean_MZ{1}; Mean_MZ{2}];
g = [ones(size(Mean_MZ{1})); 2*ones(size(Mean_MZ{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Mean)')
title('MZ')
[h, p, ci, stats] = ttest2(Mean_MZ{1}, Mean_MZ{2});
annotation('textbox', [0.21, 0.3, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 8)
x = [Mean_EZOSP{1}; Mean_EZOSP{2}];
g = [ones(size(Mean_EZOSP{1})); 2*ones(size(Mean_EZOSP{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Mean)')
title('EZOSP')
[h, p, ci, stats] = ttest2(Mean_EZOSP{1}, Mean_EZOSP{2});
annotation('textbox', [0.49, 0.3, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 9)
x = [Mean_RPEcomp{1}; Mean_RPEcomp{2}];
g = [ones(size(Mean_RPEcomp{1})); 2*ones(size(Mean_RPEcomp{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Mean)')
title('RPEcomp')
[h, p, ci, stats] = ttest2(Mean_RPEcomp{1}, Mean_RPEcomp{2});
annotation('textbox', [0.77, 0.3, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

%CREATING BOXPLOTS IN TERMS OF MEDIAN%
figure
subplot(3, 3, 1)
x = [Median_TRT{1}; Median_TRT{2}];
g = [ones(size(Median_TRT{1})); 2*ones(size(Median_TRT{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Median)')
title('TRT')
[h, p, ci, stats] = ttest2(Median_TRT{1}, Median_TRT{2});
annotation('textbox', [0.21, 0.91, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 2)
x = [Median_RNFL{1}; Median_RNFL{2}];
g = [ones(size(Median_RNFL{1})); 2*ones(size(Median_RNFL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Median)')
title('RNFL')
[h, p, ci, stats] = ttest2(Median_RNFL{1}, Median_RNFL{2});
annotation('textbox', [0.49, 0.91, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 3)
x = [Median_GCIPL{1}; Median_GCIPL{2}];
g = [ones(size(Median_GCIPL{1})); 2*ones(size(Median_GCIPL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Median)')
title('GCIPL')
[h, p, ci, stats] = ttest2(Median_GCIPL{1}, Median_GCIPL{2});
annotation('textbox', [0.77, 0.91, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 4)
x = [Median_INL{1}; Median_INL{2}];
g = [ones(size(Median_INL{1})); 2*ones(size(Median_INL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Median)')
title('INL')
[h, p, ci, stats] = ttest2(Median_INL{1}, Median_INL{2});
annotation('textbox', [0.21, 0.6, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 5)
x = [Median_OPL{1}; Median_OPL{2}];
g = [ones(size(Median_OPL{1})); 2*ones(size(Median_OPL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Median)')
title('OPL')
[h, p, ci, stats] = ttest2(Median_OPL{1}, Median_OPL{2});
annotation('textbox', [0.49, 0.6, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 6)
x = [Median_ONL{1}; Median_ONL{2}];
g = [ones(size(Median_ONL{1})); 2*ones(size(Median_ONL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Median)')
title('ONL')
[h, p, ci, stats] = ttest2(Median_ONL{1}, Median_ONL{2});
annotation('textbox', [0.77, 0.6, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 7)
x = [Median_MZ{1}; Median_MZ{2}];
g = [ones(size(Median_MZ{1})); 2*ones(size(Median_MZ{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Median)')
title('MZ')
[h, p, ci, stats] = ttest2(Median_MZ{1}, Median_MZ{2});
annotation('textbox', [0.21, 0.3, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 8)
x = [Median_EZOSP{1}; Median_EZOSP{2}];
g = [ones(size(Median_EZOSP{1})); 2*ones(size(Median_EZOSP{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Median)')
title('EZOSP')
[h, p, ci, stats] = ttest2(Median_EZOSP{1}, Median_EZOSP{2});
annotation('textbox', [0.49, 0.3, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 9)
x = [Median_RPEcomp{1}; Median_RPEcomp{2}];
g = [ones(size(Median_RPEcomp{1})); 2*ones(size(Median_RPEcomp{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (Median)')
title('RPEcomp')
[h, p, ci, stats] = ttest2(Median_RPEcomp{1}, Median_RPEcomp{2});
annotation('textbox', [0.77, 0.3, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

%CREATING BOXPLOTS IN TERMS OF SD%
figure
subplot(3, 3, 1)
x = [SD_TRT{1}; SD_TRT{2}];
g = [ones(size(SD_TRT{1})); 2*ones(size(SD_TRT{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (SD)')
title('TRT')
[h, p, ci, stats] = ttest2(SD_TRT{1}, SD_TRT{2});
annotation('textbox', [0.21, 0.91, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 2)
x = [SD_RNFL{1}; SD_RNFL{2}];
g = [ones(size(SD_RNFL{1})); 2*ones(size(SD_RNFL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (SD)')
title('RNFL')
[h, p, ci, stats] = ttest2(SD_RNFL{1}, SD_RNFL{2});
annotation('textbox', [0.49, 0.91, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 3)
x = [SD_GCIPL{1}; SD_GCIPL{2}];
g = [ones(size(SD_GCIPL{1})); 2*ones(size(SD_GCIPL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (SD)')
title('GCIPL')
[h, p, ci, stats] = ttest2(SD_GCIPL{1}, SD_GCIPL{2});
annotation('textbox', [0.77, 0.91, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 4)
x = [SD_INL{1}; SD_INL{2}];
g = [ones(size(SD_INL{1})); 2*ones(size(SD_INL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (SD)')
title('INL')
[h, p, ci, stats] = ttest2(SD_INL{1}, SD_INL{2});
annotation('textbox', [0.21, 0.6, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 5)
x = [SD_OPL{1}; SD_OPL{2}];
g = [ones(size(SD_OPL{1})); 2*ones(size(SD_OPL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (SD)')
title('OPL')
[h, p, ci, stats] = ttest2(SD_OPL{1}, SD_OPL{2});
annotation('textbox', [0.49, 0.6, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 6)
x = [SD_ONL{1}; SD_ONL{2}];
g = [ones(size(SD_ONL{1})); 2*ones(size(SD_ONL{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (SD)')
title('ONL')
[h, p, ci, stats] = ttest2(SD_ONL{1}, SD_ONL{2});
annotation('textbox', [0.77, 0.6, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 7)
x = [SD_MZ{1}; SD_MZ{2}];
g = [ones(size(SD_MZ{1})); 2*ones(size(SD_MZ{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (SD)')
title('MZ')
[h, p, ci, stats] = ttest2(SD_MZ{1}, SD_MZ{2});
annotation('textbox', [0.21, 0.3, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 8)
x = [SD_EZOSP{1}; SD_EZOSP{2}];
g = [ones(size(SD_EZOSP{1})); 2*ones(size(SD_EZOSP{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (SD)')
title('EZOSP')
[h, p, ci, stats] = ttest2(SD_EZOSP{1}, SD_EZOSP{2});
annotation('textbox', [0.49, 0.3, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

subplot(3, 3, 9)
x = [SD_RPEcomp{1}; SD_RPEcomp{2}];
g = [ones(size(SD_RPEcomp{1})); 2*ones(size(SD_RPEcomp{2}))];
boxplot(x, g, 'Labels', {'MS', 'Healthy'})
ylabel('Layer Thickness (SD)')
title('RPEcomp')
[h, p, ci, stats] = ttest2(SD_RPEcomp{1}, SD_RPEcomp{2});
annotation('textbox', [0.77, 0.3, 0.1, 0], 'String', sprintf('p = %.4f', p), 'EdgeColor', 'none', 'FontSize', 11);

