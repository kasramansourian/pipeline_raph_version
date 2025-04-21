function [video_sync,task_file_input,num_cams_input] = cross_camera_sync_BV(video_struct, cam_num)
    % compare videos across cameras

    % check if subsequent video start timecodes are increasing 
    comp_tc = video_struct(1).cams(1).start_tc;
    comp_frame = video_struct(1).cams(1).start_frame;
    increasing = true;
    if length(video_struct(1).cams)==1
        increasing = false
    end
    for i=2:length(video_struct(1).cams)
        if compare_timecode(comp_tc, comp_frame, video_struct(1).cams(i).start_tc, video_struct(1).cams(i).start_frame) == 1
            increasing = false;
            break
        end
        comp_tc = video_struct(1).cams(i).start_tc;
        comp_frame = video_struct(1).cams(i).start_frame;
    end
    task_file_input = [];
    num_cams_input = [];

    if increasing
        % subsequent videos have subsequent timecodes
        % cameras can therefore be synced by relating timecodes

        % iterate through all files on first cam
        for i = 1:(size(video_struct(1).cams,2))
            video_sync(i).cams(1) = video_struct(1).cams(i);

            % iterate through other cameras
            for j = 2:cam_num
                % all files on other camera
                for k = 1:size(video_struct(j).cams,2)
                    % cam 1 start: A
                    % cam 1 end: B
                    % cam 2 start: C
                    % cam 2 end: D
                    % if A < C < B OR C < A < D
                        % break 
                    % end

                    A_tc = video_struct(1).cams(i).start_tc;
                    B_tc = video_struct(1).cams(i).end_tc;
                    A_f = video_struct(1).cams(i).start_frame;
                    B_f = video_struct(1).cams(i).end_frame;

                    C_tc = video_struct(j).cams(k).start_tc;
                    D_tc = video_struct(j).cams(k).end_tc;
                    C_f = video_struct(j).cams(k).start_frame;
                    D_f = video_struct(j).cams(k).end_frame;

                    return_val1 = compare_timecode(C_tc,C_f,A_tc,A_f);
                    return_val2 = compare_timecode(B_tc,B_f,C_tc,C_f);

                    return_val3 = compare_timecode(A_tc,A_f,C_tc,C_f);
                    return_val4 = compare_timecode(D_tc,D_f,A_tc,A_f);
                    % add file to output structure            
                    if or(return_val1>=0 && return_val2>=0, return_val3>=0 && return_val4>=0)
                        video_sync(i).cams(j) = video_struct(j).cams(k);
                        break;
                    end
                end
            end
        end
    else
        % video timecodes are not subsequent, timecodes can not be used to sync
        % across cameras
        %task_sync = input("Unable to sync using timecodes, continue with manual (0) or task (1) sync: ");
        task_sync = 1;
        c=0;
        if task_sync
            % Sync multiple cameras based on the expected number of cameras
            % for a task
            disp(strcat(num2str(length(video_struct(1).cams)), " unique files, input number of cameras for each file"))
            tasks = zeros(1, length(video_struct(1).cams));
            for i=1:length(tasks)
                
                tasks(i) = input(strcat("Number of cameras: "));
                num_cams_input = [num_cams_input;tasks(i)];
            end
            task_cams = cell(1, length(video_struct)-1);
            
            for i=2:length(video_struct) %Himi Why does i start from 2?
                disp("Enter a 1 if the camera file is related to a task: ")
                num_vids_for_cam = 0;
                for j=1:length(video_struct(i).cams)
                    video_struct(i).cams(j)
                    good = input("Task file?: ");
                    task_file_input = [task_file_input; good];
                    if good
                        num_vids_for_cam = num_vids_for_cam+1;
                        task_vids{num_vids_for_cam} = video_struct(i).cams(j);
                    end
                end
                task_cams{i-1} = task_vids;
            end
            cam_two_count = 0;
            cam_three_count = 0;

            for i=1:length(tasks)
                video_sync(i).cams(1) = video_struct(1).cams(i);
                if tasks(i) >= 2
                    cam_two_count = cam_two_count + 1;
                    
                    video_sync(i).cams(2) = task_cams{1}{cam_two_count};
                end
                if tasks(i) == 3
                    cam_three_count = cam_three_count + 1;
                    video_sync(i).cams(3) = task_cams{2}{cam_three_count};
                end
            end
        else
            % Manually associate all camera2/3 files with a camera1 file
            for i=1:length(video_struct(1).cams)
                disp(strcat(num2str(i), ": "))
                video_struct(1).cams(i)
                video_sync(i).cams(1) = video_struct(1).cams(i);
            end
            disp(strcat(num2str(length(video_struct(1).cams)), " unique camera 1 files"))
            for i=2:length(video_struct)
                for j=1:length(video_struct(i).cams)
                    video_struct(i).cams(j)
                    vid_num = input("Input the associated camera 1 file: ");
                    video_sync(vid_num).cams(i) = video_struct(i).cams(j);
                end
            end
        end
    end

    for i = 1:(size(video_struct(1).cams,2))
        % define start and end of video based on last start and first end
        vid_start_tc1 = video_sync(i).cams(1).start_tc;
        vid_end_tc1 = video_sync(i).cams(1).end_tc;
        vid_start_frame1 = video_sync(i).cams(1).start_frame;
        vid_end_frame1 = video_sync(i).cams(1).end_frame;
        no_overlap = true;
        for j = 2:length(video_sync(i).cams)
            vid_start_tc2 = video_sync(i).cams(j).start_tc;
            vid_end_tc2 = video_sync(i).cams(j).end_tc;
            vid_start_frame2 = video_sync(i).cams(j).start_frame;
            vid_end_frame2 = video_sync(i).cams(j).end_frame;

            return_val_start = compare_timecode(vid_start_tc1,vid_start_frame1,vid_start_tc2,vid_start_frame2);
            if return_val_start < 0 
                vid_start_tc1 = vid_start_tc2;
                vid_start_frame1 = vid_start_frame2;
            end

            return_val_end = compare_timecode(vid_end_tc1,vid_end_frame1,vid_end_tc2,vid_end_frame2);
            if return_val_end > 0 
                vid_end_tc1 = vid_end_tc2;
                vid_end_frame1 = vid_end_frame2;
            end
            
            return_val_start_end1 = compare_timecode(vid_start_tc1,vid_start_frame1,vid_end_tc2,vid_end_frame2);
            return_val_start_end2 = compare_timecode(vid_start_tc2,vid_start_frame2,vid_end_tc1,vid_end_frame1);
            if no_overlap
                no_overlap = ~or(return_val_start_end1>0, return_val_start_end2>0);
            end
        end
        video_sync(i).start_TC = vid_start_tc1;
        video_sync(i).start_frame = vid_start_frame1;
        video_sync(i).end_TC = vid_end_tc1;
        video_sync(i).end_frame = vid_end_frame1;
        video_sync(i).no_overlap = no_overlap;
    end
end