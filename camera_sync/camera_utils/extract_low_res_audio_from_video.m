function extract_low_res_audio_from_video(savedir_AV, lowres_audio_fname, output)
if ~exist(strcat(savedir_AV, lowres_audio_fname))
    % extract low res audio from video
    arg = ['-i ' output ' -vn -acodec copy ' savedir_AV lowres_audio_fname];
    ffmpegexec(arg)
end