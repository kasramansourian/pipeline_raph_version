function [session_load_dir,savedir] = set_load_save_dir(subject_id,date)
    session_load_dir = strcat('Z:\OCD_Data\',subject_id,' Recordings\',date,'\');
    savedir = strcat('Z:\OCD_Data\preprocessed-new\',subject_id,'\',date,'\');
    % add path to jsonlab
    addpath(genpath('C:\Users\Owner\Documents\GitHub\jsonlab\'))
    addpath(genpath('C:\Libraries\ffmpeg-r8\'))
    addpath(genpath('C:\Libraries\ffmpeg-20190804-01994c9-win64-static\'))
end