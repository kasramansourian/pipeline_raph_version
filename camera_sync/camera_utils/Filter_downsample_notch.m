function [ds_notch_Ch1, ts_new,fs_new] = Filter_downsample_notch(fs,fs_new,Ch1,notch_true,lpf_true,lpf)
% Build bandpass filter .1-1000 Hz of order 100
n = 100; %filter order
% fN = fs/2;
% lowcut = .1;
% highcut = 250;
% Wn = [lowcut/fN,highcut/fN];
% [b,a]= fir1(n,Wn,'bandpass');
% % Apply filter using filtfilt (zero time lag)
% if filt_true ==1
% Ch1_filt = filtfilt(b,a,Ch1);
% else
% Ch1_filt = Ch1;
% end

% Downsample data to 1000 Hz
signal_length = length(Ch1);
ts = 1/fs:1/fs:signal_length/fs;
% ds_Ch1 = resample(Ch1_filt,ts,fs_new);
r = fs/fs_new; %factor that we are downampling by: 30
ds_Ch1 = decimate(Ch1,r);
ts_new = 1/fs_new:1/fs_new:length(ds_Ch1)/fs_new;

%Plot figure showing downsampled and filtered data
% figure;
% plot(ts_new,ds_Ch1)
% title('EEG @ 500 Hz, bandpass filter: .1-500 Hz')
% xlabel('Time in seconds')
% ylabel('uV')
% ax = gca;
% ax.YLim = [-500,500];

% low pass filter 
if lpf_true
ds_Ch1 = filtfilt(lpf, ds_Ch1);
end

% Design notch filter
if notch_true ==1
lowcut = 59.9;
highcut = 60.1;
fN = fs_new/2;
Wn = [lowcut/fN,highcut/fN];
[b,c] = fir1(n,Wn,'bandpass'); 
ys1= filtfilt(b,c,ds_Ch1);
ds_notch_Ch1 = ds_Ch1-ys1;
else
    ds_notch_Ch1 = ds_Ch1;
end
 %saveas(gcf,strcat('EEG',num2str(j),'.png'))

% figure;
% plot(ts_new,ds_notch_Ch1)
% title('EEG @ 500 Hz, bandpass filter: .1-500 Hz, notch filter: 59-61, 119-121, 179-181 Hz')
% xlabel('Time in seconds')
% ylabel('uV')
% ax = gca;
% ax.YLim = [-500,500];
% saveas(gcf,strcat('EEG',num2str(j),'.png'))
end
