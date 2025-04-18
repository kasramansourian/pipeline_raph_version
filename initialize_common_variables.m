%% TODO ADD THESE TO DATA AND HAVE THAT CARRY IT INSGTEAD OF ALWAYS CALLING DEFINE TASKS.m
data = struct();

data.paths.ECoG_server_path = '/Volumes/datalake/';
data.paths.percept_data_path = [data.paths.ECoG_server_path 'DBSPsych-56119/']; %'/Users/raphaelb/Documents/UW/Research/gridlab/DBS psychiatric/data/Percept/'; 
data.paths.extract_percerpt_repo = '/Users/kasramansourian/Documents/Percept-master/';
data.paths.extract_jsonlab_repo = '/Users/kasramansourian/Documents/jsonlab-master/';
data.paths.save_h5_repo =  '/Users/kasramansourian/Documents/easyh5-master';

addpath(genpath([data.paths.extract_percerpt_repo 'ExtractFiles/']));
addpath(data.paths.extract_jsonlab_repo);
addpath(data.paths.save_h5_repo);


task_to_event_code = {
    'ERP',                10, @extract_erp_task_data;
    'Resting',            12, @extract_resting_task_data;
    'Movement',           14, @extract_resting_task_data; 
    'Resting_Movement',   15, @extract_resting_task_data;
    'TSST',               16, @extract_simple_task_data;
    'Clinician Interview',17, @extract_simple_task_data;
    'Adaptive',           18, @extract_simple_task_data;
    'Amplitude',          19, @extract_simple_task_data;
    'Ramping',            20, @extract_simple_task_data;
    'PAAT',               21, @extract_paat_task_data;
    'IAPS',               21, @extract_paat_task_data};

data.constants.task_dictionary = dictionary(task_to_event_code(:,1),cell2mat(task_to_event_code(:,2)));
data.constants.extract_task_data_dictionary  = dictionary(cell2mat(task_to_event_code(:,2)),task_to_event_code(:,3));
data.constants.date_string_format = 'yyyy-MM-dd';
data.constants.houston_timezone = 'UTC-05:00';
data.constants.timestamp_string_format = 'yyyy-MM-dd HH:mm:ss.SSSSSSSS ZZZZ';
data.constants.percept_file_date_string_format = 'yyyyMMdd''T''HHmmss';
