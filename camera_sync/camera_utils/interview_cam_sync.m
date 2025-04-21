% Stronghold?
prompt = 'Running on stronghold? 1 = yes, 0 = no';
stronghold = input(prompt);

% Preprocessed file?
prompt = 'Is there a preprocessed file? 1 = yes, 0 = no';
preproc_bool = input(prompt);

%% define open ephys folder name and session load dir

% if there is a preprocessed file saved, we can get the open ephys folder name
% from the file. If there isn't a preprocessed file saved, we have to
% select it from a list.
if preproc_bool ==1
    prompt = 'Enter subject ID string.';
    subject_id = input(prompt);
    prompt = 'Enter date string.';
    date = input(prompt);
    prompt = 'Enter task string.';
    task_name = input(prompt);
    [session_load_dir,savedir] = set_load_save_dir(subject_id,date,stronghold);
    task_savedir = strcat(savedir, task_name,'\');
    files = dir(task_savedir);
    for i = 1:size(files,1)
        if length(files(i).name)>22
        if strcmp(files(i).name((end-21):end),'synced_ephys_behav.mat')
            break
        end
        end
    end
    load(strcat(task_savedir,files(i).name))
    open_ephys_folder_name = data.open_ephys_folder;
else
    prompt = 'Enter subject ID string.';
    subject_id = input(prompt);
    prompt = 'Enter date string.';
    date = input(prompt);
    [session_load_dir,savedir] = set_load_save_dir(subject_id,date,stronghold);
    open_ephys_folder_name = find_open_ephys_folder(session_load_dir);
    
    % define open ephys load directory
    loaddir = strcat(session_load_dir, 'open-ephys\',open_ephys_folder_name,'\' );
    open_ephys_folder = loaddir;
    addpath(genpath(loaddir))
    % load/filter open ephys data
    load_filter_data;
end

%% find number of cameras and video load dir

[video_load_dir,cam_num] = find_video_loaddir(session_load_dir);

%% define final video savedir

savedir_final = [savedir,task_name,'\'];
if ~exist(savedir_final)
    mkdir(savedir_final)
end
addpath(genpath(savedir_final))

%% define audio loaddir

audio_loaddir = strcat(session_load_dir, 'audio','\');

%% designate savedir for intermediates
savedir_AV = [savedir,'AV_preprocessing\'];
if ~exist(savedir_AV)
    mkdir(savedir_AV)
end
addpath(genpath(savedir_AV))

%% make lists of continuous videos for entire session

video = concatenate_continuous_files(continuous_files_all,cam_num,video_load_dir,date,camera_folder_names);

%% Find which videos from different cameras overlap and define video_sync struct


 

 %% synchronize cameras: outputs [date,'_cut_cam1.mp4'] and [date,'_cut_cam2.mp4']
 cam_sync;
 output1 = [date,'_cut_cam1.mp4'];
 output2 = [date,'_cut_cam2.mp4'];


% define video_start_time and video_end_time here

%% crop video
% make time strings for start and stop
[start_str,end_str] = time_in_sec_to_hms_string(video_start_time,video_end_time);

%%
if ~or(or(strcmp(task_name,'interview'),strcmp(task_name,'TSST')),strcmp(task_name,'programming'))

i = '-i';
file_temp = [savedir_AV output1];
fn = [file_temp];
ss = '-ss';
space = ' ';
c = '-t';
d = '-c copy';
output1 = [output1(1:(end-4)) '-cut.mp4'];
fn_new = [savedir_AV output1];
%end_str = duration_1;

arg = [i space fn space ss space start_str2 space c space end_str2 space '-threads 4 -preset ultrafast' space rewrite_tag space fn_new];
ffmpegexec(arg)

i = '-i';
file_temp = [savedir_AV output2];
fn = [file_temp];
ss = '-ss';
space = ' ';
c = '-t';
d = '-c copy';
output2 = [output2(1:(end-4)) '-cut.mp4'];
fn_new = [savedir_AV output2];

%end_str = duration_1;

arg = [i space fn space ss space start_str2 space c space end_str2 space '-threads 4 -preset ultrafast' space rewrite_tag space fn_new];
ffmpegexec(arg)
end

%4. Strip off audio track to create a silent video:
silent_vid_name1 = [savedir_AV date '_silent_video1.mp4'];
map = '-map 0:0 -acodec copy -vcodec copy';
fn_new = [savedir_AV output1];
arg = [i space fn_new space map space rewrite_tag space silent_vid_name1];
%arg = '-i cut.mp4 -map 0:0 -acodec copy -vcodec copy silent_video.mp4';
ffmpegexec(arg)

silent_vid_name2 = [savedir_AV date '_silent_video2.mp4'];
map = '-map 0:0 -acodec copy -vcodec copy';
fn_new = [savedir_AV output2];
arg = [i space fn_new space map space rewrite_tag space silent_vid_name2];
%arg = '-i cut.mp4 -map 0:0 -acodec copy -vcodec copy silent_video.mp4';
ffmpegexec(arg)

%5. Stitch high resolution audio to the video:
new_fn_audio = [savedir_AV,task_name,'_high_res_audio.wav'];
new_vid_fn = strcat(savedir_final, task_name,'_',date,'_cam1_HR-AV.mp4');
i = '-i';
cv = '-c:v copy';
ca = '-c:a aac';

arg = [i space silent_vid_name1 space i space new_fn_audio space cv space ca space rewrite_tag space new_vid_fn];
ffmpegexec(arg)

new_fn_audio = [savedir_AV,task_name,'_high_res_audio.wav'];
new_vid_fn = strcat(savedir_final, task_name,'_',date,'_cam2_HR-AV.mp4');
i = '-i';
cv = '-c:v copy';
ca = '-c:a aac';

arg = [i space silent_vid_name2 space i space new_fn_audio space cv space ca space rewrite_tag space new_vid_fn];
ffmpegexec(arg)
%end

%% update data with video info
data.final_video_name = strcat(task_name,'_',file_date,'_HR-AV.mp4');
%data.original_video_name = [task_loaddir fname];
data.video_start_cam1 = start_str1;
data.video_start_cam2 = start_str2;

data.video_end_cam1 = end_str1;
data.video_end_cam2 = end_str2;

save(fullfile(savedir_temp,strcat(subject_id,'_',task_name,'_',file_date,'_synced_ephys_behav_AV.mat')),'data','-v7.3')



