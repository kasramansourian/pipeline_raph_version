function [timecode_new, frame_new] = subtract_timecodes(timecode1,timecode2,frame1,frame2)
% assumes 30fps, subtracts 1 - 2
% if timecode 2 is greater than timecode 1, then subtract 2-1
timecode = timecode1-timecode2;
frame = frame1-frame2;

if timecode(1)<0
    timecode = timecode2-timecode1;
    frame = frame2-frame1;
end

if any(timecode<0) || frame < 0
    if frame<0
        timecode(3) = timecode(3)-1;
        frame = frame+30;
    end
    if timecode(2) <0
        timecode(1) = timecode(1)-1;
        timecode(2) = timecode(2)+60;
    end
    if timecode(3) < 0 
        timecode(2) = timecode(2)-1;
        timecode(3) = timecode(3)+60;
    end
end
        
timecode_new = timecode;
frame_new = frame;
end

