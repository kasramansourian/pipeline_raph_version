% Load preprocessed task file to which audio and video will be synced
data_path = input("Enter path to preprocessed data file: ");
load(data_path);

% figure out how many cameras there are
% make list of files to concatenate 
% concatenate files 
% sync corresponding files with timecodes 

% Find the path to the audio files for the task day
stronghold = true;
subject_id = data.preprocessing.subject_id;
date = data.preprocessing.date;
fs = 30000;
fs_new = 1000;
if stronghold
    session_load_dir = strcat('D:\',subject_id,'\',date,'\');
    savedir = strcat('D:\OCD-Patient-Analysis\',subject_id,'\',date,'\');
else
    session_load_dir = strcat('E:\Box Sync\',subject_id,'\',date,'\');
    savedir = strcat('E:\OCD-Patient-Analysis\',subject_id,'\',date,'\');
end
audio_path = strcat(session_load_dir,'\Audio\');

% Filter for I and M files and sort according to time of recording
audio_files = dir(audio_path);
audio_files = {audio_files.name};
audio_files = string(audio_files);
audio_files_M = audio_files(endsWith(audio_files, "M.wav"));
audio_files_I = audio_files(endsWith(audio_files, "I.wav"));
audio_files_I = sort(audio_files_I);
audio_files_M = sort(audio_files_M);

% Load the open ephys file containing timecodes or pulse train
ephys_path = strcat(session_load_dir, "open-ephys\", data.open_ephys_folder, "\100_ADC7.continuous");

% Find LTCs for all audio files
if ~isfile(strcat(savedir, "preprocessed_audio.mat"))
    for i=1:length(audio_files_I)
        [ltc, ~] = ltc_decode(strcat(audio_path, audio_files_I(i)));
        full_audio(i) = ltc;
    end
    save(strcat(savedir, "preprocessed_audio.mat"), 'full_audio');
else
    load(strcat(savedir, "preprocessed_audio.mat"));
end

% Find LTCs for ephys file
if ~isfile(strcat(data.open_ephys_folder, "timecodes.mat"))
    [ephys_ltc, TC] = ltc_decode(ephys_path);
    save(strcat(data.open_ephys_folder, "timecodes.mat"), 'ephys_ltc');
else
    load(strcat(data.open_ephys_folder, "timecodes.mat"));
end

if isempty(ephys_ltc.time)
    % No LTCs in ephys file case, align pulse train
    audio_sync
    % cross correlate synced audio with video audio (use non-cut version of
    % high quality audio to cross correlate and align)
    % cut video
else
    found_audio = false;
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
    
    for i=1:length(full_audio)
        % Found audio file containing task start LTC
        if ismember(first_time, full_audio(i).time, 'rows')
            % When the timecode is found, use the offsets previously found to cut
            % the audio to the time period of the task
            found_audio = true;
            [all_firsts, ~] = ismember(full_audio(i).time, first_time, 'rows');
            [all_lasts, ~] = ismember(full_audio(i).time, last_time, 'rows');
            audio_frame_first = find(all_firsts&full_audio(i).frame_num==first_frame,1);
            audio_frame_last = find(all_lasts&full_audio(i).frame_num==last_frame,1);
            audio_first_index = full_audio(i).timecode_start_open_ephys(audio_frame_first);
            audio_end_index = full_audio(i).timecode_start_open_ephys(audio_frame_last);
            audio_fs = full_audio(i).audio_fs;
            audio_start_offset = floor(start_offset*audio_fs/30000);
            audio_end_offset = floor(end_offset*audio_fs/30000);
            synced_audio = audioread(strcat(audio_path, audio_files_M(i)));
            audio_start = audio_first_index-audio_start_offset;
            audio_end = audio_end_index+audio_end_offset;
            synced_audio = synced_audio(audio_start:audio_end, :);
            audiowrite("synced.wav", synced_audio, audio_fs);
            data.audio = synced_audio;
            data.fs_audio = audio_fs;
            data.audio_filename = audio_files_M(i);
            data.audio_start = audio_start;
            data.audio_end = audio_end;
            % sync open ephys timecodes with video timecodes and cut video
            break
        end
    end
    
    % If no audio file contains the LTC then there must be LTCs missing
    % from the audio files and cross correlation is necessary
    if ~found_audio
         % sync open ephys timecodes with video timecodes and cut video
         % cross correlation btw video and audio, cut audio
    end
end