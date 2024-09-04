%% load values and plot on same fig

SubIDs={'00054', '00061', '00159'};

save_dir='D:\STEPPING\stepping paper\Sci data paper';
addpath('D:\stepping_data_opm')

colors = linspecer(30);


figure;
hold on;

colnum=3;

for sub=1:length(SubIDs)

    load(fullfile(save_dir,[SubIDs{sub},'_median_emg.mat']))

    time=time';
    upperBound = medianValues + 0.5 * iqrValues;
    lowerBound = medianValues - 0.5 * iqrValues;

    % Plot the median with shaded IQR area

    % Plot the shaded area representing the IQR
    %fill([time, fliplr(time)], [upperBound, fliplr(lowerBound)], colors(colnum,:), 'FaceAlpha', 0.35, 'EdgeColor', 'none');
    
    hold on
    
    % Plot the median line
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
