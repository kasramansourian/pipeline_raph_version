function [synced_audio, audio_fs] = align_audio_ephys(data)
    addpath('C:\Users\edastinv\Desktop\Heart-Rate-Research-master\Libraries\fitellipse');
    % Filter for I and M files and sort according to time of recording
    stronghold = true;
    if stronghold
        audio_path = strcat('D:\',data.preprocessing.subject_id,'\',data.preprocessing.date,'\Audio\');
    else
        audio_path = strcat('E:\Box Sync\',data.preprocessing.subject_id,'\',data.preprocessing.date,'\Audio\');
    end
    audio_files = dir(audio_path);
    audio_files = {audio_files.name};
    audio_files = string(audio_files);
    audio_files_M = audio_files(endsWith(audio_files, "M.wav"));
    audio_files = audio_files(endsWith(audio_files, "I.wav"));
    audio_files = sort(audio_files);
    audio_files_M = sort(audio_files_M);
    
    % Load the open ephys file containing timecodes
    ephys_path = strcat(data.open_ephys_folder, "100_ADC7.continuous");
    
    % Choose which audio files you believe should have the tasks
    % corresponding to the ephys files
    disp(strcat("There are ", num2str(length(audio_files)), " audio files."))
    subset = input("Which audio files do you want to search through: ");
    audio_files = audio_files(subset);
    audio_files_M = audio_files_M(subset);
    
    % Find LTCs for all audio files and ephys file
    for i=1:length(audio_files)
        [ltc, ~] = ltc_decode(strcat(audio_path, audio_files(i)));
        full_audio(i) = ltc;
    end
    [ephys_ltc, ~] = ltc_decode(ephys_path);
    
    % Find first and last timecodes within the range of the task in the
    % ephys file
    ephys_start = data.data_reference{2, 2}*30;
    ephys_end = data.data_reference{2, 3}*30;
    first_tc = find(ephys_ltc.timecode_start_open_ephys >= ephys_start, 1);
    last_tc = find(ephys_ltc.timecode_start_open_ephys <= ephys_end, 1, 'last');
    start_offset = ephys_ltc.timecode_start_open_ephys(first_tc) - ephys_start;
    end_offset = ephys_end - ephys_ltc.timecode_start_open_ephys(last_tc);
    first_time = ephys_ltc.time(first_tc,:);
    last_time = ephys_ltc.time(last_tc,:);
    first_frame = ephys_ltc.frame_num(first_tc);
    last_frame = ephys_ltc.frame_num(last_tc);
    
    % For each audio file of interest search for the first timecode within
    % the task
    % When the timecode is found, use the offsets previously found to cut
    % the audio to the time period of the task
    for i=1:length(full_audio)
        [all_firsts, ~] = ismember(full_audio(i).time, first_time, 'rows');
        if nnz(all_firsts)>0
            [all_lasts, ~] = ismember(full_audio(i).time, last_time, 'rows');
            audio_frame_first = find(all_firsts&full_audio(i).frame_num==first_frame,1);
            audio_frame_last = find(all_lasts&full_audio(i).frame_num==last_frame,1);
            audio_first_index = full_audio(i).timecode_start_open_ephys(audio_frame_first);
            audio_end_index = full_audio(i).timecode_start_open_ephys(audio_frame_last);
            audio_fs = full_audio(i).audio_fs;
            audio_start_offset = floor(start_offset*audio_fs/30000);
            audio_end_offset = floor(end_offset*audio_fs/30000);
            synced_audio = audioread(strcat(audio_path, audio_files_M(i)));
            synced_audio = synced_audio(audio_first_index-audio_start_offset:audio_end_index+audio_end_offset, :);
            audiowrite("synced.wav", synced_audio, audio_fs);
        end
    end
end