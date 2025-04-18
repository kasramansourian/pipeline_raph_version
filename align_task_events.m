function [data] = align_task_events(data)
%ALIGN_DATA_STREAMS Summary of this function goes here
%   Detailed explanation goes here
    brainvision_events = data.brainvision.events;
    this_task_events_mask = ([brainvision_events.sample]' >= ...
        data.brainvision.sampleinfo(1)) & ([brainvision_events.sample]' <= ...
    data.brainvision.sampleinfo(2)) & ~([0;diff([brainvision_events.sample]')==1]);
    brainvision_events(~this_task_events_mask)=[];
    is_stimulus = contains({brainvision_events.type}','Stimulus');
    brainvision_events = brainvision_events(is_stimulus);
    brainvision_event_codes = str2double(extractBetween({brainvision_events.value}',3,4));
    index_of_events = [brainvision_events.sample];
    

    pd_mask = cellfun(@(x)strcmpi(x,'PHOTODIODE'),data.brainvision.label);
    photodiode = data.brainvision.trial{1, 1}(pd_mask,:);
    figure; plot(photodiode)
    photo_thresh = input('Threshold: ');
    photodiode_bool = double(photodiode > photo_thresh);
    [~,photodiode_event_inds] = findpeaks(photodiode_bool,'MinPeakWidth',.01*data.brainvision.fsample);  
    photodiode_event_inds = max(1,photodiode_event_inds); 
    brainvision_Timestamp = data.brainvision.brainvision_start_timestamp_unix + data.brainvision.time{1, 1}*1e3;
    brainvision_events_timestamps = brainvision_Timestamp(index_of_events)';
    photodiode_events_timestamps = brainvision_Timestamp(photodiode_event_inds)';
    behavior_events_timestamps = [data.behavior.events.Timestamp]';
    behavior_events_id = [data.behavior.events.Event_Code]';
    [~, task_event_by_eeg_ind] = min(abs(behavior_events_timestamps-brainvision_Timestamp'));
    brainvision_behav_start_diff = behavior_events_timestamps(1)-brainvision_events_timestamps(1);
    behavior_events_timestamps = behavior_events_timestamps - brainvision_behav_start_diff;
    
    unique_events = {}; 
    behav_ind_of_brain_event = zeros(size(brainvision_events_timestamps));
    count = 1;
    no_photodiode_count = 0;
    for i = 1:length(brainvision_events_timestamps)
        current_event_timestamp = brainvision_events_timestamps(i);
        [time_to_nearest_photo_event, nearest_photo_event_ind] = min(abs(photodiode_events_timestamps-current_event_timestamp));
        %Nearest matching BehavEvent is within 150ms
        if time_to_nearest_photo_event  < 150 
            unique_events(count,:) = {photodiode_events_timestamps(nearest_photo_event_ind),brainvision_event_codes(i)};
        else
            unique_events(count,:) = {current_event_timestamp,brainvision_event_codes(i)};
            no_photodiode_count = no_photodiode_count+1;
        end
       
        [min_time_to_nearest, nearest_behav_event_ind] = min(abs(behavior_events_timestamps-unique_events{count,1}));
        if (brainvision_event_codes(i) == behavior_events_id(nearest_behav_event_ind)) && (min_time_to_nearest < 150)
            behav_ind_of_brain_event(count) = nearest_behav_event_ind;
        end
        count = count+1;
    end

    data.Events = table([unique_events{:,1}]',[unique_events{:,2}]','VariableNames',{'Timestamp','Event'});
    data.behavior.events.Timestamp = behavior_events_timestamps';
    data.behavior.first_event_unix_time  = behavior_events_timestamps(1);
    data.behavior.first_event_local_time = datetime(data.behavior.first_event_unix_time, ...
        'ConvertFrom', 'posixtime','Format',data.constants.timestamp_string_format, 'TimeZone', data.constants.houston_timezone);
    
    data.behavior.last_event_unix_time  = behavior_events_timestamps(end);
    data.behavior.last_event_local_time = datetime(data.behavior.last_event_unix_time, ...
        'ConvertFrom', 'posixtime','Format',data.constants.timestamp_string_format, 'TimeZone', data.constants.houston_timezone);
    
    data.brainvision.brainvision_task_start_timestamp_unix = unique_events{1,1};
    data.brainvision.brainvision_task_start_timestamp_local = datetime(unique_events{1,1}/1e3, ...
        'ConvertFrom', 'posixtime','Format',data.constants.timestamp_string_format, 'TimeZone', data.constants.houston_timezone);

    Timestamp = brainvision_Timestamp(table2array(data.brainvision.pupillometry(:,1)))';
    Tobii_Events = table2array(data.brainvision.pupillometry(:,2));
    data.brainvision.pupillometry = table(Timestamp,Tobii_Events);
    % 
    % figure; hold on;
    % plot(brainvision_Timestamp,photodiode/max(photodiode));
    % plot(data.Events.Timestamp,data.Events.Event/21);
    % scatter(behavior_events_timestamps, ones(size(behavior_events_id))+.025,'filled');
    % legend('Photodiode','Brainvision Events','Task File Events')
    % xlabel('Unix Timestamp')
    % title('Events Algined to Photodiode')

end


