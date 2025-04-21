% Make a folder to save figures if it doesn't already exist
if ~exist(strcat(savedir_final,'figures/'))
    mkdir(strcat(savedir_final,'figures/'))
end
figure_folder = strcat(savedir_final,'figures/');
if ~exist(figure_folder)
    mkdir(figure_folder)
end

% Load channel locations file
load('chanlocs.mat')

% design low pass filter for stim artifact
lpf = designfilt('lowpassfir', 'PassbandFrequency', 100, 'StopbandFrequency', 130, 'PassbandRipple', 0.1, 'StopbandAttenuation', 60, 'SampleRate', fs_new);

if pause_num > 1
    pause_string = strcat("_", num2str(pause_num));
else
    pause_string = "";
end
if equipment_version == 0
    EEG_channels = [1:10,23:32];
    figure('units','normalized','outerposition',[0 0 1 1]);
    for i = 1:20
        notch_true = 1;
        lpf_true = 1;
        j = EEG_channels(i);
        Ch1 = load_open_ephys_data_faster(strcat(loaddir,'100_CH',num2str(j), pause_string, '.continuous'));
        Ch1 = Ch1(ephys_start:ephys_end);
        [Ch1, ts_new,fs_new] = Filter_downsample_notch(fs,fs_new,Ch1,notch_true,lpf_true,lpf);
        EEG{i} = Ch1;
        subplot(4,5,i)
        pspectrum(Ch1,fs_new,'FrequencyLimits',[0 200])
        title(strcat("EEG Channel ",num2str(i), ", ",channel_locs(i).labels))
        hold on
    end
    % save the figure
    saveas(gcf, fullfile(strcat(figure_folder,'EEG_PSD.fig')));
    saveas(gcf, fullfile(strcat(figure_folder,'EEG_PSD.png')));

    if length(EEG{i})/fs < 25
        figure('units','normalized','outerposition',[0 0 1 1]);
        for i = 1:20 
            Ch = EEG{i};
            subplot(4,5,i)
            pspectrum(Ch1,fs_new,'spectrogram','FrequencyLimits',[0 200],'TimeResolution',1)
            title(strcat("EEG Channel ",num2str(i), ", ",channel_locs(i).labels))
        end
        % save the figure
        saveas(gcf, fullfile(strcat(figure_folder,'EEG_spectrogram.fig')));
        saveas(gcf, fullfile(strcat(figure_folder,'EEG_spectrogram.png')));
    end

    ECG_channels = [12,14,16];
    for i = 1:3
        notch_true = 1;
        lpf_true = 1;
        j = ECG_channels(i);
        Ch1 = load_open_ephys_data_faster(strcat(loaddir,'100_CH',num2str(j), pause_string,'.continuous'));
        Ch1 = Ch1(ephys_start:ephys_end);
        [Ch1, ts_new,fs_new] = Filter_downsample_notch(fs,fs_new,Ch1,notch_true,lpf_true,lpf);
        ECG{i} = Ch1;
    end
else
    ECG_channels = [129,130];
    Ref_channel = [131];

    for i = 1:2
        notch_true = 1;
        lpf_true = 1;
        j = ECG_channels(i);
        if isfile(strcat(loaddir,proc_num,'_CH',num2str(j),pause_string,'.continuous'))
            Ch1 = load_open_ephys_data_faster(strcat(loaddir,proc_num,'_CH',num2str(j),pause_string,'.continuous'));
            Ch1 = Ch1(ephys_start:ephys_end);
            [Ch1, ts_new,fs_new] = Filter_downsample_notch(fs,fs_new,Ch1,notch_true,lpf_true,lpf);
        end
        ECG{i} = Ch1;
    end

    for i = 1:1
        notch_true = 1;
        lpf_true = 1;
        j = Ref_channel(i);
        if isfile(strcat(loaddir,proc_num,'_CH',num2str(j),pause_string,'.continuous'))
            Ch1 = load_open_ephys_data_faster(strcat(loaddir,proc_num,'_CH',num2str(j),pause_string,'.continuous'));
            Ch1 = Ch1(ephys_start:ephys_end);
            [Ch1, ts_new,fs_new] = Filter_downsample_notch(fs,fs_new,Ch1,notch_true,lpf_true,lpf);
        end
        Ref{i} = Ch1;
    end
    if strcmp(task_name,'programming')
        EEG_channels = [1:40, 65:104];
        for i = 1:length(EEG_channels)
            notch_true = 1;
            lpf_true = 1;
            j = EEG_channels(i);
            if isfile(strcat(loaddir,proc_num,'_CH',num2str(j),pause_string,'.continuous'))
                Ch1 = load_open_ephys_data_faster(strcat(loaddir,proc_num,'_CH',num2str(j),pause_string,'.continuous'));
                [Ch1, ts_new,fs_new] = Filter_downsample_notch(fs,fs_new,Ch1,notch_true,lpf_true,lpf);
            else
                Ch1=zeros(1,length(Ref{1}));
            end
            EEG{i} = Ch1;
        end
    end
    pulse_channel = [8];
    for i = 1
        notch_true = 0;
        lpf_true = 0;
        j = pulse_channel(i);
        try
            Ch1 = load_open_ephys_data_faster(strcat(loaddir,proc_num,'_ADC',num2str(j),pause_string,'.continuous'));
        catch ME
            if (strcmp(ME.message, 'Found corrupted record'))
                Ch1=load_corrupted(strcat(loaddir,proc_num,'_ADC',num2str(j),pause_string,'.continuous'),false);
            else
                rethrow(ME)
            end
        end
        Ch1 = Ch1(ephys_start:ephys_end);
        [Ch1, ts_new,fs_new] = Filter_downsample_notch(fs,fs_new,Ch1,notch_true,lpf_true,lpf);
        pulse{i} = Ch1;
        figure;
        plot(pulse{i})
        title('Pulse')
    end
end
