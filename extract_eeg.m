function [data] = extract_eeg(data)
    %EXTRACT_EEG: Load .eeg, .vhdr, and .vmrk into behvaioral data 
    %   Use field trip open brain vision task files (.eeg, .vhdr, and .vmrk)
    %   and format the information into a fieldtrip struct
    %
    %   (String) path_to_eeg: path to eeg files including the file name.
    %   example input = '/path/to/eeg/task.eeg' 

    path_to_eeg = extractBefore(data.paths.path_to_eeg,'.'); %Remove extension
    headerfile = [path_to_eeg '.vhdr'];
    datafile = [path_to_eeg '.eeg'];


    % Initialize fieldtrip struct
    cfg = [];
    cfg.headerfile = [path_to_eeg '.vhdr'];
    cfg.datafile = [path_to_eeg '.eeg'];
    ft_data = ft_preprocessing(cfg);
    
    % Find the task initialization events in the EEG data, and trim the EEG data to start when the task initialized
    cfg = [];
    cfg.headerfile = headerfile;
    cfg.datafile = datafile;
    cfg.trialfun = 'trialfun_extract_events';
    cfg.task_name = data.task;
    cfg = ft_definetrial(cfg);
    data.brainvision = ft_redefinetrial(cfg, ft_data);
    data.brainvision.events = data.brainvision.cfg.event;
    % data.brainvision.eye_tracking_events = data.brainvision.cfg.event;
    is_new_segment = contains({data.brainvision.events.type}','New Segment');
    if sum(is_new_segment) > 1
        warning('More than one "New Segment" in Events List');
    end

    data.brainvision.brainvision_start_timestamp_local = data.brainvision.events(is_new_segment).timestamp;
    data.brainvision.brainvision_start_timestamp_local.Format = data.constants.timestamp_string_format;
    data.brainvision.brainvision_start_timestamp_local.TimeZone = data.constants.houston_timezone;
    data.brainvision.events(is_new_segment).timestamp = data.brainvision.brainvision_start_timestamp_local;
    data.brainvision.brainvision_start_timestamp_unix = posixtime(data.brainvision.brainvision_start_timestamp_local)*1e3;

    msec_into_eeg_task_starts = data.brainvision.time{1}(data.brainvision.sampleinfo(1)) * 1e3;
    data.brainvision.brainvision_task_start_timestamp_local = data.brainvision.brainvision_start_timestamp_local + milliseconds(msec_into_eeg_task_starts);
    data.brainvision.brainvision_task_start_timestamp_unix = data.brainvision.brainvision_start_timestamp_unix + msec_into_eeg_task_starts;
    data.brainvision.task_code = data.brainvision.trialinfo(1);
    
    inds_of_first_event = data.brainvision.cfg.trl(:,5);


    EVsample = [data.brainvision.events.sample]';
    EVvalue = {data.brainvision.events.value}';
    EVtype = {data.brainvision.events.type}';
    
    empty = cellfun(@isempty,EVvalue);
    EVvalue=EVvalue(~empty);
    EVsample=EVsample(~empty);
    EVtype=EVtype(~empty);
    
    is_stimulus = contains(EVtype,'Tobii');
    EVvalue=string(EVvalue(is_stimulus));
    EVsample=EVsample(is_stimulus);

    % Convert the string event codes to numbers
    pupillometry_code=str2double(extractBetween(EVvalue,3,4));
    data.brainvision.pupillometry = table(EVsample,pupillometry_code);

end

