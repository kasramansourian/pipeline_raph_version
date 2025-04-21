function vid_name = generate_vid_name(id, date, task_name, time,file_num, camera_num)
    id_num = extractBetween(id, length(id)-1, length(id));
    date_num = erase(date, "-");
    switch task_name
        case "programming"
            task_num = "01";
        case "interview"
            task_num = "02";
        case "provoc"
            task_num = "03";
        case "TSST"
            task_num = "04";
        case "MSIT"
            task_num = "05";
        case "beads"
            task_num = "06";
        case "resting-state"
            task_num = "07";
        otherwise
            task_num = "08";
    end
    file_num = num2str(file_num, "%02d");
    camera_num = num2str(camera_num, "%02d");
    vid_name = char(strcat(id_num, "_", date_num, "_", time, "_",task_num, "_", camera_num, "_", file_num, ".mp4"));
end