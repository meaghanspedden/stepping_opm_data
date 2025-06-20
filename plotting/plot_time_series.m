% Inputs
i = best_trial_idx;  % trial index
X = ftdat.time{i}-3;            % time vector (1 x time)
Y = ftdat.trial{i};           % data matrix (57 x time)

n_channels = size(Y,1);

% Determine scaling factor: use robust estimate of signal amplitude
channel_amplitudes = max(Y, [], 2) - min(Y, [], 2);   % peak-to-peak
median_amp = median(channel_amplitudes);              % robust spacing scale
offset = 1.2 * median_amp;                            % add margin to avoid overlap

% Apply offset: higher-numbered channels go lower on the plot
Y_offset = Y + (offset * (n_channels:-1:1))';

% Plot
figure; hold on;
for ch = 1:n_channels
    plot(X, Y_offset(ch, :), 'LineWidth',.7);   % black lines
end
title(sprintf('Trial %d', i));
xlabel('Time (s)');
yticks(offset * (1:n_channels));
box off
set(gca, 'YTick', [], 'YTickLabel', []);

ylim([0, offset * (n_channels+1)]);
