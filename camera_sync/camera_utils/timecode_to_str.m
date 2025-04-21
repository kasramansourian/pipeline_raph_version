function [start_str,end_str] =timecode_to_str(timecode_start,timecode_end,video_frame_start,video_frame_end)
% takes in start and stop in format of timecode vector [hr, min, sec] and
% frame number, and converts to time string in format accepted by ffmpeg

% make time strings for start and stop
start_h = timecode_start(1);
start_m = timecode_start(2);
start_s = timecode_start(3)+(video_frame_start/30);

snum_h = numel(num2str(floor(start_h)));
snum_m = numel(num2str(floor(start_m)));
snum_s = numel(num2str(start_s + (video_frame_start/30)));

end_h = timecode_end(1);
end_m = timecode_end(2);
end_s = timecode_end(3)+(video_frame_end/30);

enum_h = numel(num2str(floor(end_h)));
enum_m = numel(num2str(floor(end_m)));
enum_s = numel(num2str(end_s+(video_frame_end/30)));

if snum_h < 2
    temp = strcat('0',num2str(start_h),':');
else
    temp = strcat(num2str(start_h),':');
end
if snum_m < 2
    temp = strcat(temp,'0',num2str(start_m),':');
else
    temp = strcat(temp,num2str(start_m),':');
end
if snum_s <2
    start_str = strcat(temp,'0',num2str(start_s,'%.5f'));
else
    start_str = strcat(temp,num2str(start_s,'%.5f'));
end

if enum_h < 2
    temp = strcat('0',num2str(end_h),':');
else
    temp = strcat(num2str(end_h),':');
end
if enum_m < 2
        temp = strcat(temp,'0',num2str(end_m),':');    
else
    temp = strcat(temp,num2str(end_m),':');
end
if enum_s <2
    end_str = strcat(temp,'0',num2str(end_s));
else
    end_str = strcat(temp,num2str(end_s));
end

end