function [start_str,end_str] = time_in_sec_to_hms_string(video_start_time,video_end_time);


start_h = floor(video_start_time/60/60);
if start_h<1
start_m = floor(video_start_time/60);
else
start_m = floor(video_start_time/60)-60*start_h;
end
start_s = video_start_time - start_m*60 - start_h*60*60;

snum_h = numel(num2str(floor(start_h)));
snum_m = numel(num2str(floor(start_m)));
snum_s = numel(num2str(floor(start_s)));

end_h = floor(video_end_time/60/60);
if end_h<1
    end_m = floor(video_end_time/60);
else
    end_m = floor(video_end_time/60)-60*end_h;
end

end_s = video_end_time - end_m*60 - end_h*60*60;

enum_h = numel(num2str(floor(end_h)));
enum_m = numel(num2str(floor(end_m)));
enum_s = numel(num2str(floor(end_s)));

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
