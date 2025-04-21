
addpath('C:\Users\Nicole\OneDrive\Documents\Brown Grad\OCD project\BeadsTask1\analysis-tools-master\')
addpath('C:\Users\Nicole\OneDrive\Documents\Brown Grad\OCD project\EEG test data\2018-10-10_16-35-14\')
loaddir = 'C:\Users\Nicole\OneDrive\Documents\Brown Grad\OCD project\EEG test data\2018-10-10_16-35-14\';
Channels = cell(8,1);
figure;

for i = 1:8
Channels{i} = load_open_ephys_data(strcat(loaddir,'100_ADC',num2str(i),'.continuous'));
subplot(8,1,i)
plot(Channels{i}')
hold on
end
% light on channel 2
light = Channels{2}';
% timecode on channel 8
data = Channels{8};
save(strcat(loaddir,'open_ephys_pulse_test.mat'),'data');
[openephys_frame,openephys_time,thresh,timecode_start_open_ephys,data]=ltc_decode('open_ephys_pulse_test.mat');

%%
%From 10/9/2018 test, `ffprobe -i GH010004.MP4`
%creation_time= '2018-10-09';
%timecode = [0,9,13];
%video_frame_counter = 14;

%From 10/10/2018 test
timecode_start = [0, 15, 49];
video_frame_start = 23;
timecode_end = [0,16,22];
video_frame_end = 21;

% open file in video reader to get video frames
v = VideoReader(strcat(loaddir,'video\','GH010021.mp4'));
num_video_frames = v.NumberofFrames;

%%

% did the video start after the open ephys start?
% if so, find the start index of the open ephys recording
val = compare_timecode(timecode_start,video_frame_start,openephys_time(1,:),openephys_frame(1));
if and(timecode_start(1,3) > openephys_time(1,3),timecode_start(1,2) >= openephys_time(1,2))
    for i = 1:size(openephys_time,1)
        if and(openephys_time(i,1:3)==timecode_start, openephys_frame(i)==video_frame_start)
            start_i_openephys = i;
            break;
        end
    end
end  
% did the video end after open ephys ended?
% if so, find the start index of the video recording
val = compare_timecode(timecode_end,video_frame_end,openephys_time(end,:),openephys_frame(end));
if val == -1 
    for i = 1:size(openephys_time,1)
        if and(openephys_time(i,1:3)==timecode_end, openephys_frame(i)==video_frame_end)
            end_i_openephys = i;
            break;
        end
    end
end  

% sync open ephys recording with video recording
openephys_time_sync = openephys_time(start_i_openephys:end_i_openephys,:);
openephys_frame_sync = openephys_frame(start_i_openephys:end_i_openephys);

% 
timecode_start_open_ephys_sync = timecode_start_open_ephys(start_i_openephys:end_i_openephys,:);

% plot the light pulse
figure;
plot(light)
ax = gca;
ax.XLim = [timecode_start_open_ephys_sync(1),timecode_start_open_ephys_sync(end)];
yax = ax.YLim;

% index into light with the rounded indices of each timecode
lightx = light(round(timecode_start_open_ephys_sync));

%%
slide = 1;
%bounds = [390,800];
window_size = 200;
%entire video
bounds = [1,size(openephys_frame_sync)];
screen_show1 = [bounds(1):slide:bounds(2)-window_size]';
screen_show2 = [window_size+bounds(1):slide:bounds(2)]';
frames = (bounds(1):bounds(2))';
v = VideoReader(strcat(loaddir,'video\','GH010021.mp4'));
version = '1';

for l = 1:size(screen_show1,1)
    
    fig = figure('Color','w');
    subplot(5,1,5)
    plot(lightx(screen_show1(l):screen_show2(l)))
    ax = gca;
    ax.XLim = [0,window_size];
    ax.YLim = yax;
    title(strcat(num2str(openephys_time_sync(screen_show1(l),1)),':',num2str(openephys_time_sync(screen_show1(l),2)),':',num2str(openephys_time_sync(screen_show1(l),3)),':',num2str(openephys_frame_sync(screen_show1(l)))))
    hold on
    h(1) = subplot(5,1,[1,2,3,4]);
    v.CurrentTime = (screen_show1(l))/30;
    frame = readFrame(v);
    imshow(frame);
    truesize
    box off
    axis off
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 20 10];
    fig.InvertHardcopy = 'off';
    print(strcat(loaddir,'images/',num2str(l)),'-dpng','-r0')
    close all
    hold on
    images{l} = imread(strcat(loaddir,'images/',num2str(l),'.png'));
    imshow(images{l})
 end
 
 % create the video writer with 1 fps
 writerObj = VideoWriter(strcat('demo',version,'.avi'));
 writerObj.FrameRate = 15;
 
 % set the seconds per image
 secsPerImage = ones(size(screen_show1,1),1);
 
 % open the video writer
 open(writerObj);
 % write the frames to the video
 for u=1:length(images)
     % convert the image to a frame
     frame = im2frame(images{u}); 
     for v=1:secsPerImage(u) 
         writeVideo(writerObj, frame);
     end
 end
 % close the writer object
 close(writerObj);


    
    

