%Kinematics: extract foot position, filter and save median for plotting

clear all
close all

datdir='D:\STEPPING\sub-OP00054\ses-001\beh';
addpath(datdir)

save_dir='D:\STEPPING\stepping paper\Sci data paper';
addpath('D:\stepping_data_opm')

SubjectID={'00054'};

plotop=1;
nsteps=30; %pr block
runs=1:5;
trlength=350; %trial length used for plotting

allstepsPos=[];


for j=1:length(runs)
   
    cd(datdir)

    filesAndFolders = dir('sub*.tsv');
    files = filesAndFolders(~[filesAndFolders.isdir]);
    fileNames = {files.name};
    thisrun=find(contains(fileNames,sprintf('run-00%g',j)));

    % load file
    fileID = fopen(fileNames{thisrun});
    dat = textscan(fileID,'%f %s %f %f %f %f', 'Delimiter',';');

    fclose(fileID);
    %% extract data

    headers=dat{:,2}; %col 2 contains headers Mode/trig/trialend/marker etc.
    timestamps=dat{:,1}; %time stamps
    xcoords=dat{:,3}; %x coords
    ycoords=dat{:,4}; %y coords (AP=forward-back)

    trialstart=find(strcmp(headers,'TriggerOutStart'));
    trialstop=find(strcmp(headers,'TrialEnd'));

    if length(trialstart)~=nsteps
        fprintf('Not expected nr steps!')
    end

    %% loop through steps
    thisrunpos=[]; %save position for each run
    
    for k=1:nsteps 
       
        %select data for this trial/step
        thisdat_x=xcoords(trialstart(k):trialstop(k));
        thisdat_y=ycoords(trialstart(k):trialstop(k));

        thisstepheaders=headers(trialstart(k):trialstop(k));
        thissteptimestamps=timestamps(trialstart(k):trialstop(k));
        
        % convert time date stamps to seconds from trial start
        seconds_from_start = unique((thissteptimestamps - min(thissteptimestamps)) * 86400);


        todel=find(contains(thisstepheaders,'Marker')); %only use user xy, delete rest
        thisdat_y(todel)=[];

       % y is forward/anterior

        %step_starts = dsearchn(thisdat_y, 1.05*min(thisdat_y));
        %step_stops = dsearchn(thisdat_y,.95*max(thisdat_y));

%         f=figure; plot(seconds_from_start,thisdat_y,'r-') % y is forward
%         vline(seconds_from_start(step_starts))
%         vline(seconds_from_start(step_stops))
%         title(sprintf('trial %g',k))

        %waitfor(f)

        %data is irregularly sampled,interpolate 
        new_seconds_from_start = 0:0.01:max(seconds_from_start); %100 hz
        resampled_data = interp1(seconds_from_start, thisdat_y, new_seconds_from_start, 'pchip');

        %low pass filter at 5 Hz
        Fs=100;
        cutoff_frequency = 5;  % Cutoff frequency 
        filter_order = 5;  
        [b, a] = butter(filter_order, cutoff_frequency / (Fs / 2), 'low');  

        filtered_data = filtfilt(b, a, resampled_data);
        
        %save filtered position vector
        thisrunpos(k,:)=filtered_data(1:trlength);

    end
 
    allstepsPos=[allstepsPos;thisrunpos];

end

%calculate median over steps for plotting
medianValues=median(allstepsPos,1);
time=new_seconds_from_start(1:trlength);

save(fullfile(save_dir,sprintf('med_pos_sub%s',SubjectID{:})), 'medianValues', 'time')

