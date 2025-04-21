function [extrap_tc, extrap_frame] = extrapolate_timecode(A, V, ftv, ffv)
    A_t = zeros(1, size(A,1));
    V_t = zeros(1, size(V,1));
    for i=1:length(A_t)
        A_t(i) = A(i,1)*60*60+A(i,2)*60+A(i,3)+A(i,4)/30;
        V_t(i) = V(i,1)*60*60+V(i,2)*60+V(i,3)+V(i,4)/30;
    end

    figure
    plot(V_t, A_t)
    lm = fitlm(V_t, A_t)
    
    vid_extrap = ftv(1)*60*60+ftv(2)*60+ftv(3)+ffv/30;
    aud_extrap = interp1(V_t, A_t, vid_extrap);
    hours = floor(aud_extrap/(60*60));
    minutes = floor(aud_extrap/60)-hours*60;
    seconds = floor(aud_extrap)-minutes*60-hours*60*60;
    extrap_tc = [hours, minutes, seconds];
    extrap_frame = floor((aud_extrap-floor(aud_extrap))*30);
end