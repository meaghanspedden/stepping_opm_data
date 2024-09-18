%% load rectified smoothed median EMG from each participant and plot

SubIDs={'00054', '00061', '00159'};

save_dir='D:\STEPPING\stepping paper\Sci data paper';
addpath('D:\stepping_data_opm')

colors = linspecer(30);

figure;
hold on;

colnum=3; %which color to use in linspecer map

for sub=1:length(SubIDs)

    load(fullfile(save_dir,[SubIDs{sub},'_median_emg.mat']))

    time=time';
    
    % Plot median line
    plot(time, medianValues, 'color',colors(colnum,:), 'LineWidth', 4);
    set(gca, 'FontSize', 14); 

    colnum=colnum+4;
end
legend({'Sub1', 'Sub2', 'Sub3'})

xlim([2.5 6.5])

xticks(2.5:1:6.5);

xticklabels({'0','1', '2', '3', '4'});

savename='medianEMGAll.pdf';
print(gcf, fullfile(save_dir,savename), '-dpdf', '-r300'); %
