% Determine the paths for the video and low res audio
lowres_audio_fname = [[num2str(vid_file_index), '_', num2str(cam_index)],'_low-res-audio.aac'];

% assume camera 1 was turned on during beep
cam_index = 1;
vid_file = videos(vid_file_index).cams(cam_index).file;
    
% Load the low res audio and prompt for the cross corr index
extract_low_res_audio_from_video(savedir_AV, lowres_audio_fname, vid_file);
[yl,Fs_l] = audioread([savedir_AV lowres_audio_fname]);

up_sync_beep_temp = resample(sync_beep_temp, Fs_l,fs_audio);

ds_factor = 20;
fs_audio_l_ds = Fs_l/ds_factor;
y_l_ds = downsample(yl(:,1),ds_factor);

sync_beep_ds = downsample(up_sync_beep_temp,ds_factor);
[istart_low,istop_low,dist] = findsignal(y_l_ds,sync_beep_ds);

% sync point check/plot:
% istart_low/fs_audio_l_ds/60
% figure;
% plot((1/fs_audio_l_ds):(1/fs_audio_l_ds):(length(y_l_ds)/fs_audio_l_ds),y_l_ds)
% hold on
% plot((istart_low:istop_low)/fs_audio_l_ds,sync_beep_ds)

vid_sync_index = istart_low*(Fs_l/fs_audio_l_ds);

