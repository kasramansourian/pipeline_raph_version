function [behavior,raw_dat,start_time,end_time,task_version] = extract_resting_task_data(behavjson_fullpath)
    % if data is length 16, then delete 2nd cell... added a screen to
    % remind to set tablet volume (code is written assuming this isn't
    % there
    raw_dat = loadjson(behavjson_fullpath);
    task_version = raw_dat{1, 1}.git.ref;

    if length(raw_dat)==16
        raw_dat(2) = [];
    end
    % All trials relevant to the task have a value or 0/1 field in their JSON object
    trial_inds = find(arrayfun(@(x) isfield(x{1}, 'value') || isfield(x{1}, 'x0x30_'), raw_dat));
    trials = raw_dat(trial_inds);
    behavior = zeros(31,3);
    count = 1;
    task_start_time = datetime(raw_dat{1, 7}.start_date, 'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSS''Z''','Format','yyyy-MM-dd HH:mm:ss.SSSSSSSS ZZZZ','TimeZone','UTC-00:00');
    task_start_time_unix = convertTo(task_start_time,'posix')*1e3;
    
    latest_event = [task_start_time_unix,0,0];
    for i=1:length(trials)
        start = raw_dat{trial_inds(i)-1}.time_elapsed + task_start_time_unix;
        if isfield(trials{i}, 'value')
            % For saccade trials, loop through all and add to behvavior
            for j=1:length(trials{i}.value.data)
                try 
                    behavior(count,:) = [trials{i}.value.data{j}.timestamp, start + trials{i}.value.data{j}.rt,trials{i}.value.data{j}.code];
                catch ME
                    behavior(count,:) = [trials{i}.value.data(j).timestamp, start + trials{i}.value.data(j).rt,trials{i}.value.data(j).code];
                end
                latest_event = behavior(count,:);
                count = count+1;
            end
        else
            % For blinks/eyes closed, add start and ends
            rt_time_30 = start + trials{i}.x0x30_.rt;
            behavior(count,:) = [rt_time_30,0,trials{i}.x0x30_.code];
            count = count+1;
            rt_time_31 = start + trials{i}.x0x31_.rt;
            behavior(count,:) = [ rt_time_31, 0, trials{i}.x0x31_.code];
            count = count+1;
        end
    end
    behavior(:,2) = behavior(:,1) - task_start_time_unix;
    behavior(behavior(:,2)<0,2) = 0;
    if length(behavior) < 50 %Resting
        % Compute the start and end for the 1.5 minute rest
        timestamp_30 = ((behavior(29,1) - raw_dat{13}.time_elapsed) ) + behavior(29,2);
        behavior(30,:) = [timestamp_30,(raw_dat{13}.time_elapsed),10 ];
        timestamp_31 = ((raw_dat{14}.time_elapsed) - behavior(30,1)) + behavior(30,2);
        behavior(31,:) = [timestamp_31,raw_dat{14}.time_elapsed,11];
        behavior = table(behavior(:,1),behavior(:,2),behavior(:,3),repmat("",size(behavior(:,3))),'VariableNames',{'Timestamp','Task_Time','Event_Code','event_name'});
        json_start_ind = trial_inds(1)-1;
        json_end_ind = 14;
    else %Movement 
        % add event annotation
        n_events = size(behavior,1);
        icount_8 = 0;
        icount_9 = 0;
        txt_action_list = {...
            'tap INS', ...
            'tap lead extension', ...
            'deep breath', ...
            'chew', ...
            'cough', ...
            'swallow', ...
            'clench jaw', ...
            'body twist', ...
            'raise left arm 3 times', ...
            'raise right arm 3 times', ...
            'tap feet'};
        event_name = cell(n_events, 1);
        for i_event = 1:n_events
            switch behavior(i_event,3)
                case 1
                    event_name{i_event, 1} = 'left fixation onset';
                case 2
                    event_name{i_event, 1} = 'right fixation onset';
                case 3
                    event_name{i_event, 1} = 'up fixation onset';
                case 4
                    event_name{i_event, 1} = 'down fixation onset';
                case 5
                    event_name{i_event, 1} = 'center fixation onset';
                case 6
                    event_name{i_event, 1} = 'yawn onset';
                case 7
                    event_name{i_event, 1} = 'yawn offset';
                case 8
                    icount_8 = icount_8+1;
                    event_name{i_event, 1} = sprintf('%s onset', txt_action_list{icount_8});
                case 9
                    icount_9 = icount_9+1;
                    event_name{i_event, 1} = sprintf('%s offset', txt_action_list{icount_9});
            end
        end
        Event_Code = behavior(:,3);
        Timestamp = behavior(:,1);
        Task_Time = behavior(:,2);
        behavior = table(Timestamp, Task_Time, Event_Code, event_name);
        json_start_ind = trial_inds(1)-1;
        json_end_ind = 35;
    end

    % calculate time elapsed from JSON file

    if behavior.Task_Time(1) ~= 0
        task_start_event = table(behavior.Timestamp(1) - (behavior.Task_Time(1) * 1e3), 0, 0,"Start Task",'VariableNames',{'Timestamp','Task_Time','Event_Code','event_name'});
        behavior = [task_start_event; behavior];
    end

    time_elapsed_start = (raw_dat{json_start_ind}.time_elapsed - raw_dat{1}.time_elapsed);
    time_elapsed_end = (raw_dat{json_end_ind}.time_elapsed - raw_dat{1}.time_elapsed);

    start_time = behavior.Timestamp(1);
    end_time =  behavior.Timestamp(end);

end
