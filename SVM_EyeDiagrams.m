
clc; clearvars; close all;
addpath(genpath('../src'));

fileListPath = 'MS_filenames.txt';
fileNames = textread(fileListPath, '%s', 'delimiter', '\n'); 

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
i1= 23;
f1 = fileNames(i1,:);
f = ['MS_Files/', fileNames(i1,:)];
file = [f{1}, f{2}];

 %READING OCT FILE%       
[header, seg, bscan, fundus] = read_vol(file, 'get_coordinates');

boundaries = fields(seg);

X = header.X_oct; 
Y = header.Y_oct; 

%FUNDUS IMAGE%
f = figure;
imagesc(fundus); colormap(gray); axis("off");

%MIDDLE B_SCAN%
f = figure;
idx_bscan = 25;
imshow(bscan(:,:,idx_bscan)); hold on;
for j=1:length(boundaries)
    plot(seg.(boundaries{j})(idx_bscan, :))
end
lgd = legend(boundaries);
fontsize(lgd,12,'points')
