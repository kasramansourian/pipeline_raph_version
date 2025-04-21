cam_index=1;
task_name = lower(data.task);

[sync_beep,fs_beep]=audioread([data.paths.code_path 'utils/camera_sync/camera_utils/task_beeps/' task_name_temp,'.wav']);



if contains(task_name,'programming')
    sync_beep_temp = sync_beep(6.3e4:8.1e4,1);
elseif contains(task_name, 'provocation')
    sync_beep_temp = sync_beep(50000:80000,1);
elseif contains(task_name, 'beads')
    sync_beep_temp=sync_beep(700:2.072e4,1);
elseif contains(task_name, {'msit', 'MSIT'})
    sync_beep_temp=sync_beep(1.756e4:4.331e4,1);
elseif contains(task_name, 'resting-state1')
    sync_beep_temp=sync_beep(2.16e4:4.396e4,1);
elseif contains(task_name, 'resting-state2')
    sync_beep_temp=sync_beep(1.086e4:3.495e4,1);
elseif contains(task_name, 'interview')
    sync_beep_temp=sync_beep(2.358e4:4.714e4,1);
elseif contains(task_name, 'erp')
    sync_beep_temp=sync_beep(2.852e4:4.666e4,1);
elseif contains(task_name, {'TSST', 'tsst'})
    sync_beep_temp=sync_beep(2.591e4:4.422e4,1);
elseif contains(task_name, 'movement')
    sync_beep_temp=sync_beep(4.856e4:6.716e4,1);
elseif contains(task_name, 'adaptive')
    sync_beep_temp=sync_beep(4.681e4:6.501e4,1);
elseif contains(task_name, 'amplitude')
    sync_beep_temp=sync_beep(2.203e4:4.476e4,1);
elseif contains(task_name, 'ramping')
    sync_beep_temp=sync_beep(2.208e4:4.228e4,1);
end

task_code = data.constants.task_dictionary({data.task});

str_events = {data.Events.Event};
for i = 1:length(str_events)
    temp_event = str_events{i};
    num = regexp(temp_event,'\d');
    temp_event = str2num(temp_event(num));
    if task_code ==temp_event
        % get event index where task event was sent (15)
        task_event_index = data.events(i+1).sample;
    end
end
% use start time in data reference -- subtract task event index =
% correction_val_start
correction_val_start = data.data_reference{2,2} - task_event_index;

% use end time in data reference -- subtract task event index =
% correction_val_end
correction_val_end = data.data_reference{2,3} - task_event_index;


% Find video file corresponding to the audio/ephys
find_sync_video;




