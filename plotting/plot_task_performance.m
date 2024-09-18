%bar plot of task performance

clear; close all; clc;

addpath('D:\stepping_data_opm') %github dir
save_dir='D:\STEPPING\stepping paper\Sci data paper';
cd(save_dir)

fileNames = {'Sub00054_step_error.mat', 'Sub00061_step_error.mat', 'Sub00159_step_error.mat'};

means = zeros(1, length(fileNames)); 
stdDevs = zeros(1, length(fileNames)); 

for i = 1:length(fileNames)
    data = load(fileNames{i}); 
    means(i) = mean(data.y_error(:)); 
    stdDevs(i) = std(data.y_error(:)); 
end

barcolor=linspecer(5);

% Plot
figure;
bar(means, 'FaceColor', barcolor(2,:)); 
hold on;

% Add error bars
errorbar(1:length(means), means, stdDevs, 'k.', 'LineWidth', 1.5); % Error bars for SD

set(gca, 'XTickLabel', {'Subject 1', 'Subject 2', 'Subject 3'});
set(gca, 'FontSize', 14); 
ylabel('Y error (m)');
grid on;



save_name='yerror_all.pdf';
save_dir='D:\STEPPING\stepping paper\Sci data paper';
print(gcf, fullfile(save_dir,save_name), '-dpdf', '-r300'); % 
