%% Technical validation analysis

clearvars
addpath('D:\spm') %spm path
spm('defaults','EEG')


sub='OP00159';
BF_file_dir = {['D:\steppingsave_v1\',sub(3:end),'\error_fullbrain']}; %where you want to save the BF file
data_file={['D:\steppingsave_v1\',sub(3:end),'\erd',sub(3:end),'_clone001_erd.mat']};

filename_kin=['D:\STEPPING\stepping paper\Sci data paper\Sub',sub(3:end),'_step_error.mat'];
load(filename_kin)

err=y_error'; err=err(:);
med_val=median(err);
below_idx=find(err<med_val);
above_idx=find(err>med_val);

%% find trials with those indices and mark conditions

D=spm_eeg_load(data_file{1});

D=conditions(D, below_idx, 'LOW');
D=conditions(D, above_idx, 'HIGH');
save(D)



%%----------OG-------------------------------------------
%{'D:\STEPPING\Coh_results00054\Dec2023\beta erd final'}; 

%data_file= {'D:\STEPPING\Coh_results00054\Dec2023\erd00054_clone001_erd.mat'};
%data_file= {'D:\STEPPING\Coh_results00061\Dec2023\erd00061_clone001_erd.mat'};
%data_file= {'D:\STEPPING\Coh_results00159\Dec2023\erd00159_clone1_erd.mat'};

%%------------------------------------------

freqband=[15 30];


if strcmp(sub, 'OP00054')
    stepping_time = [4000 4500];
elseif strcmp(sub, 'OP00061')
    stepping_time = [4100 4600];
elseif strcmp(sub, 'OP00159')
    stepping_time = [4500  5000];
else
    error('invalid subject ID')
end

standing_time = [1600 2100]; %same for all participants

%% low error

matlabbatch = [];

matlabbatch{1}.spm.tools.beamforming.data.dir = BF_file_dir;
matlabbatch{1}.spm.tools.beamforming.data.D = data_file;
matlabbatch{1}.spm.tools.beamforming.data.val = 1;
matlabbatch{1}.spm.tools.beamforming.data.gradsource = 'inv';
matlabbatch{1}.spm.tools.beamforming.data.space = 'MNI-aligned';
matlabbatch{1}.spm.tools.beamforming.data.overwrite = 1;

matlabbatch{2}.spm.tools.beamforming.sources.BF(1) = cfg_dep('Prepare data: BF.mat file', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
matlabbatch{2}.spm.tools.beamforming.sources.reduce_rank = [2 3];
matlabbatch{2}.spm.tools.beamforming.sources.keep3d = 1;
matlabbatch{2}.spm.tools.beamforming.sources.plugin.grid.resolution = 10;
matlabbatch{2}.spm.tools.beamforming.sources.plugin.grid.space = 'MNI template';
matlabbatch{2}.spm.tools.beamforming.sources.plugin.grid.constrain = 'iskull';
matlabbatch{2}.spm.tools.beamforming.sources.normalise_lf = false;
matlabbatch{2}.spm.tools.beamforming.sources.visualise = 1;

matlabbatch{3}.spm.tools.beamforming.features.BF(1) = cfg_dep('Define sources: BF.mat file', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
matlabbatch{3}.spm.tools.beamforming.features.whatconditions.all = 1;
matlabbatch{3}.spm.tools.beamforming.features.woi = [standing_time;stepping_time];
matlabbatch{3}.spm.tools.beamforming.features.modality = {'MEG'};
matlabbatch{3}.spm.tools.beamforming.features.fuse = 'no';
matlabbatch{3}.spm.tools.beamforming.features.cross_terms = 'megeeg';
matlabbatch{3}.spm.tools.beamforming.features.plugin.csd.foi = freqband;
matlabbatch{3}.spm.tools.beamforming.features.plugin.csd.taper = 'dpss';
matlabbatch{3}.spm.tools.beamforming.features.plugin.csd.keepreal = 0;
matlabbatch{3}.spm.tools.beamforming.features.plugin.csd.hanning = 0;

%if spatial_filt_flag

    matlabbatch{3}.spm.tools.beamforming.features.regularisation.clifftrunc.zthresh = -1;
    matlabbatch{3}.spm.tools.beamforming.features.regularisation.clifftrunc.omit = 0;
% else
%     matlabbatch{3}.spm.tools.beamforming.features.regularisation.manual.lambda = 5;
% end

matlabbatch{3}.spm.tools.beamforming.features.bootstrap = false;
matlabbatch{3}.spm.tools.beamforming.features.visualise = 1;

matlabbatch{4}.spm.tools.beamforming.inverse.BF(1) = cfg_dep('Covariance features: BF.mat file', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
matlabbatch{4}.spm.tools.beamforming.inverse.plugin.dics.fixedori = 'yes';


matlabbatch{5}.spm.tools.beamforming.output.BF(1) = cfg_dep('Inverse solution: BF.mat file', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
matlabbatch{5}.spm.tools.beamforming.output.plugin.image_power.whatconditions.condlabel = {'LOW'};
matlabbatch{5}.spm.tools.beamforming.output.plugin.image_power.contrast = [1];
matlabbatch{5}.spm.tools.beamforming.output.plugin.image_power.woi = stepping_time;
matlabbatch{5}.spm.tools.beamforming.output.plugin.image_power.datafeatures = 'sumpower';
matlabbatch{5}.spm.tools.beamforming.output.plugin.image_power.foi = freqband;
matlabbatch{5}.spm.tools.beamforming.output.plugin.image_power.sametrials = false;
matlabbatch{5}.spm.tools.beamforming.output.plugin.image_power.result = 'bytrial';
matlabbatch{5}.spm.tools.beamforming.output.plugin.image_power.modality = 'MEG';
matlabbatch{5}.spm.tools.beamforming.output.plugin.image_power.scale = false;
matlabbatch{5}.spm.tools.beamforming.output.plugin.image_power.logpower = true;

matlabbatch{6}.spm.tools.beamforming.write.BF(1) = cfg_dep('Output: BF.mat file', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
matlabbatch{6}.spm.tools.beamforming.write.plugin.nifti.normalise = 'no';
matlabbatch{6}.spm.tools.beamforming.write.plugin.nifti.space = 'mni';

[a,b] = spm_jobman('run',matlabbatch); %struct output for each module

%% smooth images

% Initialize a new batch
matlabbatch = [];

% Set up the smoothing parameters
matlabbatch{1}.spm.spatial.smooth.fwhm = [10 10 10];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 1; %does this contain
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

% Assign all files to the batch at once
matlabbatch{1}.spm.spatial.smooth.data = a{end}.files;

% Run the batch once for all images
[a1, b1] = spm_jobman('run', matlabbatch);

smoothed_files = a1{1}.files;


%% copy images into folder for standing condition

lowerror_dir = fullfile(BF_file_dir,'lowerror');

if ~exist(lowerror_dir{:},'dir'); mkdir(lowerror_dir{:}); end

spm_copy(a{end}.files,lowerror_dir);
spm_copy(smoothed_files', lowerror_dir);

for ii = 1:numel(a{end}.files)
    delete(a{end}.files{ii});
    delete(smoothed_files{ii});
end


%% now do the same for high error

BF_file = a{end}.BF; %use modules from prev analysis, only output changing periods

matlabbatch = [];
matlabbatch{1}.spm.tools.beamforming.output.BF(1) = BF_file;
matlabbatch{1}.spm.tools.beamforming.output.plugin.image_power.whatconditions.condlabel = {'HIGH'};
matlabbatch{1}.spm.tools.beamforming.output.plugin.image_power.contrast = [1];
matlabbatch{1}.spm.tools.beamforming.output.plugin.image_power.woi = stepping_time;
matlabbatch{1}.spm.tools.beamforming.output.plugin.image_power.datafeatures = 'sumpower';
matlabbatch{1}.spm.tools.beamforming.output.plugin.image_power.foi = freqband;
matlabbatch{1}.spm.tools.beamforming.output.plugin.image_power.sametrials = false;
matlabbatch{1}.spm.tools.beamforming.output.plugin.image_power.result = 'bytrial';
matlabbatch{1}.spm.tools.beamforming.output.plugin.image_power.modality = 'MEG';
matlabbatch{1}.spm.tools.beamforming.output.plugin.image_power.scale = false;
matlabbatch{1}.spm.tools.beamforming.output.plugin.image_power.logpower = true;
matlabbatch{2}.spm.tools.beamforming.write.BF(1) = BF_file;
matlabbatch{2}.spm.tools.beamforming.write.plugin.nifti.normalise = 'no';
matlabbatch{2}.spm.tools.beamforming.write.plugin.nifti.space = 'mni';

[a,b] = spm_jobman('run',matlabbatch);

%% smooth images

matlabbatch = [];

% Set up the smoothing parameters
matlabbatch{1}.spm.spatial.smooth.fwhm = [10 10 10];
matlabbatch{1}.spm.spatial.smooth.dtype = 0;
matlabbatch{1}.spm.spatial.smooth.im = 1;
matlabbatch{1}.spm.spatial.smooth.prefix = 's';

% Assign all files to the batch at once
matlabbatch{1}.spm.spatial.smooth.data = a{end}.files;

% Run the batch once for all images
[a1, b1] = spm_jobman('run', matlabbatch);

smoothed_files = a1{1}.files;


higherror_dir = fullfile(BF_file_dir,'higherror');

if ~exist(higherror_dir{:},'dir'); mkdir(higherror_dir{:}); end

spm_copy(a{end}.files,higherror_dir);
spm_copy(smoothed_files', higherror_dir);

for ii = 1:numel(a{end}.files)
    delete(a{end}.files{ii});
    delete(smoothed_files{ii});
end


%% SPM 2nd level 

spm_dir = fullfile(BF_file_dir,'spm');

if ~exist(spm_dir{:},'dir')
    mkdir(spm_dir{:}); 
end

dcon = cellstr(spm_select('fplist',lowerror_dir,'^.*suv.*\.nii$'));
dact = cellstr(spm_select('fplist',higherror_dir,'^.*suv.*\.nii$'));


matlabbatch = [];

matlabbatch{1}.spm.stats.factorial_design.dir = spm_dir;

for ii = 1:numel(dact)
    matlabbatch{1}.spm.stats.factorial_design.des.pt.pair(ii).scans = {dcon{ii},dact{ii}}'; %image pairs for each trial
end

matlabbatch{1}.spm.stats.factorial_design.des.pt.gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.pt.ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.review.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.review.display.matrix = 1;
matlabbatch{2}.spm.stats.review.print = false;
matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{4}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));

matlabbatch{4}.spm.stats.con.consess{1}.tcon.name = 'con > act';
matlabbatch{4}.spm.stats.con.consess{1}.tcon.weights = [1 -1];
matlabbatch{4}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{4}.spm.stats.con.delete = 0;

matlabbatch{5}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{5}.spm.stats.results.conspec.titlestr = 'step desynch';
matlabbatch{5}.spm.stats.results.conspec.contrasts = 1;
matlabbatch{5}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch{5}.spm.stats.results.conspec.thresh = 0.05;
matlabbatch{5}.spm.stats.results.conspec.extent = 0;
matlabbatch{5}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{5}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{5}.spm.stats.results.units = 1;
matlabbatch{5}.spm.stats.results.export = cell(1, 0);

spm_jobman('run',matlabbatch)