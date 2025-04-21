function [start_tc, start_frame, end_tc, end_frame] = get_video_timecodes(vid_path)
    % Lines 2-16 are adapted from ffmpeginfo to only parse out the timecode
    % get FFMPEG executable
    ffmpegexe = ffmpegpath();

    [s,msg] = system(sprintf('%s %s',ffmpegexe,sprintf('-i "%s" ',vid_path)));

    if s==0
       error('ffmpeginfo failed to run FFmpeg\n\n%s',msg);
    end

    I = regexp(msg,'Input #','start');
    if isempty(I)
       error('Specified file is not FFmpeg supported media file.');
    end

    % remove the no output warning
    msg = regexprep(msg,'At least one output file must be specified\n$','','once');

    % Parse the timecodes from the first record in the video and duration
    time = regexp(msg, "timecode\s*([^\n\r]*)", 'match');
    duration = regexp(msg, "Duration\s*([^\n\r,]*)", 'match');
    times = strtrim(split(time{1}, ':'));
    durations = strtrim(split(duration{1}, ':'));
    timecode = times(2:end);
    start_tc = [str2double(timecode{1}) str2double(timecode{2}) str2double(timecode{3})];
    start_frame = str2double(timecode{4});
    duration = durations(2:end);
    dur_tc = [str2double(duration{1}) str2double(duration{2}) floor(str2double(duration{3}))];
    dur_frame = floor((str2double(duration{3})-floor(str2double(duration{3})))*30);
    [end_tc, end_frame] = add_timecodes(start_tc, dur_tc, start_frame, dur_frame);
end