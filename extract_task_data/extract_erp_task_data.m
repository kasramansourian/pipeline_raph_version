function [behavior, raw_data, start_time, end_time, task_version] = extract_erp_task_data(behavjson_fullpath)

if contains(behavjson_fullpath,'.json')
    raw_data = loadjson(behavjson_fullpath);

    % setting task version
    task_version = raw_data{1,1}.git.ref;
    % task_version = '96631687d2eecf9f3044c689b4fe6283c8ff8f55';

    % define start and end time elapsed values
    json_start_ind = 6;
    json_end_ind = 8;
    
    % calculate time elapsed from JSON file
    start_elapsed_time = (raw_data{json_start_ind}.time_elapsed - raw_data{1}.time_elapsed);
    end_elapsed_time = (raw_data{json_end_ind}.time_elapsed - raw_data{1}.time_elapsed);

    task_start = datetime(raw_data{1,7}.start_date, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z', 'TimeZone', 'UTC-00:00');
    task_start.TimeZone = 'UTC-05:00';
    start_time = posixtime(task_start)*1e3 + start_elapsed_time;
    end_time = posixtime(task_start)*1e3 + end_elapsed_time;

    behavior = table([start_time;end_time], [15;1], ["Task Start";"Task End"],...
        'VariableNames',{'Timestamp','Event_Code','Note'});

else
    opts = detectImportOptions(behavjson_fullpath);
    opts = setvartype(opts,'Entry','char'); 
    raw_data = readtable(behavjson_fullpath, opts);

    % setting task version to hash
    if strcmp(raw_data.Entry{1}, 'Task Start')
        task_version = '96631687d2eecf9f3044c689b4fe6283c8ff8f55';
    else
        task_version = raw_data.Entry{1};
    end

    % converting timestamps to unix format
    try
        timestamps = datetime(raw_data.Timstamp, 'InputFormat', 'yyyy-MM-dd_HH_mm_ss_SS_Z', 'TimeZone', 'America/Chicago');
    catch
        timestamps = datetime(raw_data.Timstamp, 'InputFormat', 'yyyy-MM-dd_HH:mm:ss.SS_Z', 'TimeZone', 'America/Chicago');
    end
    timestamps_unix = posixtime(timestamps).*1e3;
    start_time = timestamps_unix(1);
    end_time = timestamps_unix(end);

    % converting events into respective numerical event markers
    events_map = containers.Map({'Start','Note','Notes','SUDS'}, [10,1,1,2]);
    event_markers = cell2mat(cellfun(@(x) events_map(x),raw_data.Event,'UniformOutput',false));
    
    behavior = table(timestamps_unix, event_markers, raw_data.Entry,...
        'VariableNames',{'Timestamp','Event_Code','Note'});
end 
end