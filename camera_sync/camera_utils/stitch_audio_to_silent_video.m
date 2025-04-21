function final_path = stitch_audio_to_silent_video(savedir_final, final_path, rewrite_tag, audio_path, cam_file)
final_path = strcat(savedir_final, final_path);
i = '-i';
cv = '-c:v copy';
ca = '-c:a aac';
space = ' ';
arg = [i space cam_file space i space audio_path space cv space ca space rewrite_tag space final_path];
ffmpegexec(arg)
end