function [lfp_time_new,start_toggle_ms_offset,drift,drift_correction_ratio, toggle_aligned] = manual_sync(ekg,ekg_time,lfp,lfp_time,ekg_toggle_range_estimate, lfp_toggle_range_estimate)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    
    start_toggle_ms_offset = 0;
    drift = 0;
    drift_correction_ratio = 1;
    toggle_aligned = [false,false];
    padLength = 5000;
    ekg_padded = [ekg(1)*ones(1,padLength), ekg, ekg(end)*ones(1,padLength)];
    ekg_padded_band = bandpass(ekg_padded, [240, 260], 5000);
    ekg_band = ekg_padded_band((padLength+1):(end-padLength));

    [x_envelope_upper,x_envelope_lower] = envelope(ekg_band,32,'peak');
    artifact_freq = [1 50];  %Range of requency of heart ECG
    % Apply a bandstop filter
    x_envelope_lower = bandstop(x_envelope_lower, artifact_freq, 5000);
    % Define the frequency range of the heartbeat artifact (e.g., 0.8–1.5 Hz)
    x_envelope_lower = zscore(x_envelope_lower);
    x_envelope_lower = x_envelope_lower - movmean(x_envelope_lower,length(x_envelope_lower)/3); %Remove drift

    
    ekg_start_toggle_range = [ekg_time(ekg_toggle_range_estimate(1,1)-5000),ekg_time(ekg_toggle_range_estimate(1,end)+5000)];
    ekg_end_toggle_range = [ekg_time(ekg_toggle_range_estimate(2,1)-5000),ekg_time(ekg_toggle_range_estimate(2,end)+5000)];

    lfp_start_toggle_range = [lfp_time(lfp_toggle_range_estimate(1,1)-250),lfp_time(min(length(lfp_time),lfp_toggle_range_estimate(1,end)+250))];
    lfp_end_toggle_range = [lfp_time(lfp_toggle_range_estimate(2,1)-250),lfp_time(min(length(lfp_time),lfp_toggle_range_estimate(2,end)+250))];

    ekg_toggle_start_sync = manual_syncpoint_identification(ekg_time, x_envelope_upper,ekg_start_toggle_range);
    close;
    ekg_toggle_end_sync = manual_syncpoint_identification(ekg_time, x_envelope_upper,ekg_end_toggle_range);
    close;
    
    lfp_toggle_start_sync = manual_syncpoint_identification(lfp_time, lfp{:,1},lfp_start_toggle_range);
    close;
    lfp_toggle_end_sync =  manual_syncpoint_identification(lfp_time, lfp{:,1},lfp_end_toggle_range);
    close;
    
    start_toggle_ms_offset = ekg_toggle_start_sync - lfp_toggle_start_sync;
    end_toggle_ms_offset = ekg_toggle_end_sync - lfp_toggle_end_sync;

    if ~isnan(start_toggle_ms_offset) && ~isnan(end_toggle_ms_offset)
        lfp_time_new = lfp_time + start_toggle_ms_offset;
        drift = end_toggle_ms_offset - start_toggle_ms_offset;
        ms_from_start_syncpoint = lfp_time_new-lfp_time_new(1);
        drift_correction_ratio = (ms_from_start_syncpoint(end) + drift)/ms_from_start_syncpoint(end);
        lfp_time_new = lfp_time_new(1) + (ms_from_start_syncpoint * drift_correction_ratio);
        toggle_aligned = [true,true];
    elseif ~isnan(start_toggle_ms_offset) && isnan(end_toggle_ms_offset)
        lfp_time_new = lfp_time + start_toggle_ms_offset;
        toggle_aligned = [true,false];

    elseif isnan(start_toggle_ms_offset) && ~isnan(end_toggle_ms_offset)
        lfp_time_new = lfp_time + end_toggle_ms_offset;
        toggle_aligned = [false,true];

    else
        lfp_time_new = lfp_time;
        toggle_aligned = [false,false];

    end

    figure;hold on;
    plot(ekg_time,ekg_band/max(ekg_band))
    plot(lfp_time_new,lfp{:,2}/max(lfp{:,2}))
    scatter(ekg_toggle_start_sync,0,'green')
    scatter(lfp_toggle_start_sync+start_toggle_ms_offset,0.1,'blue')

end

