function [toggle_sample_number, toggle_bool] = find_lfp_toggles(x,fs,resample_fs)
%FIND_TOGGLE Summary of this function goes here
%   Detailed explanation goes here

    % x(isnan(x)) = 0;
    [x,x_fill_bool] = fillmissing(x,'pchip');

    bandpass_150 = designfilt('bandpassiir','FilterOrder',2, ...
         'HalfPowerFrequency1',40,'HalfPowerFrequency2',124.9, ...
         'SampleRate', fs);
    
    %filter the data with each bandpass
    bandpass_tmp = filtfilt(bandpass_150,x);
    [x_envelope_upper,x_envelope_lower] = envelope(x,64,'rms');
    x_up_env_z_diff = zscore([0,diff(bandpass_tmp)]);    
    [pks,locs] = findpeaks(-x_up_env_z_diff, ...
        'Sortstr','descend', ... 
        'MinPeakDistance', fs*.7);

    %Only keep the largest 8 artifacts that are within +-8 seconds if the
    %largest largest. This is to remove other artifacts in the recording
    %being detected as toggles.
    identified_toggles_close_in_time = false;
    if length(locs) < 8
        toggle_sample_number = [];
        toggle_bool = [];
    end
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
    
%     figure; hold on;
%     plot(abs(x_up_env_z_diff));
%     plot(zscore(x_up_env_z_diff));
%     plot(x/max(x)-1);
%     scatter(locs,pks)
%     legend('Derivative of EKG Upper Envelope','EKG Upper Envelope','EKG (Scaled for Display)','Toggle Points')
%     title('Identfied Toggle Locations from Signal')
    % 
    toggle_sample_number = sort(locs)*(resample_fs/fs);
    toggle_bool = zeros(length(x)*(resample_fs/fs),1);
    for i = [1,3,5,7]
        toggle_bool(toggle_sample_number(i):toggle_sample_number(i+1)) = 1;
    end

end

