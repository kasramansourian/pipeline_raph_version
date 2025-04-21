% Determine the paths for the video and low res audio
vid_file = videos(vid_file_index).cams(cam_index).file;
vid_file2 = videos(vid_file_index).cams(cam_file_overlaps).file;
lowres_audio_fname1 = [[num2str(vid_file_index), '_', num2str(cam_index)],'_low-res-audio.aac'];
lowres_audio_fname2 = [[num2str(vid_file_index), '_', num2str(cam_file_overlaps)],'_low-res-audio.aac'];

% Load the low res audio for the good camera and prompt for the cross corr index
extract_low_res_audio_from_video(savedir_AV, lowres_audio_fname1, vid_file);
[yl,Fs_l] = audioread([savedir_AV lowres_audio_fname1]);
winopen(strcat(savedir_AV, lowres_audio_fname1));
cross_time_vid1 = input("Input the time (in seconds) for the cross correlation event: ");

% Load the low res audio for the good camera and prompt for the cross corr index
extract_low_res_audio_from_video(savedir_AV, lowres_audio_fname2, vid_file2);
[yl2,~] = audioread([savedir_AV lowres_audio_fname2]);
winopen(strcat(savedir_AV, lowres_audio_fname2));
cross_time_vid2 = input("Input the time (in seconds) for the cross correlation event: ");

% Define the ten second period containing the cross corr event
start_1_xcorr = (cross_time_vid1-5)*Fs_l;
end_1_xcorr = (cross_time_vid1+5)*Fs_l;
start_2_xcorr = (cross_time_vid2-5)*Fs_l;
end_2_xcorr = (cross_time_vid2+5)*Fs_l;
up_y = yl(start_1_xcorr:end_1_xcorr);
up_yl = yl2(start_2_xcorr:end_2_xcorr);
% Find the offset maximizing cross corr and determine the synced indices
[r, lags] = xcorr(up_yl, up_y);
[~, offset] = max(r);
vid1_sync_index = cross_time_vid1*Fs_l;
vid_sync_correction = vid_sync_index-vid1_sync_index;
vid2_sync_index =  cross_time_vid2*Fs_l + lags(offset) + vid_sync_correction;