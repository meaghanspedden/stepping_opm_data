function fieldtrip_data = load_emg_bids_tsv(tsv_file, json_file)
    % Read the JSON file to get the metadata
    json_data = jsondecode(fileread(json_file));
    
    % Read the TSV file
    tsv_data = readtable(tsv_file, 'FileType', 'text');
    
    % Extract the time and EMG signal from the table
    time = tsv_data.time;
    emg_signal = tsv_data{:, 2}; % Assuming the second column is the EMG signal
    trigger_signal = tsv_data.trigger; % Assuming the third column is the trigger
    
    % Prepare the FieldTrip data structure
    fieldtrip_data = [];
    fieldtrip_data.trial = {emg_signal'};
    fieldtrip_data.time = {time'};
    fieldtrip_data.label = {json_data.Electrode};
    fieldtrip_data.fsample = json_data.SamplingFrequency;
    fieldtrip_data.chanunit = {json_data.Units};
    
    % Optional: If you want to include the trigger as an additional channel
    fieldtrip_data.trial{1}(2, :) = trigger_signal';
    fieldtrip_data.label{2} = 'Trigger'; % Adding a label for the trigger channel
    fieldtrip_data.chanunit{2} = ''; % Unit for the trigger channel can be left empty
end
