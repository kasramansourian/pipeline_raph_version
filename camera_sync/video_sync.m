function [data] = video_sync(data)

% Find number of cameras and video load dir
session_load_dir = [data.paths.percept_data_path data.subject_id '/research/' char(data.date) '/video/'];
[video_load_dir,cam_num,camera_folder_names] = find_video_loaddir(session_load_dir);


% Move video and audio files to local disk for processing
local_video_copy_dir = [data.paths.code_path 'video_tmp/'];
if ~exist(local_video_copy_dir)
    mkdir(local_video_copy_dir)
else
    %if wasnt deleted in the past delete and make fresh empty version
    rmdir(local_video_copy_dir, 's')
    mkdir(local_video_copy_dir)
end
%%move videos to local disk and rename without spaces
for j = 1:cam_num

    if any(isspace(video_load_dir{j}(:)))
        video_load_dir_rename = video_load_dir{j};
        space = isspace(video_load_dir{j});
        inds = find(space);
        space(inds(1))=0;
        video_load_dir_rename = video_load_dir{j}(~space);
        % --> not sure what to do with this: movefile(server_video_load_dir{j},video_load_dir_rename,'f');
    end
    % video_load_dir{j} = video_load_dir_rename;
 
    if ~exist(video_load_dir{j})
        copyfile(local_video_copy_dir,video_load_dir{j})

    end
end

%% designate savedir for intermediates

savedir_AV = data.paths.save_data_path;
if ~exist(savedir_AV)
    mkdir(savedir_AV)
end
addpath(genpath(savedir_AV))

for p = 1:length(camera_folder_names)
    temp = camera_folder_names{p};
    space = isspace(temp);
    inds = find(space);
    camera_folder_names{p} = temp(~space);
end
  
if ~exist([savedir_AV, 'videos.mat'])
    %% make lists of continuous videos for entire session
    % concatenate videos
    continuous_files_all = list_continuous_video_files(video_load_dir,cam_num);
    video = concatenate_continuous_files(continuous_files_all,cam_num,video_load_dir,char(data.date),camera_folder_names,data.subject_id,savedir_AV);

    %% Find which videos from different cameras overlap and define video_sync struct
    [videos, task_file_input, num_cams_input] = cross_camera_sync_BV(video, cam_num);
    save([savedir_AV,'videos.mat'], 'videos','task_file_input','num_cams_input')
else
    load([savedir_AV, 'videos.mat'])
end

%% sync video/audio/ephys
vid_only_ephys_sync;
%%
task_adjust_start_stop_video_only;

%% Cut, strip, and stitch: pertaining to a single task
videoData.ephys_filename = ephys_pre_proc_fn;
[synced_audio,fs_audio] = audioread(videos(vid_file_index).cams(1).file);
videoData.lowres_audio = synced_audio;
videoData.fs_audio = fs_audio;
videoData.audio_filename = 'GoPro';
time = num2str(round(data.behavior.behav_start_timestamp_unix/1000));
% looping through each video pertaining to task 
for cam=1:length(videos(vid_file_index).cams)
    
    [start_str,end_str] = timecode_to_str(TC_video_start(cam,1:3),TC_video_end(cam,1:3),TC_video_start(cam,4),TC_video_end(cam,4));
    % Cut video using file from cam and start/end strings
    i = '-i';
    fn =  videos(vid_file_index).cams(cam).file;
    ss = '-ss';
    space = ' ';
    c = '-to';
    d = '-c copy';
    final_path = generate_vid_name(subject_id, date, task_name,time, file_num, cam);
    final_path = [extractBefore(final_path,'.mp4') '_lowresaudio.mp4'];
    final_path = strcat(savedir_final, final_path);
    arg = [i space fn space ss space start_str space c space end_str space '-threads 16 -preset ultrafast' space rewrite_tag space final_path];
    
    ffmpegexec(arg)
    % Update data with video info
    % Do we want the original video path?
    videoData.videos(cam).final_video_path = final_path;

end

%% define final video savedir
savedir_final = [savedir,task_name,'/'];
if ~exist(savedir_final)
    mkdir(savedir_final)
end
addpath(genpath(savedir_final))

%% Save complete preprocessing file
save(fullfile(savedir_final,strcat(subject_id,'_',task_name,'_',date,'_',time,'_synced_ephys_behav_Video.mat')),'videoData','-v7.3')

% if lfp sync file already exists, then combine
consolodate_with_lfp_sync;
close all

end