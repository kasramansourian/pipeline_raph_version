function merge_list_of_videos(savedir_AV, output, file_list)
    if ~exist([savedir_AV output])
         arg = ['-f concat -safe 0 -i',' ', file_list, ' -c copy',' ', savedir_AV output];
         ffmpegexec(arg)
    end
    disp('Done!')
end