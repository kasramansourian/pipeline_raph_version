data.paths.path_to_eeg = '/Users/raphaelb/Documents/UW/Research/gridlab/DBS psychiatric/data/Percept/004/2024-08-20/EEG/PAAT.eeg'
data.task = 'PAAT';
data = extract_eeg(data);
fs = 5000;
eeg = data.brainvision.trial{1, 1} ;
t = (1:length(eeg(5,:)))/fs;
y = eeg(5,:);

y_envelope = envelope(y,128,'peak');
stim_toggle_bool = abs(zscore(y_envelope)) > 7; 
% [pks_OFF,locs_OFF] = findpeaks(-diff([y_envelope(1),y_envelope]), ...
%     'Sortstr','descend', ...
%     'NPeaks',10, ...
%     'MinPeakDistance',fs*1.2);
% [pks_ON,locs_ON] = findpeaks(diff([y_envelope(1),y_envelope]), ...
%     'Sortstr','descend', ...
%     'NPeaks',10, ...
%     'MinPeakDistance',fs*1.2);

% figure; plot(t/60,y_filt)
figure; hold on;
plot(t/60,y)
plot(t/60,y_envelope)
plot(t/60,stim_toggle_bool*1000)

% scatter(t(locs_OFF)/60,y_envelope(locs_OFF))
% scatter(t(locs_ON)/60,y_envelope(locs_ON))
% 
% figure; hold on;
% plot(t/60,y)
% y_envelope = envelope(y,64,'peak');
% plot(t/60,y_envelope)