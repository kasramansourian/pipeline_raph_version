function [toggle_inds,toggle_bool] = get_toggles_by_thresholding(signal)
%GET_TOGGLES_BY_THRESHOLDING Summary of this function goes here
%   Detailed explanation goes here
    
    found_toggles = false;
    signal = zscore(signal);
    dt_list = [.01];
    for dt = dt_list
        y_range = round(mean(signal)):dt:max(signal);
        for i = 2:length(y_range)-1
            thresheld_signal = signal > y_range(i);
            thresheld_sig_dt = [0,diff(thresheld_signal)];
            [pks,locs] = findpeaks(abs(thresheld_sig_dt),'Annotate','extents');
            number_of_pks(i) = length(locs);
            if number_of_pks(i) == 8
                first_detected_pos_point = find(thresheld_sig_dt == 1,1,'first');
                first_detected_neg_point = find(thresheld_sig_dt == -1,1,'first');
                if first_detected_pos_point < first_detected_neg_point
                    toggle_inds = locs;
                    toggle_bool = thresheld_signal;
                    found_toggles = true;
                    return;
                end    
            end
        end
    end
    toggle_inds = [];
    toggle_bool = [];

end

