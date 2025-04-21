function [open_ephys_folder_name, open_ephys_folder_num] = find_open_ephys_folder(session_load_dir)

addpath(genpath(strcat(session_load_dir, 'open-ephys\')))
    folders = dir(strcat(session_load_dir, 'open-ephys\'));
    folders(1:2) = [];
    del = [];
    for i = 1:length(folders)
        if ~folders(i).isdir 
            del= [del;i];
        end
    end
    folders(del) = [];
    folder_names = cell(length(folders),1);
    for i = 1:length(folders)
        folder_names{i} = folders(i).name;
    end
    folder_names
    prompt = 'Enter open ephys folder index.';
    open_ephys_folder_num = input(prompt);
    if open_ephys_folder_num ~= 0
        open_ephys_folder_name = folder_names{open_ephys_folder_num};
    else
        open_ephys_folder_name = "";
    end
end