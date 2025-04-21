
function [video_load_dir,cam_num,camera_folder_names] = find_video_loaddir(session_load_dir)
    folders = dir(session_load_dir);
    camera_folders = [];
    for i = 1:length(folders)
        if strfind(lower(folders(i).name),'camera')
            camera_folders;
            folders(i).name;
            camera_folders = [camera_folders;folders(i).name];
        end
    end
    cam_num = size(camera_folders,1);
    camera_folder_names = cell(cam_num,1);
    for i = 1:cam_num
        camera_folder_names{i} = camera_folders(i,:);
    end

    
    video_load_dir = cell(cam_num,1);
    for i = 1:cam_num
        video_load_dir{i} = strcat(session_load_dir,camera_folder_names{i},'/');
    end
    
    
end

