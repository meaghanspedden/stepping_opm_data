% stepping preprocessing for tech validation - sci data

restoredefaultpath
clear all
%close all

addpath('D:\spm') %spm path
spm('defaults','EEG')

addpath(genpath('D:\stepping_data_opm')) %github repository path


%Subject ID----------
%sub='OP00054';
sub='OP00061';
%sub='OP00159';


datpath='D:\STEPPING\';
savepath=['D:\STEPPING\Coh_results',sub(3:end),'\Dec2023'];

if ~exist(savepath,'dir')
    mkdir(savepath)
end

cd(savepath)


%% ----------------------- settings for each subject
if strcmp(sub,'OP00061')

    MEGruns={'001','002','003','004','005'};
    posfile=[datpath,'sub-OP00061\ses-001\meg\ds_sub-OP00061_ses-001_task-stepping_positions.tsv'];
   MRIfile= 'D:\OP00061_experiment\mmsMQ0484_orig.img';
   % MRIfile=[datpath,'sub-OP00061\ses-001\anat\OP00061_defaced.nii'];
    badchans='G2-DH';
    trigChan='NI-TRIG-1';



elseif strcmp(sub,'OP00054')
    MEGruns={'001','002','003','004','005'};
    posfile=[datpath,'sub-OP00054\ses-001\meg\ds_sub-OP00054_ses-001_task-stepping_positions.tsv'];
    MRIfile=[datpath,'sub-OP00054\ses-001\anat\OP00054_defaced.nii'];
    badchans={'DO-Z', '35-Z', 'DK-Y','DK-Z','GD-Y','GD-Z','GD-X'};
    trigChan='NI-TRIG-1';



elseif strcmp(sub,'OP00159')
    MEGruns={'1','2','3','4','5','6'};
    posfile=[datpath,'sub-OP00159\ses-001\meg\sub-OP00159_ses-001_task-stepping_positions.tsv'];
    MRIfile=[datpath,'sub-OP00159\ses-001\anat\OP00159_defaced.nii'];
    badchans={'2-QK-X','2-QK-Y','2-QK-Z','X39','Y39','Z39'};
    trigChan ='A16';


else
    error('incorrect subject ID')

end

%% loop through MEG runs


for k=1:length(MEGruns)

    if strcmp(sub,'OP00159') % no ds prefix

        filetemplate=[datpath,'sub-OP',sub(3:end),'\ses-001\meg\sub-OP',sub(3:end),'_ses-001_task-stepping_run-'];

    else %old system recordings have ds prefix
        filetemplate=[datpath,'sub-OP',sub(3:end),'\ses-001\meg\ds_sub-OP',sub(3:end),'_ses-001_task-stepping_run-'];

    end

    %% load opm data ------------------------------------

    S = [];
    S.data = [filetemplate,MEGruns{k},'_meg.bin'];
    S.meg = [filetemplate,MEGruns{k},'_meg.json'];
    S.channels = [filetemplate,MEGruns{k},'_channels.tsv'];
    S.positions = posfile;
    S.precision = 'single';
    S.sMRI=MRIfile;

    D = spm_opm_create(S);

    close all

%% load emg data, structure as FT to convert to spm


emg_tsv = [filetemplate,MEGruns{k},'_emg.tsv'];
emg_json = [filetemplate,MEGruns{k},'_emg.json'];

ftdat = load_emg_bids_tsv(emg_tsv, emg_json);

%trigsampsEMG=trigtimes*TAEMGstruct.fsample;

EMGspmfilename=[savepath,'\stepping_spmEMGobj_new__',sub,'_run',MEGruns{k}];

D_EMG=spm_eeg_ft2spm(ftdat, EMGspmfilename);

%% look at psd for EMG
S = [];
S.D = D_EMG;
S.plot = 1;
S.triallength = 2000;
S.wind = @hanning;
spm_opm_psd(S);
xlim([1,100])

% plot time series
figure
plot(ftdat.time{1},ftdat.trial{1}(1,:))
hold on
plot(ftdat.time{1},ftdat.trial{1}(2,:)) %trigger

%% resample MEG to match EMG

S=[];
S.D=D;
S.fsample_new=1000;
Ds=spm_eeg_downsample(S);

%% look at psd

if isempty(badchans)
    badchanidx=[];
else
    badchanidx=find(contains(Ds.chanlabels,badchans));
    Ds=Ds.badchannels(badchanidx,1);
end

MEGchans=find(contains(D.chantype,'MEGMAG')); %idx

chanidxtoplot =setdiff(MEGchans,badchanidx);

S = [];
S.D = Ds;
S.plot = 1;
S.channels = Ds.chanlabels(chanidxtoplot);
S.triallength = 3000;
S.wind = @hanning;
spm_opm_psd(S);
xlim([1,100])
ylim([10^1 10^5])
title('Pre hfc/amm')


%% hfc or amm

if strcmp(sub,'OP00178') %nchannels >120

    S = [];
    S.D = Ds;
    S.li = 9;
    S.le = 3;
    S.corrLim = 0.98;
    hfD = spm_opm_amm(S);

else %nchannels < 120

    S = [];
    S.D = Ds;
    S.usebadchans=0;
    [hfD, Yinds] = spm_opm_hfc(S);

end


S = [];
S.D = hfD;
S.plot = 1;
S.channels = Ds.chanlabels(chanidxtoplot);
S.triallength = 2000;
S.wind = @hanning;
spm_opm_psd(S);
xlim([1,100])
ylim([10^1 10^5])
title('post hfc/amm')


