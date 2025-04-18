function [behavior, raw_data, start_time, end_time,task_version] = extract_simple_task_data(behavjson_fullpath)
    initialize_common_variables;
    raw_data = loadjson(behavjson_fullpath);
    task_version = raw_data{1, 1}.git.ref;

    % define start and end time elapsed values
    json_start_ind = 6;
    json_end_ind = 8;
    
    start_date_string = raw_data{1, json_start_ind}.start_date;
    start_date = datetime(start_date_string,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSS''Z''', ...
                                            'TimeZone','UTC-00:00',...
                                            'Format',data.constants.timestamp_string_format);
    start_date.TimeZone = data.constants.houston_timezone;

    start_timestamp = posixtime(start_date) * 1e3;

    % calculate time elapsed from JSON file
    start_time = (raw_data{json_start_ind}.time_elapsed - raw_data{1}.time_elapsed) + start_timestamp;
    end_time = (raw_data{json_end_ind}.time_elapsed - raw_data{1}.time_elapsed) + start_timestamp;
    tmp1 = table(start_time,0,0,'VariableNames',{'Timestamp','Task_Time','Event_Code'});
    tmp2 = table(end_time,end_time-start_time,1,'VariableNames',{'Timestamp','Task_Time','Event_Code'});

    behavior = [tmp1;tmp2];

end