function [subject_id, session, date, task] = extract_basic_session_info_from_eeg_path(data)
    %assumes folder structure  data/subj_id/date/eeg/task_name.eeg
    
    location_div = split(data.paths.path_to_eeg,'/');
    location_div = location_div(~cellfun('isempty',location_div));

    subject_id = location_div{end-4};

    date_string = location_div{end-2};
    date = datetime(date_string,"InputFormat",data.constants.date_string_format,'TimeZone',data.constants.houston_timezone,'Format',data.constants.date_string_format);
    extracted_task_name = extractBefore(location_div{end},'.');
    is_digit_mask = isstrprop(extracted_task_name,'digit');
    if sum(is_digit_mask) == 0
        session = 0;
    else
        session = sscanf(extracted_task_name(is_digit_mask),'%d');
    end
    extracted_task_name = deblank(extracted_task_name(~is_digit_mask));
    try
        task = validatestring(extracted_task_name, data.constants.task_dictionary.keys);
    catch ME
        warning(['(No Matching Task Name Defined)' newline '    Task ''' extracted_task_name ...
            ''' is not apart of the preprocessing pipeline. To fix this ' ...
            'issue add any new tasks to define_tasks.m. If the task is already apart of the pipeline:' ...
            'ensure the eeg is correctly named (Naming Convention: Task#.eeg)']);
        rethrow(ME)
    end
    
end
