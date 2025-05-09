function data = performNormalization(timeVec, data, baseline, baselinetype)

baselineTimes = false(size(baseline,1),numel(timeVec));
for k = 1:size(baseline,1)
  baselineTimes(k,:) = (timeVec >= baseline(k,1) & timeVec <= baseline(k,2));
end

if length(size(data)) ~= 3
  ft_error('time-frequency matrix should have three dimensions (chan,freq,time)');
end

% compute mean of time/frequency quantity in the baseline interval,
% ignoring NaNs, and replicate this over time dimension
if size(baselineTimes,1)==size(data,2)
  % do frequency specific baseline
  meanVals = nan+zeros(size(data));
  for k = 1:size(baselineTimes,1)
    meanVals(:,k,:) = repmat(nanmean(data(:,k,baselineTimes(k,:)), 3), [1 1 size(data, 3)]);
  end
else
  meanVals = repmat(nanmean(data(:,:,baselineTimes), 3), [1 1 size(data, 3)]);
end

if (strcmp(baselinetype, 'absolute'))
  data = data - meanVals;
elseif (strcmp(baselinetype, 'relative'))
  data = data ./ meanVals;
elseif (strcmp(baselinetype, 'relchange'))
  data = (data - meanVals) ./ meanVals;
elseif (strcmp(baselinetype, 'normchange')) || (strcmp(baselinetype, 'vssum'))
  data = (data - meanVals) ./ (data + meanVals);
elseif (strcmp(baselinetype, 'db'))
  data = 10*log10(data ./ meanVals);
elseif (strcmp(baselinetype,'zscore'))
    stdVals = repmat(nanstd(data(:,:,baselineTimes),1, 3), [1 1 size(data, 3)]);
    data=(data-meanVals)./stdVals;
else
  ft_error('unsupported method for baseline normalization: %s', baselinetype);
end