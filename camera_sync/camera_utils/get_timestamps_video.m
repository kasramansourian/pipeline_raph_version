
function simple_stim_log = get_timestamps_video(simple,start_time,end_time)
simple_stim_log = simple;
temp_ind = find(and(simple_stim_log.Time >= start_time, simple_stim_log.Time <= end_time));
if min(temp_ind) > 1
    temp_ind = [min(temp_ind)-1; temp_ind];
end
simple_stim_log = simple_stim_log(temp_ind,:);

for i = 1:height(simple_stim_log)
    time = max(0,seconds((simple_stim_log.Time(i)-start_time)/1000));
    time.Format = 'mm:ss.SSS';
    simple_stim_log.Video_Timestamp(i) = time;
end
end
 