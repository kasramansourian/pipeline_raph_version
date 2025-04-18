function [behavior,data,start_time,time_end,task_version] = extract_paat_task_data(behavjson_fullpath)
% the difference between movement_analysis and movement_analysis_new are:
% The output of _new is a table. The output of  movement_analysis is a matrix
% The first two columns in the table is identical to the output of movement_analysis
% The third column is added to indicate event name corresponding to the
% event codes.
    % behavjson_fullpath = 'Z:\OCD_Data\Percept\Data\010\2024-01-03\PAAT\PAAT_P010_1_b_01-03-24';
    data = load(behavjson_fullpath);
    start_time_str = [data.p.date,data.p.startTime];
    start_time = datetime(start_time_str,'TimeZone','Etc/GMT-6','InputFormat','yyyy-MM-ddhh:mm:ss.SSS a');
    time_end = start_time + minutes(30);
    start_time = posixtime(start_time) * 1e3;
    time_end = posixtime(time_end) * 1e3;
    behavior = table(start_time, 0, 0,'VariableNames',{'Timestamp','Task_Time','Event_Code'});
    task_version = 'v1.0.0.1';
    
end
