clearvars
% addpath('D:\spm') %spm path
% spm('defaults','EEG')


sub='OP00061';
data_file=['D:\steppingsave_v1\',sub(3:end),'\erd',sub(3:end),'_clone001_erd.mat'];


if strcmp(sub, 'OP00159')
    stepping = [2 2.5];
elseif strcmp(sub, 'OP00054')
    stepping = [1.5 2];
else
    stepping = [1.6 2.1];
end

D=spm_eeg_load(data_file);

badchans=(D.badchannels);
megchans=find(contains(D.chantype,'MEG')); %idx
if strcmp(sub, 'OP00159')
    megchans=1:44;
end
goodchans = setdiff(megchans, badchans); %1:144 good chans for 159

newtime=D.time-3;

dat=median(D(goodchans,:,:),3);
glob_med=median(dat,1);

f=figure('Position', [65.6667, 198, 1210.7, 420])
plot(newtime, glob_med, 'color', [0 0.5 0.5], 'LineWidth',1); hold on
box off
xlim([stepping(1)-1 stepping(2)+.5])
vline(stepping, 'k--')
set(gca, 'FontSize', 14);
xlabel('Time after go signal (s)')
ylabel('B (fT)')

savepath='D:\STEPPING\stepping paper\sensors special issue\final figures\global medians';
savename=sprintf('global_med_%s',sub);

savefig(f, fullfile(savepath,savename));
print(f, fullfile(savepath,savename), '-dsvg');



% stepidx=dsearchn(newtime',stepping');
% standidx=dsearchn(newtime',standing');
% 
% varstep=var(glob_med(stepidx(1):stepidx(2)))
% varstand=var(glob_med(standidx(1):standidx(2)))

%%
error('stop here')
sourcefile='D:\steppingsave_v1\00061\Berd00061_clone001_erd.mat';

D=spm_eeg_load(sourcefile);

sourcedat=median(D(:,:,:),3);
figure; plot(newtime,sourcedat)
xlabel('Time after go signal (s)')

ylabel('B (fT)')
xlim([1.1 2.6])
vline([1.6 2.1], 'k--')
box off

