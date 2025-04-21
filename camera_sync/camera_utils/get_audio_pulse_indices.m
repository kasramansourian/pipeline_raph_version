function [first_crossing_open_ephys,Ch1_norm] = get_audio_pulse_indices(TC,fs)
%fs = 00;
% photodiode channel
Ch1 = TC;
PD_spot_blinktime = 1e3;
% choose amount of data to normalize to
baseline = 1:20*fs;

ws = 10000;
Ch1_new_all = zeros(length(Ch1),1);
for i = 1:ceil(length(Ch1)/ws)
    if i ==ceil(length(Ch1)/ws)
        Ch1_temp = Ch1((ws*(i-1)+1):length(Ch1)); % correct DC offset (if there is no DC offset, comment out)
        Ch1_new = Ch1_temp-mean(Ch1_temp);
        Ch1_new_all((ws*(i-1)+1):length(Ch1)) = Ch1_new;
    else
        Ch1_temp = Ch1((ws*(i-1)+1):(i*ws)); % correct DC offset (if there is no DC offset, comment out)
        Ch1_new = Ch1_temp-mean(Ch1_temp);
        Ch1_new_all((ws*(i-1)+1):(i*ws)) = Ch1_new;
    end
    
end

%sanity check
figure;
plot(Ch1_new_all)
    
Ch1 = Ch1_new_all;

% normalize data
Ch1_norm = (Ch1-mean(Ch1(baseline)))/std(Ch1(baseline));

figure;
plot(Ch1_norm)
% assign threshold to be 5 std above the mean
if ~exist('pd_thresh')
prompt = 'Manually estimate threshold for audio crossings based on figure.';
thresh = input(prompt);
pd_thresh = thresh;
end
%thresh = (mean(Ch1_norm(baseline))+50*std(Ch1_norm(baseline)));

% find first threshold crossing
temp = find(Ch1_norm>pd_thresh);
first_crossing = temp(1);
first_crossing_open_ephys = first_crossing;

% define length of sequence plus padding
photodiode_flash_seconds = PD_spot_blinktime;
clock_sample_length = photodiode_flash_seconds*fs;
%seq_length = 46*clock_sample_length;

% define range that we will look for threshold crossings
%r = (first_crossing+seq_length):size(Ch1,1);
r = (first_crossing):size(Ch1,1);

cross_thresh = fs/1.1;
% look for threshold crossings within the range & define high to low
% crossings
analog = Ch1_norm(r)>pd_thresh;
analog_ones = find(analog==1);
length_analog_ones = diff(analog_ones);
high_to_low_ind = analog_ones(find(length_analog_ones>1));
% eliminate false crossings 
pass = length_analog_ones(find(length_analog_ones>1));
faux_pass = pass < cross_thresh; % if the signal crossed the 
% threshold for a short amount of time, it does not count
high_to_low_ind(faux_pass) = []; % so eliminate it from the list
high_to_low_ind = [high_to_low_ind;analog_ones(end)]; % and include the last high to low transition

% look for threshold crossings within the range & define low to high
% crossings
analog_zeros = find(analog==0);
length_analog_zeros = diff(analog_zeros);
low_to_high_ind = analog_zeros(find(length_analog_zeros>1));
pass = length_analog_zeros(find(length_analog_zeros>1));
faux_pass = pass < cross_thresh;
low_to_high_ind(faux_pass) = [];

%photodiode_pulse_inds = [low_to_high_ind,high_to_low_ind];

%figure for sanity check
figure;
plot(Ch1_norm)
hold on
scatter(low_to_high_ind+r(1),1.5*ones(size(low_to_high_ind,1),1))
hold on
scatter(high_to_low_ind+r(1),1.5*ones(size(high_to_low_ind,1),1))
ax = gca;
ax.XLim = [2.65e5,2.9e5];
% %scatter(low_to_high_ind,100*ones(size(low_to_high_ind,1),1))
% buttons_fname = '100_ADC1.continuous';
% B1 = load_open_ephys_data(strcat(loaddir_EEGsync,buttons_fname));
% buttons_fname = '100_ADC2.continuous';
% B2 = load_open_ephys_data(strcat(loaddir_EEGsync,buttons_fname));
% buttons_fname = '100_ADC3.continuous';
% B3 = load_open_ephys_data(strcat(loaddir_EEGsync,buttons_fname));
% plot(B1)
% hold on
% plot(B2)
% hold on
% plot(B3)
% scatter(fs*(((r(1)+low_to_high_ind(1,1))/fs)+log_pulse_inds),ones(size(log_pulse_inds)))
end
