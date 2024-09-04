%% plot kinematics

SubIDs={'sub00054', 'sub00061', 'sub00159'};

save_dir='D:\STEPPING\stepping paper\Sci data paper';
addpath('D:\stepping_data_opm')

colors = linspecer(30);

figure;
hold on;

colnum=3;

for sub=1:length(SubIDs)

load(fullfile(save_dir,['med_pos_and_iqr_',SubIDs{sub}]))

upperBound = medianValues + 0.5 * iqrValues;
lowerBound = medianValues - 0.5 * iqrValues;

%fill([time, fliplr(time)], [upperBound, fliplr(lowerBound)], colors(colnum,:), 'FaceAlpha', 0.35, 'EdgeColor', 'none');

plot(time, medianValues, 'color',colors(colnum,:), 'LineWidth', 4);
set(gca, 'FontSize', 14); 

colnum=colnum+4;

end

legend({'Sub1', 'Sub2','Sub3'})

%legend({'','Sub1','', 'Sub2','', 'Sub3'})


savename='medianPositionAll.pdf';
print(gcf, fullfile(save_dir,savename), '-dpdf', '-r300'); % 

