% look for PreProc LFP File
preprocessed_file = strcat(task_savedir,preprocs{file_num});
preprocessed_file_lfp = [extractBefore(preprocessed_file,'_v3'),'_lfp',version,'.mat'];

if exist(preprocessed_file_lfp)
    data_lfp = load(preprocessed_file_lfp);
    
    %% Update Stim log with Video times
    if task_num == 10 %exclude toggles from amplitude vids only
        for i =1:length(data_lfp.lfpData)
        start_time = data_lfp.data.behavior.behav_start_timestamp_unix;
        end_time = data_lfp.data.behavior.behav_end_timestamp_unix;
        data_lfp.lfpData(i).simple_stim_log = get_timestamps_video(data_lfp.lfpData(i).simple_stim_log,start_time,end_time);
        end
    else
        for i =1:length(data_lfp.lfpData)
        start_time = data_lfp.lfpData(i).full_stim_log.("Unified Derived Time")(1);
        end_time = data_lfp.lfpData(i).full_stim_log.("Unified Derived Time")(end);
        data_lfp.lfpData(i).simple_stim_log = get_timestamps_video(data_lfp.lfpData(i).simple_stim_log,start_time,end_time);
        end
    end
  
    data_lfp = get_simple_logs(data_lfp.lfpData,length(data_lfp.lfpData));
    % data_lfp is just the simple stim logs, not resaving
    % all of lfpData
 
    if exist("avdata")
        %Save Relevant AV Info
        data_lfp.ephys_filename = ephys_pre_proc_fn;
        data_lfp.lfp_filename = preprocessed_file_lfp;
        data_lfp.audio = avdata.audio;
        data_lfp.fs_audio = avdata.fs_audio;
        data_lfp.audio_filename = avdata.audio_filename;
        data_lfp.audio_start = avdata.audio_start;
        data_lfp.audio_end = avdata.audio_end;
        data_lfp.videos = avdata.videos;
        final_filename = fullfile(savedir,task_name,strcat(subject_id,'_',task_name,'_',date,'_',time,'_synced_ephys_behav_AV_lfp.mat'));
    elseif exist("audioData")
        data_lfp.ephys_filename = ephys_pre_proc_fn;
        data_lfp.lfp_filename = preprocessed_file_lfp;
        data_lfp.audio = audioData.audio;
        data_lfp.fs_audio = audioData.fs_audio;
        data_lfp.audio_filename = audioData.audio_filename;
        data_lfp.audio_start = audioData.audio_start;
        data_lfp.audio_end = audioData.audio_end;
        final_filename = fullfile(savedir,task_name,strcat(subject_id,'_',task_name,'_',date,'_',time,'_synced_ephys_behav_Audio_lfp.mat'));
    elseif exist("videoData")
        data_lfp.ephys_filename = ephys_pre_proc_fn;
        data_lfp.lfp_filename = preprocessed_file_lfp;
        ata_lfp.lowres_audio = videoData.lowres_audio;
        data_lfp.fs_audio = videoData.fs_audio;
        final_filename = fullfile(savedir,task_name,strcat(subject_id,'_',task_name,'_',date,'_',time,'_synced_ephys_behav_Video_lfp.mat'));
    end

        
    %rename data_lfp as data for saving
    data = data_lfp;
    if isfield(data,'EEG_all')    % Comment to BROWN: This conditional statement added!!
        data = rmfield(data,'EEG_all');
    end
    time = num2str(round(start_time/1000));
    
    save(final_filename,'data','-v7.3')

else
    disp('Still need to do LFP sync')
end
