function [timecode_new, frame_new] = add_timecodes(timecode1,timecode2,frame1,frame2)
% assumes 30fps, adds 1 + 2
timecode = timecode1+timecode2;
frame = frame1+frame2;
if frame>=30
    timecode(3) = timecode(3)+1;
    frame = frame-30;
end

if timecode(2) >= 60 
    timecode(1) = timecode(1)+1;
    timecode(2) = timecode(2)-60;
end
if timecode(3) >= 60 
    timecode(2) = timecode(2)+1;
    timecode(3) = timecode(3)-60;
end
    
timecode_new = timecode;
frame_new = frame;
end