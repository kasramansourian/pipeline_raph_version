%function [r,thresh,EEG_trial_ts] = get_photodiode_pulse_indices(EEGsync_fname, loaddir_EEGsync,photodiode_flash_seconds);
analog_all = zeros(length(event{1}),4);
preprocessing=data.preprocessing;
photodiode_flash_seconds = 100;
p_file=1;
% photodiode channel
j = [1,2,3,4];
%j = [1,2,3,4];
for i = 1:4
    ii = j(i);
    Ch1 = event{ii};

    % choose amount of data to normalize to
    baseline = 1:20*fs;

    % normalize data
    Ch1_norm = (Ch1-min(Ch1))/(max(Ch1)-min(Ch1));

    if ~exist('ev_thresh') || length(ev_thresh)<4
        if ~isempty(fieldnames(preprocessing(p_file))) && isfield(preprocessing(p_file), 'ev_thresh')
            ev_thresh = preprocessing(p_file).ev_thresh;
        else
            % assign threshold to be 5 std above the mean
            figure;
            plot(Ch1_norm)
            title("Event Norm")
            prompt = 'Manually estimate threshold for event code crossings based on figure.';
            ev_thresh(i) = input(prompt);
        end
    end

    %thresh = (mean(Ch1_norm(baseline))+2000*std(Ch1_norm(baseline)));

    % find first threshold crossing
    % How to handle empty channel?
    temp = find(Ch1_norm>ev_thresh(i));
    if ~isempty(temp)
        first_crossing = temp(1);

        % define length of sequence plus padding
        %photodiode_flash_seconds = PD_spot_blinktime;
        clock_sample_length = photodiode_flash_seconds*fs;
        %seq_length = 46*clock_sample_length;

        % define range that we will look for threshold crossings
        %r = (first_crossing+seq_length):size(Ch1,1);
        r = (first_crossing):size(Ch1,1);

        % look for threshold crossings within the range & define high to low
        % crossings
        analog = Ch1_norm(r)>ev_thresh(i);
        analog_ones = find(analog==1);
        length_analog_ones = diff(analog_ones);
        high_to_low_ind = analog_ones(find(length_analog_ones>1));
        % eliminate false crossings 
        pass = length_analog_ones(find(length_analog_ones>1));
        %faux_pass = pass < fs/(.25*clock_sample_length); % if the signal crossed the 
        % threshold for a short amount of time, it does not count
        %high_to_low_ind(faux_pass) = []; % so eliminate it from the list
        high_to_low_ind = [high_to_low_ind;analog_ones(end)]; % and include the last high to low transition

        % look for threshold crossings within the range & define low to high
        % crossings
        analog_zeros = find(analog==0);
        length_analog_zeros = diff(analog_zeros);
        low_to_high_ind = analog_zeros(find(length_analog_zeros>1));
        pass = length_analog_zeros(find(length_analog_zeros>1));
        faux_pass = pass < fs/100; %100
        low_to_high_ind(faux_pass) = [];

        %photodiode_pulse_inds = [low_to_high_ind,high_to_low_ind];

        %figure for sanity check
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

        % find MSIT task
        % A = pass<50;
        % out = zeros(size(A));
        % ii = strfind([0,A(:)'],[0 1]);
        % out(ii) = strfind([A(:)',0],[1 0]) - ii + 1;
        % 
        % rest_i = find(out==12);
        % msit_i = find(out==11);
        % beads_i = find(out==14);
        % provoc_i = find(out==13);


        analog_all(:,i) = 2^(i-1)*[zeros(r(1)-1,1);analog];
    end
end

event_codes = sum(analog_all,2);
A = event_codes;
for i = 1:14
    ind = find(A==i);
    temp = diff(find(A==i));
    consec = temp==1;
    
    a = ind;
    n = 1; %  number consecutive numbers
    k = [true;diff(a(:))~=1 ];
    s = cumsum(k);
    x =  histc(s,1:s(end));
    idx = find(k);
    out = a(idx(x>n));
    for j = 1:size(out,1)
        del = (out(j)+1):(out(j)+x(j)-1);
        event_codes(del) = zeros(size(del,2),1);
    end
% next connect subsequent samples with a line
end

if ~isempty(fieldnames(preprocessing(p_file))) && isfield(preprocessing(p_file), 'remove_ev')
    remove_ev = preprocessing(p_file).remove_ev;
else
    prompt = 'Manually identify serial port initialization periods (in minutes) on figure.';
    remove_ev = input(prompt);
end
for i = 1:size(remove_ev,1)
    event_codes(round(fs*60*remove_ev(i,1))+1:round(fs*60*remove_ev(i,2))+1) = 0;
end

if strcmp(date,'2018-11-26')
    remove_ev = [1.8,2];
    event_codes(round(fs*60*remove_ev(i,1))+1:round(fs*60*remove_ev(i,2))+1) = 0;
end

if ~isempty(fieldnames(preprocessing(p_file))) && isfield(preprocessing(p_file), 'missing_ev')
    missing_ev = preprocessing(p_file).missing_ev;
else
    prompt = 'Missing task identifier events? (task identifier, time in minutes)';
    missing_ev = input(prompt);
end
for i = 1:size(missing_ev,1)
    event_codes(round(fs*60*missing_ev(i,2))+1) = missing_ev(i,1);
end
