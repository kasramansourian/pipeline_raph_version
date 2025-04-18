function [data] = toggle_sync(data)
%TOGGLE_SYNC Summary of this function goes here
%   Detailed explanation goes here
    num_of_devices = length(data.neural);
    all_offset = [];
    ekg_mask = cell2mat(cellfun(@(x) any(strcmpi(x,{'EKG','ECG'})),data.brainvision.label,'UniformOutput',false));
    if sum(ekg_mask) == 0; error('No EKG Channel Found! Please check Brainvision recording includes a labeled EKG channel.');end
    ekg = data.brainvision.trial{1,1}(ekg_mask,:);
    ekg_time = data.brainvision.brainvision_task_start_timestamp_unix  + data.brainvision.time{1,1}*1e3;
    
    % [~, ekg_2nd_event_ind] = min(abs(ekg_time-data.processed.Events.Timestamp(2)));
    % [~, ekg_last_event_ind] = min(abs(ekg_time-data.processed.Events.Timestamp(end)));
    midpoint_ind = round(length(ekg)/2);

    [start_ekg_toggle_inds, start_ekg_toggle_bool] = find_ekg_toggles(ekg(1:midpoint_ind),data.brainvision.fsample);
    
    [end_ekg_toggle_inds, end_ekg_toggle_bool] = find_ekg_toggles(ekg(midpoint_ind:end),data.brainvision.fsample);
    
    



    lfp_time = cellfun(@(x) x.Timestamp,{data.neural.combined_data_table}','UniformOutput',false);
    lfp = cellfun(@(x) x(:,contains(fields(x),'TD_')),{data.neural.combined_data_table}','UniformOutput',false);
    
    for ins = 1:length(lfp)
        start_lfp_xcorr_r = [];
        start_lfp_xcorr_lag = [];
        end_lfp_xcorr_r = [];
        end_lfp_xcorr_lag = [];
        for chan = 1:width(lfp{ins})
            lfp_time = cellfun(@(x) x.Timestamp,{data.neural.combined_data_table}','UniformOutput',false);
            
            

            %Find Start Toggles
            [start_lfp_toggles_sample_number{ins,chan}, start_lfp_toggles_bool{ins,chan}] = find_lfp_toggles(lfp{ins}{1:int32(end/2),chan}',data.neural(ins).fs,data.brainvision.fsample);
            [end_lfp_toggles_sample_number{ins,chan}, end_lfp_toggles_bool{ins,chan}] = find_lfp_toggles(lfp{ins}{int32(end/2):end,chan}',data.neural(ins).fs,data.brainvision.fsample);
                

            %Get offet of Start Toggles
            if ~isempty(start_ekg_toggle_inds)
                [r, lag] = xcorr(start_ekg_toggle_bool,start_lfp_toggles_bool{ins,chan});
                start_lfp_xcorr_r(chan,:) = r;
                start_lfp_xcorr_lag(chan,:) = lag;
                
            end
            
            %Get offet of End Toggles
            if ~isempty(end_ekg_toggle_inds)
                [r, lag] = xcorr(end_ekg_toggle_bool,end_lfp_toggles_bool{ins,chan});
                end_lfp_xcorr_r(chan,:) = r;
                end_lfp_xcorr_lag(chan,:) = lag;
            end 
            

        end
        figure; hold on;
        plot(ekg_time,ekg/max(ekg))
        %Identify Best Channel for start toggle alignment
        start_ekg_toggle_inds = [];
        start_ekg_toggle_bool = [];
        if ~isempty(start_ekg_toggle_inds)
            
            [r, ind_of_best_fit_start] = max(start_lfp_xcorr_r,[],2);
            [~, best_chan_start] = max(r);
            shift_in_start_lfp_to_ekg = start_lfp_xcorr_lag(best_chan_start,ind_of_best_fit_start(best_chan_start));
            start_ind_shift = shift_in_start_lfp_to_ekg / data.brainvision.fsample * data.neural(ins).fs;
            if shift_in_start_lfp_to_ekg <= 0
                ekg_start_sync_ind = 1;
                lfp_start_sync_ind = max(1,round(abs(start_ind_shift)));   % max(1,abs(round(shift_in_start_lfp_to_ekg * data.brainvision.fsample))));
            else
                ekg_start_sync_ind = shift_in_start_lfp_to_ekg;
                lfp_start_sync_ind = 1;

            end
            lfp_start_syncpoint = lfp_time{ins}(lfp_start_sync_ind);
            ekg_start_syncpoint = ekg_time(ekg_start_sync_ind);
            start_lfp_time_offset_in_ms{ins} = ekg_start_syncpoint-lfp_start_syncpoint;
            lfp_time{ins} = lfp_time{ins} + start_lfp_time_offset_in_ms{ins};    
            data.neural(ins).Applied__msec_Offset_Correction = start_lfp_time_offset_in_ms{ins};
            
            plot(ekg_time(1:midpoint_ind),start_ekg_toggle_bool,'Color','blue','LineWidth',2)
            scatter(ekg_time(ekg_start_sync_ind),1.1)
            scatter(lfp_time{ins}(lfp_start_sync_ind),1.2)
        end
            
        %Identify Best Channel for end toggle alignment
        if ~isempty(end_ekg_toggle_inds)
            [r, ind_of_best_fit_end] = max(end_lfp_xcorr_r,[],2);
            [~, best_chan_end] = max(r);
            shift_in_end_lfp_to_ekg = end_lfp_xcorr_lag(best_chan_end,ind_of_best_fit_end(best_chan_end)) - shift_in_start_lfp_to_ekg;
            end_ind_shift = shift_in_end_lfp_to_ekg / data.brainvision.fsample * data.neural(ins).fs;

            if shift_in_end_lfp_to_ekg <= 0
                ekg_end_sync_ind = length(ekg_time);
                lfp_end_sync_ind = round(length(lfp_time{ins})+end_ind_shift); % round(length(lfp_time{ins})/2)+max(1,abs(round(shift_in_end_lfp_to_ekg * (data.neural(ins).fs/data.brainvision.fsample))));
            else
                ekg_end_sync_ind = length(ekg_time)-(shift_in_end_lfp_to_ekg);
                lfp_end_sync_ind = length(lfp_time{ins});

            end
            lfp_end_syncpoint = lfp_time{ins}(lfp_end_sync_ind);
            ekg_end_syncpoint = ekg_time(ekg_end_sync_ind);
            end_lfp_time_offset_in_ms{ins} = ekg_end_syncpoint-lfp_end_syncpoint;

            if isempty(start_ekg_toggle_bool)
                lfp_time{ins} = lfp_time{ins} + end_lfp_time_offset_in_ms{ins};
                data.neural(ins).Applied__msec_Offset_Correction = end_lfp_time_offset_in_ms{ins};
            else
                %Drift Correction if possible (need start and end toggles)
                drift = end_lfp_time_offset_in_ms{ins}; %start_sync_point_already aligned to 0
                ms_from_start_syncpoint = (lfp_time{ins}-lfp_time{ins}(lfp_start_sync_ind));
                drift_correction_ratio = (ms_from_start_syncpoint(lfp_end_sync_ind) + drift)/ms_from_start_syncpoint(lfp_end_sync_ind);
                lfp_time{ins} = lfp_time{ins}(lfp_start_sync_ind) + (ms_from_start_syncpoint * drift_correction_ratio);
                data.neural(ins).drift = drift;
                data.neural(ins).drift_correction_ratio =drift_correction_ratio;
            end
            scatter(ekg_time(ekg_end_sync_ind),1.1)
            scatter(lfp_time{ins}(lfp_end_sync_ind),1.2)
            plot(ekg_time(midpoint_ind:end),end_ekg_toggle_bool,'Color','blue','LineWidth',2)
        end  
  


        
        plot(lfp_time{ins},table2array(lfp{ins})/max(table2array(lfp{ins})),'Color','green')
        plot(linspace(lfp_time{ins}(1),lfp_time{ins}(int32(end/2)),length(start_lfp_toggles_bool{ins,chan})),start_lfp_toggles_bool{ins,chan},'Color','red','LineWidth',2)
        plot(linspace(lfp_time{ins}(int32(end/2)),lfp_time{ins}(end),length(end_lfp_toggles_bool{ins,chan})),end_lfp_toggles_bool{ins,chan},'Color','red','LineWidth',2)

        
       
        
        do_manual_toggle_sync = input('Enter 0 to Continue or Enter 1 for Manual Time Sync: ');
        if do_manual_toggle_sync
            manual_sync(data)
        end

        data.neural(ins).combined_data_table.Timestamp = lfp_time{ins};
        data.neural(ins).combined_data_table.Datetime  = datetime(lfp_time{ins},...
                                                        'ConvertFrom','posixtime', ...
                                                        'Format',data.constants.timestamp_string_format, ...
                                                        'TimeZone',data.constants.houston_timezone);

    end

  
    


end

