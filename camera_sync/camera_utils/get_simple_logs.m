
%% Left Device IDs:
% 012: DeviceNPC700507H
% 011: DeviceNPC700550H
% 010: DeviceNPC700543H
% 009: DeviceNPC700500H
% 008: DeviceNPC700514H


%% Right Device IDs:
% 012: DeviceNPC700549H
% 011: DeviceNPC700551H
% 010: DeviceNPC700544H
% 009: DeviceNPC700501H
% 008: DeviceNPC700515H

%% Set up for both phases, has not been tested for Phase I bc no simple stim log yet



function simple_logs = get_simple_logs(data,phase)
simple_logs={};
if phase==1
    INS = data.simple_stim_log;
    INS = movevars(INS,'Video_Timestamp','After','Time');
        simple_logs.INS = INS;
end

if phase ==2
    for i = 1:2
        hem = data(i).hemisphere;
        if strcmp(hem,'right')
            right_hemisphere = data(i).simple_stim_log;
            right_hemisphere = movevars(right_hemisphere,'Video_Timestamp','After','Time');
            simple_logs.Right_Hemisphere = right_hemisphere;

        end
        if strcmp(hem,'left')
            left_hemisphere = data(i).simple_stim_log;
            left_hemisphere = movevars(left_hemisphere,'Video_Timestamp','After','Time');
            simple_logs.Left_Hemisphere = left_hemisphere;
        end
    end
end
end



