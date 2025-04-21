function silent_path = strip_audio(rewrite_tag, cam_file)
    % Strip off audio track to create a silent video:
    silent_path = [cam_file(1:(end-7)), 'silent.mp4'];
    arg = strcat("-i ", cam_file," -map 0:0 -acodec copy -vcodec copy ", rewrite_tag, " ", silent_path);
    arg=char(arg);
    ffmpegexec(arg)
end
