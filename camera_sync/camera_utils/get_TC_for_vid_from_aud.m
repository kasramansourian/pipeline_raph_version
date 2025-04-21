function [time, frame] = get_TC_for_vid_from_aud(start_tc, start_frame, audio_index, audio_fs)
    % Gets the timecode corresponding to an index in the low resolution
    % audio file by converting the position to the nearest frame and time
    timestamp = start_tc(1)*60*60+start_tc(2)*60+start_tc(3)+start_frame/30;
    total_offset = timestamp+audio_index/audio_fs;
    hours_offset = floor(total_offset/(60*60));
    minutes_offset = floor(total_offset/60)-hours_offset*60;
    seconds_offset = floor(total_offset)-minutes_offset*60-hours_offset*60*60;
    frame = floor((total_offset-floor(total_offset))*30);
    time = [hours_offset, minutes_offset, seconds_offset];
end