
%% trial by trial step length


addpath('D:\spm') 
spm('defaults','EEG')

sub='00054';
filename_kin='D:\STEPPING\stepping paper\Sci data paper\Sub00054_step_error.mat';
sourcefile='D:\steppingsave_v1\00054\Berd00054_clone001_erd.mat';
load(filename_kin) %y_error 6 x 30
err=y_error'; err=err(:);

D=spm_eeg_load(sourcefile);

ftdat=spm2fieldtrip(D);

cfg=[];
cfg.toilim=[3 4.5];
ftdat=ft_redefinetrial(cfg,ftdat);


cfg2 = [];
cfg2.output    = 'pow';
cfg2.channel   = 'all';
cfg2.method    = 'mtmfft';
cfg2.foilim    = [15 30];
cfg2.keeptrials='yes';
cfg2.taper     = 'hanning'; %
cfg2.tapsmofrq = 1;
freqdat    = ft_freqanalysis(cfg2, ftdat);


dat=squeeze(freqdat.powspctrm);
Y=dat-mean(dat);

X=log(err);
X=X-mean(X);

spm_cva(Y,X)