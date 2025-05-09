%% Technical validation analysis

clearvars
addpath('D:\spm') %spm path
spm('defaults','EEG')
%spm eeg %apparently need to opne the gui to run batch? prob a way around this...

sub='OP00159';

    BF_file_dir = {['D:\steppingsave_v1\',sub(3:end),'\pow_source']}; %where you want to save the BF file
    data_file={['D:\steppingsave_v1\',sub(3:end),'\erd',sub(3:end),'_clone001_erd.mat']};

if ~isfolder(BF_file_dir{1})
    mkdir(BF_file_dir{1});
end


freqband=[15 30];

% time periods for stepping identified by visual inspection of EMG signal

% if strcmp(sub, 'OP00054') || strcmp(sub, 'OP00061')
%     stepping_time=[4200 4700];

% if strcmp(sub, 'OP00054')
%     stepping_time = [4000 4500];
% elseif strcmp(sub, 'OP00061')
%     stepping_time = [4100 4600];
% elseif strcmp(sub, 'OP00159')
%     stepping_time = [4500  5000];
% else
%     error('invalid subject ID')
% end
% 
% standing_time = [1600 2100]; %same for all participants

%% standing epoch

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
matlabbatch{2}.spm.tools.beamforming.sources.plugin.voi.vois{1}.voidef.label = 'Left M1';
matlabbatch{2}.spm.tools.beamforming.sources.plugin.voi.vois{1}.voidef.pos = [-42 -12 54 ];
matlabbatch{2}.spm.tools.beamforming.sources.plugin.voi.vois{1}.voidef.ori = [0 0 0];
matlabbatch{2}.spm.tools.beamforming.sources.plugin.voi.radius = 15;
matlabbatch{2}.spm.tools.beamforming.sources.plugin.voi.resolution = 5;
matlabbatch{2}.spm.tools.beamforming.sources.normalise_lf = false;
matlabbatch{2}.spm.tools.beamforming.sources.visualise = 1;

matlabbatch{3}.spm.tools.beamforming.features.BF(1) = cfg_dep('Define sources: BF.mat file', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
matlabbatch{3}.spm.tools.beamforming.features.whatconditions.all = 1;
matlabbatch{3}.spm.tools.beamforming.features.woi = [-Inf Inf];
matlabbatch{3}.spm.tools.beamforming.features.modality = {'MEG'};
matlabbatch{3}.spm.tools.beamforming.features.fuse = 'no';
matlabbatch{3}.spm.tools.beamforming.features.cross_terms = 'megeeg';
matlabbatch{3}.spm.tools.beamforming.features.plugin.cov.foi = freqband;
matlabbatch{3}.spm.tools.beamforming.features.plugin.cov.taper = 'none';
matlabbatch{3}.spm.tools.beamforming.features.regularisation.clifftrunc.zthresh = -1;
matlabbatch{3}.spm.tools.beamforming.features.regularisation.clifftrunc.omit = 0;
matlabbatch{3}.spm.tools.beamforming.features.bootstrap = false;
matlabbatch{3}.spm.tools.beamforming.features.visualise = 1;



matlabbatch{4}.spm.tools.beamforming.inverse.BF(1) = cfg_dep('Covariance features: BF.mat file', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
matlabbatch{4}.spm.tools.beamforming.inverse.plugin.lcmv.orient = true;
matlabbatch{4}.spm.tools.beamforming.inverse.plugin.lcmv.keeplf = false;
matlabbatch{5}.spm.tools.beamforming.output.BF(1) = cfg_dep('Inverse solution: BF.mat file', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
matlabbatch{5}.spm.tools.beamforming.output.plugin.montage.method = 'max';
matlabbatch{5}.spm.tools.beamforming.output.plugin.montage.vois = cell(1, 0);

matlabbatch{6}.spm.tools.beamforming.write.BF(1) = cfg_dep('Output: BF.mat file', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','BF'));
matlabbatch{6}.spm.tools.beamforming.write.plugin.spmeeg.mode = 'write';
matlabbatch{6}.spm.tools.beamforming.write.plugin.spmeeg.modality = 'MEG';
matlabbatch{6}.spm.tools.beamforming.write.plugin.spmeeg.addchannels.none = 0;
matlabbatch{6}.spm.tools.beamforming.write.plugin.spmeeg.prefix = 'B';

[a,b] = spm_jobman('run',matlabbatch); %struct output for each module



