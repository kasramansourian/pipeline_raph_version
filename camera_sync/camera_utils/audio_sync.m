% Find I files containing pulse trains
triggers = [];
thresh = 10e-4;
for i = 1:length(audio_files_I)
    [y,~] = audioread(audio_files_I(i));
    if max(y(:,2)) > thresh
        triggers = [triggers;i];
    end
        
end
audio_start = triggers(1);
audio_end = triggers(end);

% Find all open ephys files for task day
open_ephys_files = dir(strcat(session_load_dir,'open-ephys/'));
del = [];
for i = 1:length(open_ephys_files)
    if length(open_ephys_files(i).name)>2
        if strcmp('.log',open_ephys_files(i).name(end-3:end))
            del = [del,i];
        end
    else
        del = [del,i];
    end
end
open_ephys_files(del) = [];

% Verify that the number of audio and open ephys files match
audio_all = [audio_start:audio_end];
num_audio_files = length(audio_all);
if length(open_ephys_files)< length(audio_all)
    error('Warning: more audio files than open ephys files')
elseif length(open_ephys_files)> length(audio_all)
    error('Warning: more open ephys files than audio files')
elseif length(open_ephys_files)== length(audio_all)
    disp('Same number of open ephys files and audio files')
end

% Read the audio file matching the index of the open ephys file
aud_file = audio_all(open_ephys_file_num);
[y,fs_audio] = audioread(I_file_names{aud_file});
y = y(:,2);

% Find pulse locations based on crossing the treshold
crossings = find(or(y> thresh,y<-thresh));

% Eliminate false crossings
length_crossings = diff(crossings);
length_crossings_pass = find(length_crossings>4200);
crossings_pass = crossings(length_crossings_pass);

% sanity check figure
figure;
plot(y)
first_crossing = temp(1);
hold on
scatter(crossings_pass,thresh*ones(length(crossings_pass),1))

% calculate audio crossings per second
diff_crossings_pass = diff(crossings_pass);
crossings_per_second = mean(diff_crossings_pass)/fs_audio;

% calculate pulse crossings per second on open ephys
[first_crossing_open_ephys,audio_open_ephys_trace] = get_audio_pulse_indices(TC,fs);
close all;

% load M file
%[audio,fs_audio] = audioread(audio_files_M(aud_file));
%audio_file_name = audio_files_M(aud_file);

% cut out first bit of mic recording before open ephys was turned on
%audio = audio(crossings_pass(1):end,:);

% find duration of open ephys and audio recording
%dur_openephys = length(audio_open_ephys_trace)/fs_new;
%dur_mic = length(audio)/fs_audio;

audio_start_OE = first_crossing_open_ephys;
%audio_end_OE = first_crossing_open_ephys+fs*dur_mic;

% Cut audio to task
task_start = data.data_reference{2,2}/fs_new;
%task_end = data.data_reference{2,3}/fs_new;

audio_ts = (1/fs_audio):(1/fs_audio):(length(audio)/fs_audio);
temp = find(round(audio_ts,4)==round(task_start,4));
audio_start = temp(1);
%{
temp = find(round(audio_ts,4)==round(task_end,4));
audio_end = temp(1);

audio_ts = audio_ts(audio_start:audio_end);
audio = audio(audio_start:audio_end,:);

% Update preprocessed file with audio information
data.audio = audio;
data.fs_audio = fs_audio;
data.audio_filename = audio_file_name;
data.audio_start = audio_start;
data.audio_end = audio_end;
%}