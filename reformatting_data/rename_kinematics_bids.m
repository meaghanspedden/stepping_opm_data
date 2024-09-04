% MATLAB Script to Rename Kinematics Files to BIDS Format Without Loading

% Define the subject, block, and base directory
subject_id = '159'; % Change this to the specific subject ID you want to process
block_number = '6'; % Change this to the specific block number you want to process
input_directory = 'D:\STEPPING\sub-OP00159\ses-001\beh'; % Specify your input directory
output_directory = 'D:\STEPPING\sub-OP00159\ses-001\beh'; % Specify your output directory

% Construct the input filename based on the current naming convention
input_filename = sprintf('Subj_%s_VGstepping_Block_%s_*.txt', subject_id, block_number);
input_filepath = fullfile(input_directory, input_filename);

% Use dir to find the file (assuming there is only one matching file per block)
file_info = dir(input_filepath);

if isempty(file_info)
    error('No file found for Subject %s, Block %s.', subject_id, block_number);
elseif length(file_info) > 1
    error('Multiple files found for Subject %s, Block %s. Please check the filenames.', subject_id, block_number);
end

% Create the BIDS-compliant filename
sub_label = sprintf('sub-OP00%s', subject_id);
ses_label = 'ses-001';
task_label = 'task-stepping';
run_label = sprintf('run-00%s', block_number);
recording_label = 'recording-kinematics';
bids_filename = sprintf('%s_%s_%s_%s_%s_beh.tsv', sub_label, ses_label, task_label, run_label, recording_label);

% Construct the full paths for renaming
input_fullpath = fullfile(input_directory, file_info.name);
output_fullpath = fullfile(output_directory, bids_filename);

% Rename (move) the file
movefile(input_fullpath, output_fullpath);

% Display a message indicating success
fprintf('File %s has been renamed to %s\n', file_info.name, bids_filename);
