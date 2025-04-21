function return_val = compare_timecode(timecode1,frame1,timecode2,frame2)
    if timecode1(1,1)>timecode2(1,1)
        return_val = 1;
    elseif timecode1(1,1)<timecode2(1,1)
        return_val = -1;
    else %if it's equal
        if timecode1(1,2)>timecode2(1,2)
            return_val = 1;
        elseif timecode1(1,2)<timecode2(1,2)
            return_val = -1;
        else
            if timecode1(1,3)>timecode2(1,3)
                return_val = 1;
            elseif timecode1(1,3)<timecode2(1,3)
                return_val = -1;
            else
                if frame1(1,1)>frame2(1,1)
                    return_val = 1;
                elseif frame1(1,1)<frame2(1,1)
                    return_val = -1;
                else 
                    return_val = 0;
                end
            end
        end
    end
end
                
        
        
