clear all
close all
restoredefaultpath

sub='00054';

addpath('D:\spm')
spm('EEG', 'defaults')
addpath('D:\stepping_data_opm\plotting')

fieldtripDir    = 'D:\fieldtrip';
addpath(fieldtripDir)
ft_defaults;


savepath=['D:\steppingsave_v1\',sub];
cd(savepath)
%%

if strcmp(sub,'00061')
    posfile='D:\STEPPING_bids_v1\sub-OP00061\ses-001\meg\sub-OP00061_ses-001_task-stepping_positions.tsv';
    MRIfile='D:\OP00061_experiment\mmsMQ0484_orig.img';
    filename='D:\STEPPING_bids_v1\sub-OP00061\ses-001\meg\erd00061_clone001_erd.mat';
    stepping_time = [4.100 4.600];


elseif strcmp(sub,'00054')
    
    posfile='D:\STEPPING_bids_v1\sub-OP00054\ses-001\meg\sub-OP00054_ses-001_task-stepping_positions.tsv';
    MRIfile='D:\OP00054_experiment\OP00031-headcast.nii';
    filename='D:\STEPPING_bids_v1\sub-OP00054\ses-001\meg\erd00054_clone001_erd.mat';
    stepping_time = [4 4.5];


    elseif strcmp(sub,'00159')
    MRIfile='D:\OP00159_experiment\scannercast_info\OP00159_defaced.nii';
    posfile='D:\STEPPING_bids_v1\sub-OP00159\ses-001\meg\sub-OP00159_ses-001_task-stepping_positions.tsv';
    filename='D:\STEPPING_bids_v1\sub-OP00159\ses-001\meg\erd00159_clone001_erd.mat';
    fileraw='D:\steppingsave_v1\00159\erd_raw00159_clone001_erd_raw.mat';
    filetempfilt='D:\steppingsave_v1\00159\erd_tempfilt00159_clone001_erd_tempfilt.mat';
    stepping_time = [4.500  5.000];
end


standing_time = [1.600 2.100]; %same for all participants


%load headlayout


%D=spm_eeg_load(fileraw);

%ftdatraw=spm2fieldtrip(D);

D=spm_eeg_load(filename);
badchans=D.badchannels; 
ftdatproc=spm2fieldtrip(D);

meglabs=ftdatproc.label(1:end-9);
badlabs=ftdatproc.label(badchans);
goodmeg=meglabs(~contains(meglabs,badlabs));

cfg=[];
cfg.channel=goodmeg;
ftdat=ft_selectdata(cfg,ftdatproc);

% D=spm_eeg_load(filetempfilt);
% ftdattempfilt=spm2fieldtrip(D);

%chanidx=find(contains(ftdatraw.label, '53-0L-Y'));

rawmat=[]; procmat=[]; tempfiltmat=[];

cfg=[];
cfg.bpfilter='yes';
cfg.bpfreq= [15 30];
%cfg.channel=ftdatraw.label{chanidx};
%betadatraw=ft_preprocessing(cfg,ftdatraw);
betadatproc=ft_preprocessing(cfg,ftdat);
%betadattemp=ft_preprocessing(cfg, ftdattempfilt);

% for k=1:length(betadatraw.trial)
% 
% % rawmat(k,:)=abs(hilbert(betadatraw.trial{k}));
% procmat(:,:,k)=abs(hilbert(betadatproc.trial{k}));
% %tempfiltmat(k,:)=abs(hilbert(betadattemp.trial{k}));
% end

%meanraw=mean(rawmat,1);
%meanproc=mean(procmat,1);
%meantemp=mean(tempfiltmat,1);


color1 = [0.5, 0.2, 0.7];   % 
color2 = [0.85, 0.33, 0.1]; %


% figure; plot(ftdatraw.time{1}-3,meanraw,'LineWidth',2, 'Color', color1)
% ylabel('Beta envelope')
% hold on
% yyaxis right
% plot(ftdatraw.time{1}-3,meanproc, 'LineWidth', 2, 'Color', color2)
% %ylim([175 350])
% 
% %ylim([150 350])
% box off;
% vline([1], 'k--')
% xlim([-1 2.7])
% xlabel('Time (s)')
%legend({'Raw', 'Processed'})
%%
n_trials=length(betadatproc.trial);

beta_envelopes = zeros(n_trials, size(betadatproc.trial{1}, 2));

for i = 1:n_trials
    trial_data = betadatproc.trial{i};
    envelope = abs(hilbert(trial_data'))';               
    beta_envelopes(i, :) = mean(envelope, 1);         
end

avg_envelope = mean(beta_envelopes, 1);
correlations = zeros(1, n_trials);
for i = 1:n_trials
    correlations(i) = corr(beta_envelopes(i, :)', avg_envelope');
end

[~, best_trial_idx] = max(correlations);
plot_time_series
vline([1 1.5], 'k--')

%%
% figure 
% plot(ftdat.time{1}-3,ftdat.trial{best_trial_idx}(1:end-9,:))
% vline([1], 'k--')
% xlim([0 2.1])
% xlabel('Time (s)')

% 
% if strcmp(sub, 'OP00159')
%     stepping = [2 2.5];
% elseif strcmp(sub, 'OP00054')
%     stepping = [1.5 2];
% else
%     stepping = [1.6 2.1];
% end

error('stop')
ftdat=ftdatproc;
cfg=[];
cfg.toilim=standing_time;
stand=ft_redefinetrial(cfg, ftdat);

cfg=[];
cfg.toilim=stepping_time;
step=ft_redefinetrial(cfg,ftdat);

cfg2 = [];
cfg2.output    = 'pow';
cfg2.channel   = 'all';
cfg2.method    = 'mtmfft';
cfg2.taper     = 'hanning';
cfg2.foilim       = [15 30];
standfreq   = ft_freqanalysis(cfg2, stand);

stepfreq   = ft_freqanalysis(cfg2, step);

pow_diff=stepfreq;
pow_diff.powspctrm=10*log10(stepfreq.powspctrm.\standfreq.powspctrm);
%pow_diff.powspctrm=(stepfreq.powspctrm-standfreq.powspctrm).\standfreq.powspctrm;




fig=figure;
fig.Position = [100, 200, 600, 400];
cfg                  = [];
cfg.parameter        = 'powspctrm';
cfg.xlim             = [15 30];
%cfg.zlim             =[-.6 0];
cfg.interplimits     ='head';
cfg.layout           = lay;
cfg.channel = pow_diff.label(contains(pow_diff.label, '-Y'));

ft_topoplotER(cfg,pow_diff)
colorbar

figure
ft_plot_layout(lay, 'chanindx',chanidx, 'label', 'no', 'box', 'no')






