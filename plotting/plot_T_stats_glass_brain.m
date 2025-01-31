%plot t stats on glass brain with stat threshold

clear all
close all

addpath('D:\SPM')
spm('defaults','EEG');

%subs={'00054', '00061', '00159'};

subs={'00159'};

all_t_img=zeros(91, 109, 91, length(subs));
t_thresh=zeros(1,length(subs));

for s = 1:length(subs)

    thissub=subs{s};

    SPMpath=['D:\steppingsave_v1\', thissub, '\spm\'];


    matlabbatch=[];
    matlabbatch{1}.spm.stats.results.spmmat(1) = {[SPMpath '\SPM.mat']};
    matlabbatch{1}.spm.stats.results.conspec.titlestr = 'move';
    matlabbatch{1}.spm.stats.results.conspec.contrasts = 1;
    matlabbatch{1}.spm.stats.results.conspec.threshdesc = 'FWE';
    matlabbatch{1}.spm.stats.results.conspec.thresh = 0.05;
    matlabbatch{1}.spm.stats.results.conspec.extent = 0;
    matlabbatch{1}.spm.stats.results.conspec.conjunction = 1;
    matlabbatch{1}.spm.stats.results.conspec.mask.none = 1;
    matlabbatch{1}.spm.stats.results.units = 1;
    matlabbatch{1}.spm.stats.results.export = cell(1, 0);

    spm_jobman('run',matlabbatch)


    S = [];
    S.mri  = [SPMpath,'spmT_0001.nii'];

    S.threshold = xSPM.u;
    S.tail = 1;
    S.detail = 1;
    S.glass.colourbar = 1;
    S.glass.cmap = 'winter';
    %S.glass.detail = 2;
    figure
    [h, t_img] = mes_go_mri2glass(S);

%     all_t_img(:,:,:,s) = t_img;
%     
%     t_thresh(s)=xSPM.u;

end


%% take minimum t stat across participants for each voxel

% all_min_t = min(all_t_img,[], 4);
% 
% %plot
% 
% 
% S = [];
% S.mri  = [SPMpath,'spmT_0002.nii']; %just use for MNI locs (hdr)
% S.map = all_min_t;
% S.threshold = min(t_thresh);
% S.tail = 1;
% S.detail = 1;
% S.glass.colourbar = 1;
% S.glass.cmap = 'winter';
% 
% figure
% h = mes_go_mri2glass_group(S);
% 
% 
% % plot
% 
% % hdr = spm_vol(S.mri);
% % img = spm_read_vols(hdr);
% % 
% % % get the locations
% % [x y z] = ind2sub(hdr.dim,ids);
% % mni_locs = hdr.mat * [x  y z ones(size(z))]';
% % mni_locs  = mni_locs(1:3,:)';





