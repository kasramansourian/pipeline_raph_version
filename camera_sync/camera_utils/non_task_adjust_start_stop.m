% Find start and end for ephys/audio/video by watching the video and
% manually determining the session duration
winopen(videos(vid_file_index).cams(cam_index).file)
video_man_start = input("Input the time for the start of the session [h,m,s]");
video_man_end = input("Input the time for the end of the session [h,m,s]");
[start_time_video, start_frame_video, ~, ~] = get_video_timecodes(videos(vid_file_index).cams(cam_index).file);
[video_start_time(cam_index, 1:3), video_start_frame(cam_index)] = add_timecodes(start_time_video, video_man_start, start_frame_video, 0);
[video_end_time(cam_index, 1:3), video_end_frame(cam_index)] = add_timecodes(start_time_video, video_man_end, start_frame_video, 0);
[offset_time, offset_frame] = subtract_timecodes(video_start_time(cam_index, 1:3), first_time_video, video_start_frame(cam_index), first_frame_video);
[dur_time, dur_frame] = subtract_timecodes(video_end_time(cam_index, 1:3), video_start_time(cam_index, 1:3), video_end_frame(cam_index), video_start_frame(cam_index));
offset = offset_time(1)*60*60+offset_time(2)*60+offset_time(3)+offset_frame/30;
duration = dur_time(1)*60*60+dur_time(2)*60+dur_time(3)+dur_frame/30;
if open_ephys_folder_num ~= 0
    ephys_start = ephys_sync_index + offset*fs;
    ephys_end = ephys_start + duration*fs;
end
audio_start = aud_sync_index + offset*audio_fs;
audio_end = audio_start + duration*audio_fs;

for cam_file_overlaps=1:length(videos(vid_file_index).cams)
    if cam_file_overlaps~= cam_index
        [first_time_video_i, first_frame_video_i, ~, ~] = get_video_timecodes(videos(vid_file_index).cams(cam_file_overlaps).file);
        video_video_xcorr;
        [first_time_video_i, first_frame_video_i] = get_TC_for_vid_from_aud(first_time_video_i, first_frame_video_i, vid2_sync_index, Fs_l);
        [video_start_time(cam_file_overlaps, 1:3), video_start_frame(cam_file_overlaps)] = get_TC_for_vid_from_aud(first_time_video_i, first_frame_video_i, audio_start-aud_sync_index, fs_audio);
        [video_end_time(cam_file_overlaps, 1:3), video_end_frame(cam_file_overlaps)] = get_TC_for_vid_from_aud(first_time_video_i, first_frame_video_i, audio_end-aud_sync_index, fs_audio);
    else
        [video_start_time(cam_file_overlaps, 1:3), video_start_frame(cam_file_overlaps)] = get_TC_for_vid_from_aud(first_time_video, first_frame_video, audio_start-aud_sync_index, fs_audio);
        [video_end_time(cam_file_overlaps, 1:3), video_end_frame(cam_file_overlaps)] = get_TC_for_vid_from_aud(first_time_video, first_frame_video, audio_end-aud_sync_index, fs_audio);
    end
end