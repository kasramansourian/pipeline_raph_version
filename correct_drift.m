function [timestamp_set2, first_event_offset, drift, drift_correction_ratio] = correct_drift(timestamp_set1, timestamp_set2,set2_ind_of_set1_event)
%GET_DRIFT Summary of this function goes here
%   Detailed explanation goes here

  
    first_matched_set1_event = find(set2_ind_of_set1_event > 0,1,'first');
    last_matched_set1_event = find(set2_ind_of_set1_event > 0,1,'last');

    time_set1 = timestamp_set1 - timestamp_set1(first_matched_set1_event);
    time_set2 = timestamp_set2 - timestamp_set2(set2_ind_of_set1_event(first_matched_set1_event));

    first_event_offset = timestamp_set1(first_matched_set1_event) - timestamp_set2(set2_ind_of_set1_event(first_matched_set1_event));
    timestamp_set2 = timestamp_set2 + first_event_offset;

    drift = time_set1(last_matched_set1_event) - time_set2(set2_ind_of_set1_event(last_matched_set1_event));
    drift_correction_ratio = (time_set2(set2_ind_of_set1_event(last_matched_set1_event)) + ...
        drift)/time_set2(set2_ind_of_set1_event(last_matched_set1_event));
    
    timestamp_set2 = timestamp_set1(first_matched_set1_event) + (time_set2 * drift_correction_ratio);

end

