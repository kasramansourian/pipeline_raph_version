function [data] = extract_percept_data(data)
%EXTRACT_PERCEPT_DATA Summary of this function goes here
%   Detailed explanation goes here
    
    data.paths.path_to_lfp_folder = [data.paths.percept_data_path,data.subject_id,'/LFP/'];
    ins_device_folders = [dir([data.paths.path_to_lfp_folder '*L']);dir([data.paths.path_to_lfp_folder '*R'])];
    for device = 1:length(ins_device_folders)
        data.paths.path_to_lfp_data{device} = [data.paths.path_to_lfp_folder ins_device_folders(device).name '/'];
        all_lfp_files = dir([data.paths.path_to_lfp_data{device} 'Report*.json']);

        lfp_file_name_split = cellfun(@(x) split(extractBefore(x,'.'),'_'),{all_lfp_files.name}', ...
            'UniformOutput',false);
        percept_session_dates = cellfun(@(x) datetime(x{end}(1:15), ...
                            'InputFormat', data.constants.percept_file_date_string_format, ...
                            'Format', data.constants.timestamp_string_format, ...
                            'TimeZone',data.constants.houston_timezone), ...
                  lfp_file_name_split, 'UniformOutput',false);
    
        correct_percept_file_mask = cell2mat(cellfun(@(x) split(between(x,data.date),{'days'}) == 0, ...
                                    percept_session_dates, 'UniformOutput',false));
        
        correct_percept_file_paths = cellstr(cellfun(@(x) [data.paths.path_to_lfp_data{device} x], ...
                                    {all_lfp_files(correct_percept_file_mask).name}', 'UniformOutput',false));
        session_datetimes = [];
        session_unixtimes = [];

        nearest_start_session = struct(); 
        nearest_start_session.millisec_diff_from_lfp_start_to_eeg_start = 1e12; %arbitratly high to make sure any diff will be smaller than this
        nearest_start_session.session_path = '';
        nearest_start_session.session_ind = 0;

        field_names = {'Start_Time','Channel_Names','Raw_lfp','fs','gain','type','other'};
        combined_td_sessions = struct(field_names{1},[],field_names{2},[],field_names{3},[],field_names{4},[],field_names{5},[],field_names{6},[],field_names{7},[]);
        for i = 1:length(correct_percept_file_paths)
            try
                [js, extracted_data] = extract(correct_percept_file_paths{i});
            catch ME
                continue;
            end
            utc_offset_ins_to_local_time = ['UTC' js.ProgrammerUtcOffset];
            daylight_savings_offset = sscanf(utc_offset_ins_to_local_time,'UTC-%d:00')-5;
            % Check if any session are recorded in file. (if stimVlfp
            % exists then no brainsense. if no stream1-2 then no IndefiniteStreaming
            if (isfield(extracted_data,'stimVlfp') && isempty(extracted_data.stimVlfp)) && isempty(extracted_data.stream1) && isempty(extracted_data.stream2)
                %TODO: Add case for this likely just for chronic data? or
                %at least case where no session data
                continue;
            end
            %Has BrainSense Streaming Data
            if all(isfield(extracted_data,{'BStime','BSlfp'}))
                start_time = cellfun(@(x) datetime(x-hours(daylight_savings_offset),'Format', data.constants.timestamp_string_format,'TimeZone','UTC-00:00'),{extracted_data.BStime.timeStamp}', 'UniformOutput',false);
                channel_names = {extracted_data.BStime.ch}';
                raw_data = {extracted_data.BStime.raw}';
                fs = {extracted_data.BStime.fs}';
                power_data = extracted_data.BSlfp';
                power_data = mat2cell(power_data,ones(size(power_data,1),1),ones(size(power_data,2),1));
                gain = reshape({js.BrainSenseTimeDomain.Gain}',length({js.BrainSenseTimeDomain.Gain}),[])';
                gain = mat2cell(gain,ones(size(gain,1),1),length({js.BrainSenseTimeDomain.Gain}));
                type = repmat({'BrainSenseStreaming'},length(start_time),1);
                combined_td_sessions = [combined_td_sessions; struct(field_names{1},start_time, ...
                    field_names{2},channel_names,field_names{3},raw_data,field_names{4},fs,field_names{5},gain,field_names{6},type,field_names{7},power_data)];

            end
            %Has BrainSense Indefinite Streaming
            if ~isempty(extracted_data.stream1)
                start_time = cellfun(@(x) datetime(x,'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS','Format', data.constants.timestamp_string_format,'TimeZone','UTC-00:00')-hours(daylight_savings_offset),{extracted_data.stream1.FirstPacketDateTime}', 'UniformOutput',false);
                channel_names = {extracted_data.stream1.origLabel}';
                raw_data = {extracted_data.stream1.origDat}';
                fs = {extracted_data.stream1.fs}';
                other = {extracted_data.stream1.gain}';
                power_data = mat2cell(power_data,ones(size(power_data,1),1),ones(size(power_data,2),1));
                gain = {extracted_data.stream1.gain}';
                type = repmat({'IndefiniteStreaming'},length(start_time),1);
                combined_td_sessions = [combined_td_sessions; struct(field_names{1},start_time, ...
                    field_names{2},channel_names,field_names{3},raw_data,field_names{4},fs,field_names{5},gain,field_names{6},type,field_names{7},other)];

            end
            %Remove the blank "session" added at the start to create/concate rest of the sessions from different brain sense 
            if isempty(combined_td_sessions(1).Start_Time)
                combined_td_sessions(1) = []; 
            end
            tmp_session_datetimes = cellfun(@(x) datetime(x,'TimeZone',data.constants.houston_timezone), ...
                                        {combined_td_sessions.Start_Time}', 'UniformOutput',false);
            session_datetimes = [tmp_session_datetimes{:}];
            session_unixtimes = arrayfun(@(x) posixtime(x),session_datetimes)*1e3;

            tmp_session_datetimes_end = cellfun(@(x,y) datetime(x,'TimeZone',data.constants.houston_timezone)+seconds(length(y)/fs{1}), ...
                                        {combined_td_sessions.Start_Time}',{combined_td_sessions.Raw_lfp}', 'UniformOutput',false);
            session_datetimes_end = [tmp_session_datetimes_end{:}];
            session_unixtimes_end = arrayfun(@(x) posixtime(x),session_datetimes_end)*1e3;
        
      
            [min_diff_start, min_ind_start] = min(abs(session_unixtimes - data.brainvision.brainvision_task_start_timestamp_unix));
            [min_diff_end, min_ind_end] = min(abs(session_unixtimes_end - (data.brainvision.brainvision_task_start_timestamp_unix + (length(data.brainvision.time{1})/data.brainvision.fsample)*1e3)));            
            if nearest_start_session.millisec_diff_from_lfp_start_to_eeg_start > min_diff_start
                nearest_start_session.millisec_diff_from_lfp_start_to_eeg_start = min_diff_start;
                nearest_start_session.session_ind = min_ind_start;
                nearest_start_session.session_path = correct_percept_file_paths{i};
                nearest_start_session.data = combined_td_sessions(min_ind_start);
            end
 
            
        end

        [js,extracted_data] = extract(nearest_start_session.session_path);
        utc_offset_ins_to_local_time = ['UTC' js.ProgrammerUtcOffset];
        daylight_savings_offset = sscanf(utc_offset_ins_to_local_time,'UTC-%d:00')-5;
        session_count = 1;
        combined_tmp = [];
        for session_ind = min_ind_start:min_ind_end
            this_session = combined_td_sessions(session_ind);
    
            % power_data = extracted_data.BSlfp(nearest_session.session_ind);
            start_time = datetime(this_session.Start_Time,'TimeZone','UTC-00:00','Format', data.constants.timestamp_string_format);
            start_time.TimeZone = data.constants.houston_timezone;
            
            %copy extracted data to data variable
            data.neural(device).lead_location  = extracted_data.hdr.LeadLocation; 
    
            % 
            time_from_recording_start = (1:length(this_session.Raw_lfp))/this_session.fs;
            timestamp_datetime = start_time + seconds(time_from_recording_start);
            timestamp_unixtime = posixtime(timestamp_datetime) * 1e3; %in milliseconds
            
            raw_lfp = this_session.Raw_lfp;
            td_channel_names = strcat(['TD_' data.neural(device).lead_location '_'], this_session.Channel_Names); %Add prefix TD so we know these are timedomain channels
            data.neural(device).combined_data_table{session_count} = table(timestamp_datetime',timestamp_unixtime',raw_lfp,'VariableNames',["Datetime","Timestamp","tmp"]);
            data.neural(device).combined_data_table{session_count} = splitvars(data.neural(device).combined_data_table{session_count},"tmp",'NewVariableNames',td_channel_names);
            hemisphere_order = cellfun(@(x) extractAfter(x,'.'), {extracted_data.hdr.LeadConfiguration.Initial.Hemisphere}', 'UniformOutput', false);
            
            switch this_session.type
                case 'BrainSenseStreaming'
                    power_data = this_session.other;
                    sample_index_of_power = arrayfun(@(x) find(time_from_recording_start >= x, 1), power_data.time);
                    power_combined = nan(height(data.neural(device).combined_data_table{session_count} ),width(power_data.power));
                    stim_combined = nan(height(data.neural(device).combined_data_table{session_count} ),width(power_data.stim));
    
                    power_combined(sample_index_of_power,:) = power_data.power;
                    stim_combined(sample_index_of_power,:) = power_data.stim;
                    % extract power settings
                    power_settings = power_data.lfpsettings;
                    power_settings_format_spec = 'PEAK%fHz_THR%f-%f_AVG%fms';
                    power_settings_scaned = cellfun(@(x) sscanf(x,power_settings_format_spec),power_settings,'UniformOutput',false);
                    if isempty(power_settings_scaned{1})
                        power_settings_scaned{1} = [-1,-1,-1,-1];
                    end
                    data.neural(device).power_settings.center_freq = cellfun(@(x) x(1), power_settings_scaned);
                    data.neural(device).power_settings.thresholds = cell2mat(cellfun(@(x) [x(2),x(3)], power_settings_scaned, 'UniformOutput', false));
                    data.neural(device).power_settings.power_averaging_window = cellfun(@(x) x(4), power_settings_scaned);
                    % 
                    power_channel_names = strcat('POW_', num2str(data.neural(device).power_settings.center_freq), 'HZ_', hemisphere_order); %Add prefix TD so we know these are timedomain channels
                    stim_channel_names = strcat('STIM_AMP_', hemisphere_order); %Add prefix TD so we know these are timedomain channels
    
                    power_combined = splitvars(table(power_combined),"power_combined",'NewVariableNames', power_channel_names);
                    stim_combined = splitvars(table(stim_combined),"stim_combined",'NewVariableNames', stim_channel_names);
    
                    data.neural(device).combined_data_table{session_count} = [data.neural(device).combined_data_table{session_count}, power_combined, stim_combined];
    
                case 'IndefiniteStreaming'
                    disp('Cat')
            end
            combined_tmp = [combined_tmp;data.neural(device).combined_data_table{session_count}];
            session_count = session_count+1;
        end
        data.neural(device).combined_data_table = combined_tmp;
        data.neural(device).fs = this_session.fs;
        data.neural(device).INS_Location = extractAfter(extracted_data.hdr.DeviceInformation.Initial.NeurostimulatorLocation,'.');
        data.neural(device).hdr = extracted_data.hdr;
        data.neural(device).hdr.Z = extracted_data.Z;
        data.neural(device).lfp_snapshots = extracted_data.LFP_Snapshots;
        data.neural(device).lfp_montage = extracted_data.LFPMontage;
        data.neural(device).signal_check = extracted_data.SignalCheck;    
    end
    field_name_order = ["lead_location","combined_data_table","fs","power_settings","INS_Location","hdr","lfp_snapshots","lfp_montage","signal_check"];
    data.neural = orderfields(data.neural,field_name_order);

end

