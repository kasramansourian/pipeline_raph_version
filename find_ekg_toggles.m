function [toggle_sample_number, toggle_bool] = find_ekg_toggles(ekg,fs)
%FIND_TOGGLE Summary of this function goes here
%   Detailed explanation goes here
    
    %pad to remove edge artifact induced from bandpass when signal is zero (detects as false toggles)
    padLength = fs;
    ekg_padded = [ekg(1)*ones(1,padLength), ekg, ekg(end)*ones(1,padLength)];
    x_padded = bandpass(ekg_padded, [240, 260], 5000);
    x = x_padded((padLength+1):(end-padLength));
    
    [~,x_envelope_lower] = envelope(x,2048,'rms');
    x_envelope_lower_padded = [x_envelope_lower(1)*ones(1,padLength), x_envelope_lower, x_envelope_lower(end)*ones(1,padLength)];
    % Define the frequency range of the heartbeat artifact (e.g., 0.8–1.5 Hz)
    artifact_freq = [1 50];  %Range of requency of heart ECG
    % Apply a bandstop filter
    x_envelope_lower_padded = bandstop(x_envelope_lower_padded, artifact_freq, fs);
    x_envelope_lower = x_envelope_lower_padded((padLength+1):(end-padLength));


    %Threshold Envelope to get toggle estimate
    x_envelope_lower = zscore(x_envelope_lower);
    x_envelope_lower = x_envelope_lower - movmean(x_envelope_lower,length(x_envelope_lower)/4); %Remove drift
    
    x_up_env_z_diff = zscore([0,diff(x_envelope_lower)]); 
    [pks,locs] = findpeaks(abs(x_up_env_z_diff), ...
        'Sortstr','descend', ... 
        'MinPeakDistance', fs*.5);

    %Only keep the largest 8 artifacts that are within +-8 seconds if the
    %largest largest. This is to remove other artifacts in the recording
    %being detected as toggles.
    identified_toggles_close_in_time = false;
    while ~identified_toggles_close_in_time
        time_diff_from_largest_artifact = locs(1)-locs(1:8);
        bad_inds = find(abs(time_diff_from_largest_artifact) > 10*fs);
        if bad_inds
            locs(bad_inds) = [];
            pks(bad_inds) = [];
        else
            identified_toggles_close_in_time = true;
            locs = locs(1:8);
            pks = pks(1:8);
        end
    end

    toggle_sample_number = sort(locs);
    toggle_bool = zeros(1,length(x));
    for i = [1,3,5,7]
        toggle_bool(toggle_sample_number(i):toggle_sample_number(i+1)) = 1;
    end


    [toggle_inds,x_envelope_lower_bool] = get_toggles_by_thresholding(toggle_bool);
    


    if isempty(toggle_inds)
        toggle_sample_number = [];
        toggle_bool = [];
        return;
    end

    %Remove any bool that isnt more than 100ms in duration (goal is to keep only 1 second long toggles)
    ind_of_change_points = find([0,diff(x_envelope_lower_bool)]~=0);
    dist_between_pulses = diff(ind_of_change_points);
    dist_between_pulses = dist_between_pulses(1:2:end);
    ind_less = find(~((dist_between_pulses>0) & (dist_between_pulses<500)))*2 - 1;
    start_inds_less_on_envelope = ind_of_change_points(ind_less);
    end_inds_less_on_envelope = ind_of_change_points(ind_less+1);
    x_envelope_lower_bool(:) = 0;
    for i = 1:length(start_inds_less_on_envelope)
        x_envelope_lower_bool(start_inds_less_on_envelope(i):end_inds_less_on_envelope(i))=1;
    end
    

    %Crop signal to include just toggle
    [x_envelope_upper,x_envelope_lower] = envelope(x,32,'peak');
    artifact_freq = [1 50];  %Range of requency of heart ECG
    % Apply a bandstop filter
    x_envelope_lower = bandstop(x_envelope_lower, artifact_freq, fs);
    

    % Define the frequency range of the heartbeat artifact (e.g., 0.8–1.5 Hz)
    
    x_envelope_lower = zscore(x_envelope_lower);
    x_envelope_lower = x_envelope_lower - movmean(x_envelope_lower,length(x_envelope_lower)/3); %Remove drift

    toggle_range = [max(1,find(x_envelope_lower_bool,1,'first')-fs*2),...
    min(find(x_envelope_lower_bool,1,'last')+fs*2,length(x_envelope_lower_bool))];
    x_envelope_lower_to_plot = x_envelope_lower;
    x_envelope_lower = x_envelope_lower(toggle_range(1):toggle_range(2));
    

    [toggle_inds,toggle_bool] = get_toggles_by_thresholding(x_envelope_lower);
    if ~isempty(toggle_inds) && (sum(toggle_bool) >= 2*fs)  %check that was have at least 2 seconds of toggle periods (Should be around 4 seconds in general) catch to remove bad detection
        toggle_sample_number = toggle_inds + toggle_range(1);
        toggle_bool = [zeros(1,toggle_range(1)-1),toggle_bool,zeros(1,length(x)-toggle_range(2))];
        
%         figure; hold on;
%         t = linspace(0,length(x)/fs,length(x));
%         plot(t,zscore(x))
%         plot(t,x_envelope_lower_to_plot)
%         plot(t,toggle_bool)
%         xlabel('Seconds')
%         legend('BandPass EKG','Proccessed Signal Envelope','Toggle Bool');
    else
        toggle_sample_number = [];
        toggle_bool = [];
    end
   

    


end