S = [];
S.D1 = Ds;
S.D2=hfD;
S.plot = 1;
S.channels = Ds.chanlabels(chanidxtoplot);
S.triallength = 2000;
S.wind = @hanning;
[shield,f] = spm_opm_rpsd(S);
xlim([1,100])
%legend(Ds.chanlabels(chanidxtoplot))
title('shielding factor (db)')

%% hp filter MEG

S = [];
S.D = hfD;
S.type = 'butterworth';
S.band = 'high';
S.freq = 5;
S.dir = 'twopass';
Dfilt = spm_eeg_filter(S);

%% hp filter EMG

S=[];
S.type = 'butterworth';
S.band = 'high';
S.dir = 'twopass';
S.freq = 10;
S.D=D_EMG;
DEMGfilt=spm_eeg_filter(S);

%% low pass MEG

S = [];
S.D = Dfilt;
S.type = 'butterworth';
S.band = 'low';
S.freq = 45;
S.dir = 'twopass';
Dfilt = spm_eeg_filter(S);

%% low pass to EMG here

S = [];
S.D = DEMGfilt;
S.type = 'butterworth';
S.band = 'low';
S.freq = 45;
S.dir = 'twopass';
S.order = 5; %high freq noise so increased order
DEMGfilt = spm_eeg_filter(S);

%% band stop 50 hz

S = [];
S.D = Dfilt;
S.type = 'butterworth';
S.band = 'stop';
S.freq = [49 51];
S.dir = 'twopass';
Dfilt = spm_eeg_filter(S);

S = [];
S.D = DEMGfilt;
S.type = 'butterworth';
S.band = 'stop';
S.freq = [49 51];
S.dir = 'twopass';
DEMGfilt = spm_eeg_filter(S);

%% plot EMG power spectrum

%     S = [];
%     S.D = DEMGfilt;
%     S.plot = 1;
%     S.triallength = 2000;
%     S.wind = @hanning;
%     spm_opm_psd(S);
%     xlim([1 500])

%% plot time series

ftdat=spm2fieldtrip(Dfilt);
ftdat=rmfield(ftdat,'hdr');

% cfg=[];
% cfg.channel=ftdat.label(~contains(ftdat.label,'TRIG')& ~contains(ftdat.label,badchans));
% ft_databrowser(cfg,ftdat)


close all

%% find MEG trigger times

trigIdx=find(strcmp(Dfilt.chanlabels,trigChan));

tChan=D(trigIdx,:);

thresh=1;

evSamples=find(diff(tChan<thresh)==1)-1;

evSamples=round((evSamples/(D.fsample/Ds.fsample))); %because downsampled

%% epoch MEG based on trial start trigger from -1.5 to 3 sec

S = [];
S.D = Dfilt;
S.bc = 0;
S.prefix = 'ep_erd';
S.trl = ([evSamples'-(Dfilt.fsample*1.5) evSamples'+(Dfilt.fsample*3) ones(length(evSamples),1)*Dfilt.fsample*1.5]);
ERDepoch = spm_eeg_epochs(S);

%% do the same for EMG
EMG_chans = chanlabels(D_EMG);
trigIdxEMG=find(contains(EMG_chans,'Trigger'));
tChanEMG=D_EMG(trigIdxEMG,:);

thresh=0.9;

evSamples=find(diff(tChanEMG<thresh)==1)-1;


S = [];
S.D = DEMGfilt;
S.bc = 0;
S.trl = ([evSamples'-(DEMGfilt.fsample*1.5) evSamples'+(DEMGfilt.fsample*3) ones(length(evSamples),1)*DEMGfilt.fsample*1.5]);
ERDepochEMG = spm_eeg_epochs(S);


%% clone data and add emg channel (to make data set with both EMG and MEG)


MEGdim=size(ERDepoch,1);
clonename=sprintf('%s_clone1%s_erd',sub(3:end),MEGruns{k});
newdataerd = clone(ERDepoch, clonename, [MEGdim+1 size(ERDepoch,2), size(ERDepoch,3)], 1);

%add EMG data
newdataerd(1:MEGdim, :, :)=ERDepoch(:,:,:);
newdataerd(MEGdim+1,:,:)=ERDepochEMG(:,:,:);

%add chanlabels and types
newdataerd=chanlabels(newdataerd, 1:size(newdataerd,1),[ERDepoch.chanlabels,{'TA EMG'}]);

trigsIdx=find(contains(newdataerd.chanlabels,'TRIG') | contains(newdataerd.chanlabels,'AI') | contains(newdataerd.chanlabels,'DI') | contains(newdataerd.chanlabels,'Data'));

newdataerd=chantype(newdataerd,1:MEGdim,'MEG');
newdataerd=chantype(newdataerd,trigsIdx,'Other');
newdataerd=chantype(newdataerd,MEGdim+1,'EMG');

newdataerd=units(newdataerd,1:MEGdim, 'fT');
newdataerd=units(newdataerd,trigsIdx,'unknown');

if ~isempty(badchanidx)
    newdataerd=newdataerd.badchannels(badchanidx, 1);
end

save(newdataerd)


end %loop through runs


% merge  runs


S = [];
count = 0;
for r = 1:length(MEGruns)
    count = count+1;
   
        S.D(count,:) = char(strcat(datpath,'sub-OP',sub(3:end),'\ses-001\meg\',sub(3:end),'_clone1',MEGruns(r),'_erd.mat'));

end


S.recode.file = '.*';
S.recode.labelorg = '.*';
S.recode.labelnew = '#labelorg#';
S.prefix = 'erd';
DallERD = spm_eeg_merge(S);

S = [];
S.D = DallERD;
DallERD = spm_eeg_ft_artefact_visual(S); %this sets trials/chans to bad
save(DallERD)

%badchans=DallERD.chanlabels(DallERD.badchannels);







