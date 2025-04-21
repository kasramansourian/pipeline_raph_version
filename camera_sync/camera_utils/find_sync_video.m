


% Determine which video file corresponds to the ephys/audio files
if length(open_ephys_file_names)< length(videos)
    % Manual identification is needed if there are too many videos
    disp('More video files than open ephys files, video file must be manually determined')
    for video=1:length(videos)
        disp(strcat(num2str(video), ": ", videos(video).cams(1).file))
    end
    vid_file_index = input("Watch the videos and determine which corresponds to the task being processed: ");
elseif length(open_ephys_file_names)> length(videos)
    % If there are fewer videos than ephys files, something must be missing
    disp('Warning: more open ephys files than video files')
    for video=1:length(videos)
        disp(strcat(num2str(video), ": ", videos(video).cams(1).file))
    end
    vid_file_index = input("Watch the videos and determine which corresponds to the task being processed: ");
elseif ~exist('open_ephys_file_num')
    disp('Warning: Error in finding correct ephys from audio')
    for video=1:length(videos)
        disp(strcat(num2str(video), ": ", videos(video).cams(1).file))
    end
    vid_file_index = input("Watch the videos and determine which corresponds to the task being processed: ");
elseif length(open_ephys_file_names)== length(videos) & exist('open_ephys_file_num')
    % If the number of video and ephys files is equal then the index of the
    % ephys file will correspond to the correct video file
    disp('Same number of open ephys files and video files, sync will proceed wth corresponding file')
    vid_file_index = open_ephys_file_num;
end