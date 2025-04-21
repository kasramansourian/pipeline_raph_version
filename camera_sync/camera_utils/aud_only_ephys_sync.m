% Filter for I and M files and sort according to time of recording
audio_files = dir(audio_loaddir);
audio_files = {audio_files.name};
audio_files = string(audio_files);
audio_files_M = audio_files(endsWith(audio_files, "M.wav"));
audio_files_I = audio_files(endsWith(audio_files, "I.wav"));
audio_files_I = sort(audio_files_I);
audio_files_M = sort(audio_files_M);

    % NEW DAYS
    
    % Verify that the number of audio and open ephys files match
    num_audio_files = length(audio_files_M);
    EEG_load_dir = strcat(session_load_dir,'EEG\');
    if ~exist(EEG_load_dir)
        EEG_load_dir = strcat(session_load_dir,'Raw EEG Files\');
        if ~exist(EEG_load_dir)
            EEG_load_dir = strcat(session_load_dir,'EEG Files\');
            if ~exist(EEG_load_dir)            
                error('cannot find EEG load dir - probably a folder naming issue on the ECoG server')
            end
        end
    end

    open_ephys_file_names = dir(strcat(EEG_load_dir,'*.eeg'));
    %open_ephys_file_names = open_ephys_file_names.name;
    audio_files_I
    
    if length(open_ephys_file_names)< num_audio_files
        % Manual identification is needed if there are too many audio files
        disp('More audio files than EEG files, audio file must be manually determined')
        for i=1:num_audio_files
            disp(strcat(num2str(i), ": ", strcat(audio_loaddir, audio_files_M(i))))
        end
        aud_file = input("Listen to the audio and determine which corresponds to the task being processed: ");
    elseif length(open_ephys_file_names)> num_audio_files
        % Manual identification is needed if there are too few audio files
        disp('Fewer audio files than EEG files, audio file must be manually determined')
        for i=1:num_audio_files
            disp(strcat(num2str(i), ": ", strcat(audio_loaddir, audio_files_M(i))))
        end
        aud_file = input("Listen to the audio and determine which corresponds to the task being processed: ");
    elseif length(open_ephys_file_names)== num_audio_files
        disp('Same number of EEG files and audio files')
        open_ephys_file_num = input('index of audio file: ');
        aud_file = open_ephys_file_num;
    end
    
    cam_index=1;
    
    [y,fs_audio] = audioread(strcat(audio_loaddir, audio_files_M(aud_file)));
    if contains(task_name,'programming')
        task_name_temp = 'programming';
    else
        task_name_temp = task_name;
    end

    [sync_beep,fs_beep]=audioread([task_name_temp,'.wav']);
    
    y_ds = downsample(y(:,1),22);
    
    if contains(task_name,'programming')
        sync_beep_temp = sync_beep(6.3e4:8.1e4,1); 
    elseif contains(task_name, 'provocation')
        sync_beep_temp = sync_beep(50000:80000,1);
    elseif contains(task_name, 'beads')
        sync_beep_temp=sync_beep(700:2.072e4,1);
    elseif contains(task_name, {'msit', 'MSIT'})
        sync_beep_temp=sync_beep(1.756e4:4.331e4,1);
    elseif contains(task_name, 'resting-state1')
        sync_beep_temp=sync_beep(2.16e4:4.396e4,1);
    elseif contains(task_name, 'resting-state2')
        sync_beep_temp=sync_beep(1.086e4:3.495e4,1);
    elseif contains(task_name, 'interview')
        sync_beep_temp=sync_beep(2.358e4:4.714e4,1);
    elseif contains(task_name, 'erp')
        sync_beep_temp=sync_beep(2.852e4:4.666e4,1);
    elseif contains(task_name, {'TSST', 'tsst'})
        sync_beep_temp=sync_beep(2.591e4:4.422e4,1);
    elseif contains(task_name, 'movement')
        sync_beep_temp=sync_beep(4.856e4:6.716e4,1);
    elseif contains(task_name, 'adaptive')
        sync_beep_temp=sync_beep(4.681e4:6.501e4,1);
    elseif contains(task_name, 'amplitude')
        sync_beep_temp=sync_beep(2.203e4:4.476e4,1);
    elseif contains(task_name, 'ramping')
        sync_beep_temp=sync_beep(2.208e4:4.228e4,1);
    end
    audio_ds_factor = 22;
    fs_audio_ds = fs_audio/audio_ds_factor;
    sync_beep_ds = downsample(sync_beep_temp,audio_ds_factor);
    [istart,istop,dist] = findsignal(y_ds,sync_beep_ds);
    
    ts_ds = (1/fs_audio_ds):(1/fs_audio_ds):(length(y_ds)/fs_audio_ds);
    figure;
    plot(ts_ds,y_ds)
    hold on
    plot(ts_ds(istart:istop),sync_beep_ds+.2)
    xlabel('seconds')
    ax = gca;
    %ax.XLim = [(istart-100),(istart+100)];
    
   
    
    bool = input('Does beep alignment look correct? 1=yes, 0=no: ');
    while bool==0
        disp('listen for beep and give 5 second time period to look for')
        beep_estimate = input('Give a start/end beep estimate in seconds [time1 time2]:');
        be_i = find(and(ts_ds>beep_estimate(1),ts_ds<beep_estimate(2)));
        [istart,istop,dist] = findsignal(y_ds(be_i),sync_beep_ds);
        
        temp_ts_ds = ts_ds(be_i);
        temp_y_ds = y_ds(be_i);
        figure;
        plot(temp_ts_ds,temp_y_ds)
        hold on
        plot(temp_ts_ds(istart:istop),sync_beep_ds+.2)
        xlabel('seconds')
        %ax.XLim = [(istart-100),(istart+100)];
        bool = input('Does beep alignment look correct? 1=yes, 0=no: ');
        istart = be_i(istart);
        istop = be_i(istop);
    
    end


    aud_sync_index=istart;
    switch task_name
        case 'interview'
            task_code=17;
        case 'resting-state1'
            task_code=12;
        case 'resting-state2'
            task_code=12;
        case 'provocation'
            task_code=13;
        case 'MSIT'
            task_code=11;
        case 'beads'
            task_code=14;
        case 'programming'
            task_code = 15;
        case 'erp'
            task_code = 15;
        case 'programming2'
            task_code = 15;
        case 'programming3'
            task_code = 15;
        case 'amplitude'
            task_code = 19;
        case 'adaptive'
            task_code = 18;
        case 'ramping'
            task_code = 20;

    end
    str_events = {data.events(2:end).value};
    for i = 1:length(str_events)
        temp_event = str_events{i};
        num = regexp(temp_event,'\d');
        temp_event = str2num(temp_event(num));
        if task_code ==temp_event
            % get event index where task event was sent (15) 
            task_event_index = data.events(i+1).sample;
        end
    end
    % use start time in data reference -- subtract task event index =
    % correction_val_start
    correction_val_start = data.data_reference{2,2} - task_event_index;
    
    % use end time in data reference -- subtract task event index =
    % correction_val_end
    correction_val_end = data.data_reference{2,3} - task_event_index;

    % get audio start/end time by: sync point + correction val (corrected for
    % fs)    
    audio_start = (istart + correction_val_start*(fs_audio_ds/data.fs))*audio_ds_factor;
    audio_end = (istart + correction_val_end*(fs_audio_ds/data.fs))*audio_ds_factor;

    % strip audio out of video and do same cross correlation using that
    % audio and do the same correction
    % then cut video and overlay audio





