function data = extract_task_data(data)
%EXTRACT_TASK_DATA Summary of this function goes here
%   Detailed explanation goes here
    
    data.paths.path_to_task_folder = [data.paths.percept_data_path ...
        data.subject_id '/clinic/' char(data.date,data.constants.date_string_format) ...
        '/task/' data.task '/'];
    
    files_in_task_folder = dir(data.paths.path_to_task_folder);
    % delete empty files from list
    del_inds = [];
    for i = 1:length(files_in_task_folder)
        if files_in_task_folder(i).bytes == 0 || ~contains(files_in_task_folder(i).name,'pid') && ~contains(files_in_task_folder(i).name,'.mat') && ~contains(files_in_task_folder(i).name,'ERP')
            del_inds = [del_inds,i];
        end
    end
    %Remove folders and all non-pid files (only task files)
    files_in_task_folder(del_inds) = [];
    
    data.behavior.task_files = strcat({files_in_task_folder.folder}','/',{files_in_task_folder.name}');
    
    task_data_files = cellfun(@(x) split(extractBefore(x,'.'),'_'), ...
        {files_in_task_folder.name}','UniformOutput',false);

    tmp_task_file_start_unix_timestamp = cell2mat(cellfun(@(x) str2double(x{end}),task_data_files,'UniformOutput',false));
    if ~isdst(data.brainvision.brainvision_task_start_timestamp_local)
        tmp_task_file_start_unix_timestamp = tmp_task_file_start_unix_timestamp - (3600*1e3);
    end
    [~,task_file_ind] = min(abs(tmp_task_file_start_unix_timestamp-data.brainvision.brainvision_task_start_timestamp_unix));
    data.behavior.task_file_start_unix_timestamp = tmp_task_file_start_unix_timestamp(task_file_ind);
    data.behavior.task_files = data.behavior.task_files{task_file_ind};
    data.behavior.task_file_start_datetime = datetime(data.behavior.task_file_start_unix_timestamp/1000, ...
        'ConvertFrom', 'posixtime', 'TimeZone', data.constants.houston_timezone, ...
        'Format', data.constants.timestamp_string_format);
    
    task_processing_function = data.constants.extract_task_data_dictionary(data.brainvision.task_code);
    task_processing_function = task_processing_function{1};
    [events,raw_dat,start_time,end_time,task_version] = task_processing_function(data.behavior.task_files);
    if events.Event_Code(1) == 0
        events.Event_Code(1) = data.brainvision.task_code;
    end
    data.behavior.events = events;
    data.behavior.raw_data = raw_dat;
    if ~isdst(data.behavior.task_file_start_datetime)
        daylight_savings_shift = 0;%3600; 
    else
        daylight_savings_shift = 0;
    end
    data.behavior.events.Timestamp = data.behavior.events.Timestamp - (daylight_savings_shift * 1e3);
    data.behavior.first_event_unix_time = start_time - daylight_savings_shift*1e3;
    data.behavior.last_event_unix_time = end_time - daylight_savings_shift*1e3;
    data.behavior.first_event_local_time = datetime(start_time/1e3  - daylight_savings_shift, ...
                        'ConvertFrom','posixtime', ...
                        'TimeZone',data.constants.houston_timezone, ...
                        'Format',data.constants.timestamp_string_format);
    data.behavior.last_event_local_time = datetime(end_time/1e3  - daylight_savings_shift, ...
                        'ConvertFrom','posixtime', ...
                        'TimeZone',data.constants.houston_timezone, ...
                        'Format',data.constants.timestamp_string_format);
    data.behavior.task_version = task_version;

    
   
end