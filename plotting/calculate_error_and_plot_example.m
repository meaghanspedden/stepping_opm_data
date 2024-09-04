% Calculate y error and plot example of endpoint and box

datdir='D:\STEPPING\sub-OP00159\ses-001\beh';
addpath(datdir)
save_dir='D:\STEPPING\stepping paper\Sci data paper';

SubjectIDs={'00159'};

plotop=0; % Plotting option (plot example in paper, for 159)
nsteps=30; % Per block
runs=1:6;
nruns=length(runs);

%% Function to handle plotting
function plotExampleFigure(endpoints, boxYs, boxrad, boxYtoplot)
    figure;
    hold on;
    % Plot the box position
    patch([-boxrad -boxrad boxrad boxrad],...
        [boxYtoplot-boxrad boxYtoplot+boxrad boxYtoplot+boxrad boxYtoplot-boxrad],'m');
    
    for k=1:length(boxYs)
        thisboxY = boxYs(k);
        if thisboxY == boxYtoplot
            theta = linspace(0, 2*pi, 100); % Parameter for circle
            radius = 0.015; % Circle radius in data units
            x_circle = endpoints(k, 1) + radius * cos(theta); % X coordinates
            y_circle = endpoints(k, 2) + radius * sin(theta); % Y coordinates
            patch(x_circle, y_circle, 'b', 'EdgeColor', 'k', 'FaceAlpha', 0.7); % Blue filled circle
        end
    end
    xlim([-0.6 0.6]);
    ylim([-0.2 1]);
    axis equal;
    hold off;
end

%% Main loop for subjects
for jj=1:length(SubjectIDs)
    Subject = SubjectIDs{jj};
    
    % Preallocate
    y_error = zeros(nruns, nsteps);
    
    for j=1:nruns
        cd(datdir)
        
        filesAndFolders = dir('sub*.tsv');
        files = filesAndFolders(~[filesAndFolders.isdir]);
        fileNames = {files.name};
        thisrun = find(contains(fileNames, sprintf('run-00%g', j)));
        
        % Load file
        fileID = fopen(fileNames{thisrun});
        dat = textscan(fileID, '%.8f %s %f %f %f %f', 'Delimiter', ';');
        fclose(fileID);
        
        %% Extract data
        headers = dat{:, 2}; % Column 2 contains headers Mode/trig/trialend/marker etc.
        timestamps = dat{:, 1}; % Time stamps
        xcoords = dat{:, 3}; % X coordinates (and mode numbers)
        ycoords = dat{:, 4}; % Y coordinates
        
        trialends = find(strcmp(headers, 'TrialEnd'));
        if length(trialends) ~= nsteps
            fprintf('Not expected nr steps !!')
        end
        
        %% Find user xy just before trial end
        endpoints = [];
        
        for mm = 1:length(trialends) % Get user endpoints
            ind_userxy = trialends(mm) - 1; % Index of row just above (standing still)
            
            if ~strcmp(headers(ind_userxy), 'UserXY')
                disp('No user xy just before trial end')
                endpoints = [endpoints; NaN NaN];
            else
                endpoints = [endpoints; xcoords(ind_userxy) ycoords(ind_userxy)];
            end
        end
        
        % Error in y direction
        BoxPosI = find(contains(headers, 'BoxPos')); % Box position
        boxYs = xcoords(BoxPosI); % This is correct (only y position printed, so in 'x coords col')
        
        y_error(j, :) = abs(endpoints(:, 2) - boxYs);
        
        boxrad = 0.03; % For plotting
        boxYtoplot = .43; % To make example figure
        
        if plotop
            plotExampleFigure(endpoints, boxYs, boxrad, boxYtoplot);
        end
        
    end % Runs loop
    
    y_errorall = y_error(:);
    figure;
    histogram(y_errorall)
    
    savename = sprintf('Sub%s_step_error', Subject);
    cd(save_dir)
    save(savename, 'y_error')
    
    close all
    
end % Subject loop
