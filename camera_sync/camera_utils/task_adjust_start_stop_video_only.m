% % Find start and end for ephys/audio/video from task start and stop in
% % preprocessing file
% ephys_start = data.data_reference{2, 2}*30; 
% ephys_end = data.data_reference{2, 3}*30;
% 
% % time separation between sync index and task start in open ephys
% offset = (ephys_start-ephys_sync_index)/fs;
% 
% % duration of task in open ephys
% duration = (ephys_end-ephys_start)/fs;
% 
% % use offset to determine where audio should start and end
% audio_start = aud_sync_index+offset*fs_audio;
% audio_end = audio_start + duration*fs_audio;

TC_video_start = zeros(length(videos(vid_file_index).cams),4);
TC_video_end = zeros(length(videos(vid_file_index).cams),4);

for i=1:length(videos(vid_file_index).cams)
   % if cam_file_overlaps~= cam_index
        lowres_audio_fname = [[num2str(vid_file_index), '_',num2str(i)],'_low-res-audio.aac'];
        vid_file = videos(vid_file_index).cams(i).file
       % Load the low res audio and prompt for the cross corr index
        extract_low_res_audio_from_video(savedir_AV, lowres_audio_fname, vid_file);
        [yl,Fs_l] = audioread([savedir_AV lowres_audio_fname]);

        up_sync_beep_temp = resample(sync_beep_temp, Fs_l,fs_beep);

        ds_factor = 20;
        fs_audio_l_ds = Fs_l/ds_factor;
        y_l_ds = downsample(yl(:,1),ds_factor);

        sync_beep_ds = downsample(up_sync_beep_temp,ds_factor);        
        [istart_low,istop_low,dist] = findsignal(y_l_ds,sync_beep_ds,'Normalization','zscore','NormalizationLength',21);
        
        ts_l_ds = (1/fs_audio_l_ds):(1/fs_audio_l_ds):(length(y_l_ds)/fs_audio_l_ds);
        %attempt at bandpass
%         y_bs = bandpass(y_l_ds,[599,601],fs_audio_l_ds);
%         [istart_low_bs,istop_low_bs,dist] = findsignal(y_bs,sync_beep_ds);

                
         vid_sync_index = istart_low*(Fs_l/fs_audio_l_ds);
         vid_sync_index/Fs_l
         winopen(strcat(savedir_AV, lowres_audio_fname));
         bool = input('confirm that sync point is correct (1 = yes, 0 = no): ')
         
         while bool==0
            disp('listen for beep and give 5 second time period to look for')
            beep_estimate = input('Give a start/end beep estimate in seconds [time1 time2]:');
            be_i = find(and(ts_l_ds>beep_estimate(1),ts_l_ds<beep_estimate(2)));
            [istart_low,istop_low,dist] = findsignal(y_l_ds(be_i),sync_beep_ds);
            
            temp_ts_ds = ts_l_ds(be_i);
            temp_y_ds = y_l_ds(be_i);
            figure;
            plot(temp_ts_ds,temp_y_ds)
            hold on
            plot(temp_ts_ds(istart_low:istop_low),sync_beep_ds+.2)
            xlabel('seconds')
            %ax.XLim = [(istart-100),(istart+100)];
            bool = input('Does beep alignment look correct? 1=yes, 0=no: ');
            istart_low = be_i(istart_low);
            istop_low = be_i(istop_low);
         end
            
%          while bool ==0
%              %error('sync point is not correct') 
%              before_or_after = input('is the true sync beep before (1) or after (0) the found beep?: ');
%              if before_or_after == 0
%                 [istart_low_new,istop_low_new,dist] = findsignal(y_l_ds(istop_low:end),sync_beep_ds,'Normalization','zscore','NormalizationLength',21);
%                 istart_low = istart_low_new + istart_low;
%                 istop_low = istop_low_new + istop_low;
%              else
%                 [istart_low_new,istop_low_new,dist] = findsignal(y_l_ds(1:istart_low),sync_beep_ds,'Normalization','zscore','NormalizationLength',21);
%                 istart_low = istart_low_new;
%                 istop_low = istop_low_new;
%              end
%              vid_sync_index = istart_low*(Fs_l/fs_audio_l_ds);
%              vid_sync_index/Fs_l
%              winopen(strcat(savedir_AV, lowres_audio_fname));
%              bool = input('confirm that sync point is correct (1 = yes, 0 = no): ')
%          end
%         figure;
%         plot((1/fs_audio_l_ds):(1/fs_audio_l_ds):(length(y_l_ds)/fs_audio_l_ds),y_l_ds)
%         hold on
%         plot((istart_low:istop_low)/fs_audio_l_ds,sync_beep_ds)

        video_start = vid_sync_index + correction_val_start*(Fs_l/data.fs);
        video_end = vid_sync_index + correction_val_end*(Fs_l/data.fs);

        [first_time_video_i, first_frame_video_i] = get_TC_for_vid_from_aud([0 0 0], 0, video_start, Fs_l);
        TC_video_start(i,1:3) = first_time_video_i;
        TC_video_start(i,4) = first_frame_video_i;
        
        [first_time_video_i, first_frame_video_i] = get_TC_for_vid_from_aud([0 0 0], 0, video_end, Fs_l);
        TC_video_end(i,1:3) = first_time_video_i;
        TC_video_end(i,4) = first_frame_video_i;

        
end