%{ 
Updated Percept Preprocessing Pipeline. 

Full pipeline integration (EEG/Behavior, percept data, toggle sync)
%} 
close all; clear;

% %Clear paths and re-add fieldtrip to prevent accidently path issues
restoredefaultpath;
addpath '/Users/kasramansourian/Documents/fieldtrip'
ft_defaults


code_path = mfilename("fullpath"); %gets path of current running file 
code_path = code_path(1:end-15);   %keep only directory path(removes file name)
addpath(genpath(code_path));
cd(code_path);
initialize_common_variables;
[s,git_hash_string] = system('git rev-parse HEAD');
version = git_hash_string;

%Select brain vision EEG file of session you want to preprocess
[eeg_file,location] = uigetfile({'*.eeg'},'Select an .eeg file',data.paths.percept_data_path);
data.paths.path_to_eeg = [location eeg_file];
[subject_id, session, date, task] = extract_basic_session_info_from_eeg_path(data);
data.subject_id = subject_id;
data.session = session;
data.date = date;
data.task = task;
data.paths.code_path = code_path;
[~,git_hash_string] = system(['git -C ' replace(code_path,' ','\ ') ' rev-parse HEAD']); 
data.constants.git_commit_hash = git_hash_string(1:end-1); %removes newline char

data.paths.save_data_path = [code_path 'Preprocessed/' data.subject_id '/'  char(data.date) '/' data.task '/'];
if ~exist(data.paths.save_data_path, 'dir')
    mkdir(data.paths.save_data_path)
end

%Display and Confirm Selection (Give opportunity to exit code if incorrect)
disp([newline 'Session Selected for Preprocessing: ' newline ...
      newline '     Subject: ' data.subject_id newline ...
      newline '     Date: ' char(data.date,data.constants.date_string_format) newline ...
      newline '     Task: ' data.task newline])

disp('Extracting Brainvision Data')
data = extract_eeg(data);

disp('Extracting Task Data')
data = extract_task_data(data);

disp('Extracting Percept Data')
data = extract_percept_data(data);

disp('Aligning Events to Photodiode')
data = align_task_events(data); %Look through task_sync script and add those parts

disp('Toggle Sync')
data = toggle_sync(data); %use toggle sync to align all data streams (w/ optional manual)

disp('Plot Data')
plot_final_data;

%Save Data
disp('Saving Data')
save_data_path = [code_path 'Preprocessed/' data.subject_id '/'  char(data.date) '/' data.task '/'];
if ~exist(save_data_path, 'dir')
    mkdir(save_data_path)
end

file_name = ['P' data.subject_id '_' char(data.date) '_' data.task '_' int2str(data.session)];
save([data.paths.save_data_path file_name '.mat'],'data', '-v7.3');
saveh5(data, [data.paths.save_data_path file_name '.h5']);

disp('Processing Complete')