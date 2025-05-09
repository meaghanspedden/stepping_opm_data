



addpath('D:\spm') %spm path
spm('defaults','EEG')

%%


sourcefile='D:\steppingsave_v1\00159\Berd00159_clone001_erd.mat';

D=spm_eeg_load(sourcefile)


ftdat=spm2fieldtrip(D)

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'Left M1';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = [15:40];
%cfg.t_ftimwin = 5 ./ cfg.foi;  % 5 cycles per frequency
%cfg.tapsmofrq = 0.4 * cfg.foi;  % ~40% smoothing per frequency
%cfg.tapsmofrq   = 3;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.25;   % length of time window = 0.5 sec
cfg.toi          = 1.5:0.1:6;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
TFR = ft_freqanalysis(cfg, ftdat);


dat1=TFR.powspctrm;

addpath('D:\brainspineconnectivity\plotting')

cfg = [];
cfg.baseline     = [1.5 3];
cfg.baselinetype = 'relchange';
cfg.maskstyle    = 'saturation';
%cfg.zlim         = [-2 2];
cfg.channel      = 'Left M1';
figure
ft_singleplotTFR(cfg, TFR);


%figure; plot(TFR.time, squeeze(mean(TFR.powspctrm,2)))


normdat = performNormalization(TFR.time,TFR.powspctrm, cfg.baseline, 'db');

% figure; 
% s= pcolor(TFR.time, TFR.freq, squeeze(normdat));
% s.FaceColor='interp';
% s.EdgeColor='interp';
% colorbar
% caxis([-3 3])

%%
sourcefile='D:\steppingsave_v1\00054\Berd00054_clone001_erd.mat';

D=spm_eeg_load(sourcefile)


ftdat=spm2fieldtrip(D)

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'Left M1';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = [15:40];
%cfg.t_ftimwin = 5 ./ cfg.foi;  % 5 cycles per frequency
%cfg.tapsmofrq = 0.4 * cfg.foi;  % ~40% smoothing per frequency
%cfg.tapsmofrq   = 3;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.25;   % length of time window = 0.5 sec
cfg.toi          = 1.5:0.1:6;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
TFR = ft_freqanalysis(cfg, ftdat);
dat2=TFR.powspctrm;

cfg = [];
cfg.baseline     = [1.5 3];
cfg.baselinetype = 'relchange';
cfg.maskstyle    = 'saturation';
%cfg.zlim         = [-2 2];
cfg.channel      = 'Left M1';
% figure
% ft_singleplotTFR(cfg, TFR);


%figure; plot(TFR.time, squeeze(mean(TFR.powspctrm,2)))


normdat2 = performNormalization(TFR.time,TFR.powspctrm, cfg.baseline, 'db');

% figure; 
% s= pcolor(TFR.time, TFR.freq, squeeze(normdat));
% s.FaceColor='interp';
% s.EdgeColor='interp';
% colorbar
% caxis([-3 3])

%%
sourcefile='D:\steppingsave_v1\00061\Berd00061_clone001_erd.mat';

D=spm_eeg_load(sourcefile)


ftdat=spm2fieldtrip(D)

cfg              = [];
cfg.output       = 'pow';
cfg.channel      = 'Left M1';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = [15:40];
%cfg.t_ftimwin = 5 ./ cfg.foi;  % 5 cycles per frequency
%cfg.tapsmofrq = 0.4 * cfg.foi;  % ~40% smoothing per frequency
%cfg.tapsmofrq   = 3;
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.25;   % length of time window = 0.5 sec
cfg.toi          = 1.5:0.1:6;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
TFR = ft_freqanalysis(cfg, ftdat);

addpath('D:\brainspineconnectivity\plotting')

cfg = [];
cfg.baseline     = [1.5 3];
cfg.baselinetype = 'relchange';
cfg.maskstyle    = 'saturation';
%cfg.zlim         = [-2 2];
cfg.channel      = 'Left M1';
figure
ft_singleplotTFR(cfg, TFR);

dat3=TFR.powspctrm;
%figure; plot(TFR.time, squeeze(mean(TFR.powspctrm,2)))


normdat3 = performNormalization(TFR.time,TFR.powspctrm, cfg.baseline, 'db');


alldat=cat(4, dat1, dat2, dat3);
meandat=mean(alldat,4);
normdatmean = performNormalization(TFR.time,meandat, cfg.baseline, 'db');

levels = -2:1.5:2;


figure; 
s= pcolor(TFR.time, TFR.freq, squeeze(normdatmean));
s.FaceColor='interp';
s.EdgeColor='interp';
%colormap(cmocean('delta'))
colorbar
caxis([-2 2])
hold on
[C, h]= contour(TFR.time, TFR.freq, squeeze(normdatmean),levels, 'LineColor', [0.4 0.4 0.4], 'LineWidth', 1.5); % 'k' for black lines
clabel(C, h, 'FontSize', 12, 'Color', 'black', 'FontWeight', 'bold', 'LabelSpacing', 350);


