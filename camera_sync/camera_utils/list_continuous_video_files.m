function continuous_files_all = list_continuous_video_files(video_load_dir,cam_num)

camera_file_names_all = cell(cam_num,1);

    for i = 1:cam_num
        files = dir(video_load_dir{i});
        files(1:2) = [];
        delete_files = [];
        for j = 1:length(files)
            if ~strcmp('.MP4',files(j).name(end-3:end))
                delete_files = [delete_files,j];
            end            
        end
        files(delete_files) = [];
        
        temp = cell(length(files),1);
        for j = 1:length(files)
            temp{j} = files(j).name;
        end
        camera_file_names_all{i} = temp;
    end
    
    % for each camera, if the last 4 digits are the same then it's
    % continuous
    continuous_files_all = {};
    for i = 1:cam_num
        temp_names = camera_file_names_all{i};
        cont_temp = {};
        continuous_files = {};
        for j = 1:size(temp_names,1)
            dig_oi = temp_names{j}(5:8);
            % if we are looking at the first file in a list of continuous
            % files, then check the rest of the list for other files that
            % belong with it
            cont_temp = {};
            if strcmp(temp_names{j}(4),'1')
            cont_temp{1} = temp_names{j};
                c = 2;
                for k = (j+1):size(temp_names,1)
                    dig = temp_names{k}(5:8);
                    if strcmp(dig,dig_oi)
                        cont_temp{c} = temp_names{k};
                        c = c+1;
                    end
                end
            end
            if ~isempty(cont_temp)
                continuous_files{j} = cont_temp;
            end
        end
        continuous_files_all{i} = continuous_files;

    end
                    
end