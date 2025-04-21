function cut_path = cut_video(rewrite_tag, start_str, end_str, cam_file, task_name)
i = '-i';
fn = cam_file;
ss = '-ss';
space = ' ';
c = '-to';
d = '-c copy';
cut_path = [cam_file(1:(end-4)) '_' task_name '_cut.mp4'];
%end_str = duration_1;

arg = [i space fn space ss space start_str space c space end_str space '-threads 16 -preset ultrafast' space rewrite_tag space cut_path];
ffmpegexec(arg)
end