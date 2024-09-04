%Loops through blocks, calculates y errror and hits

datdir='D:\STEPPING\sub-OP00159\ses-001\beh';
addpath(datdir)
save_dir='D:\STEPPING\stepping paper\Sci data paper';

SubjectIDs={'00159'};

plotop=0;%plotting option (plot example in paper, for 159)
nsteps=30; %pr block
runs=1:6;
nruns=length(runs);
%%
for jj=1:length(SubjectIDs)

    Subject=SubjectIDs{jj};

    % preallocate
    y_error=zeros(nruns,nsteps);

    for j=1:nruns

        cd(datdir)

        filesAndFolders = dir('sub*.tsv');
        files = filesAndFolders(~[filesAndFolders.isdir]);
        fileNames = {files.name};
        thisrun=find(contains(fileNames,sprintf('run-00%g',j)));

        % load file
        fileID = fopen(fileNames{thisrun});
        dat = textscan(fileID,'%.8f %s %f %f %f %f', 'Delimiter',';');
        fclose(fileID);
        %% extract data
        headers=dat{:,2}; %col 2 contains headers Mode/trig/trialend/marker etc.
        timestamps=dat{:,1}; %time stamps
        xcoords=dat{:,3}; %x coords (and mode numbers)
        ycoords=dat{:,4}; %y coords

        trialends=find(strcmp(headers,'TrialEnd'));
        if length(trialends)~=nsteps
            fprintf('Not  expected nr steps !!')
        end

        %%
        %Find user xy just before trial end
        endpoints=[];
        if plotop
            f1=figure;
            f1.Position=[680   542   560   454];
            hold on
        end

        for mm=1:length(trialends) %get user endpoints

            ind_userxy=trialends(mm)-1; % index of row just above (standing still)

            if ~strcmp(headers(ind_userxy),'UserXY')
                disp('no user xy just before trial end')
                endpoints=[endpoints; NaN NaN];
            else
                endpoints=[endpoints; xcoords(ind_userxy) ycoords(ind_userxy)];
            end

        end

        %error in y direction
        BoxPosI=find(contains(headers,'BoxPos')); %box position
        boxYs=xcoords(BoxPosI); %this is correct (only y position printed, so in 'x coords col')

        y_error(j,:)=abs(endpoints(:,2)-boxYs);

        boxrad=0.03; %for plotting
        boxYtoplot=.43; %to make example figure

        if plotop
            patch([-boxrad -boxrad boxrad boxrad],...
                [boxYtoplot-boxrad boxYtoplot+boxrad boxYtoplot+boxrad boxYtoplot-boxrad],'m'); hold on
            hold on
        end

        for k=1:length(BoxPosI) %for each box

            thisboxY=boxYs(k); %forward is positive

            if thisboxY==boxYtoplot

                theta = linspace(0, 2*pi, 100); % Parameter for circle
                radius = 0.015; % Circle radius in data units (estimated!)
                x_circle = endpoints(k, 1) + radius * cos(theta); % X coordinates
                y_circle = endpoints(k, 2) + radius * sin(theta); % Y coordinates

                % Draw the circle using patch
                if plotop
                    patch(x_circle, y_circle, 'b', 'EdgeColor', 'k','FaceAlpha',0.7); % Blue filled circle
                    hold on
                    xlim([-0.6 0.6])
                    ylim([-0.2 1])
                    axis equal
                end
            end


        end %steps


    end %runs


    y_errorall=y_error(:);
    figure;
    histogram(y_errorall)

    savename=sprintf('Sub%s_step_error',Subject);
    cd(save_dir)
    save(savename,'y_error')

    close all

end %subject loop