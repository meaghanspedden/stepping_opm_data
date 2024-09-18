% load EMG, rectify and smooth, save median for plotting 

addpath('D:\spm')
spm('defaults','eeg')

save_dir='D:\STEPPING\stepping paper\Sci data paper';

sub='00054'; %load preproc SPM file
D=spm_eeg_load('D:\STEPPING\Coh_results00054\Dec2023\erd00054_clone001_erd.mat');

labs=D.chanlabels;
EMGidx=find(contains(labs, 'TA EMG'));

savemat=[];

windowSize=100;


for k=1:size(D,3) %for each trial save envelope

    thistrial=abs(squeeze(D(EMGidx,:,k)));

    envelope = movmean(thistrial, windowSize);

    savemat(:,k)=envelope;

    % plot(D.time, envelope)
    % hold on

end

medianValues=median(savemat,2);
time=D.time;

save(fullfile(save_dir, sprintf('%s_median_emg',sub)), 'medianValues', 'time')




