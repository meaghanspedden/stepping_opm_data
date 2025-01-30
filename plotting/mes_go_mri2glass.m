function [h, t_img] = mes_go_mri2glass(S)



% Usage
% S - options stucture
% S.mri - path to MRI (already in MNI space)
% S.threshold - takes value betwene 0-1, where 1 is peak value only.
% S.tail - Do you want +ve values (1), -ve (-1), or both? (0, default)
% S.mask - path addional masking of MRI map (assumes also in MRI space)

if ~isfield(S,'mri'); error('please supply a path to an MRI'); end
if ~isfield(S,'threshold'); S.threshold = eps; end
if ~isfield(S, 'tail'); S.tail = 0; end

hdr = spm_vol(S.mri);
img = spm_read_vols(hdr);

if isfield(S,'mask')
    maskhdr = spm_vol(S.mask);
    mask = spm_read_vols(maskhdr);
    img = img .* mask;
end


switch S.tail
    case 0
        max_stat = max(abs(img(:)));
        [sorted_stat, ids] = sort(abs(img(:)),'descend');
        cutoff = find(sorted_stat < S.threshold,1,'first');
    case 1
        max_stat = max(img(:));
        [sorted_stat, ids] = sort(img(:),'descend');
        cutoff = find(sorted_stat < S.threshold,1,'first');
    case -1
        max_stat = max(-img(:));
        [sorted_stat, ids] = sort(-img(:),'descend');
        cutoff = find(sorted_stat < S.threshold,1,'first');
end

ids = ids(1:cutoff);
stats = img(ids);

% get the locations
[x y z] = ind2sub(hdr.dim,ids);
mni_locs = hdr.mat * [x  y z ones(size(z))]';
mni_locs  = mni_locs(1:3,:)';

glass = [];
if isfield(S,'glass')
    glass = S.glass;
end

if numel(stats) == 1
    h=[];
    t_img=zeros(size(img));
else

h = spm_glass(stats,mni_locs,glass);

t_img=img;
end